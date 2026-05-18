%dw 2.0
output application/json

/**
 * Audit Logger
 * Builds a comprehensive audit log entry with before/after state comparison.
 *
 * Expected inputs (via variables):
 *   - vars.auditAction: The action being audited (CREATE, UPDATE, DELETE, READ)
 *   - vars.entityType: The type of entity (Order, Customer, Payment, etc.)
 *   - vars.entityId: The unique identifier of the entity
 *   - vars.beforeState: The entity state before the operation (null for CREATE)
 *   - vars.afterState: The entity state after the operation (null for DELETE)
 *   - vars.userId: The user performing the action
 *   - vars.auditMetadata: Optional additional metadata
 */

import * from dwl::common-transforms

/**
 * Compares two objects and returns only the fields that have changed.
 * @param before - The object state before the change
 * @param after - The object state after the change
 * @return Object with changed fields showing old and new values
 */
fun diffStates(before: Object, after: Object): Object = do {
    var allKeys = (keysOf(before) ++ keysOf(after)) distinctBy $
    ---
    allKeys reduce ((key, acc = {}) -> do {
        var oldVal = before[key]
        var newVal = after[key]
        ---
        if (oldVal == newVal) acc
        else acc ++ {
            (key): {
                oldValue: oldVal default null,
                newValue: newVal default null
            }
        }
    })
}

/**
 * Determines the sensitivity level of the audit event.
 * @param action - The audit action
 * @param entityType - The type of entity
 * @return Sensitivity level string
 */
fun sensitivityLevel(action: String, entityType: String): String =
    if (action == "DELETE") "HIGH"
    else if (entityType == "Payment" or entityType == "CreditCard" or entityType == "BankAccount") "HIGH"
    else if (action == "UPDATE" and (entityType == "Customer" or entityType == "User")) "MEDIUM"
    else if (action == "CREATE") "MEDIUM"
    else "LOW"

// Build the change summary
var changeDetails = vars.auditAction match {
    case "CREATE" -> {
        changeType: "CREATION",
        changedFields: keysOf(vars.afterState default {}) as Array,
        newState: vars.afterState default {}
    }
    case "DELETE" -> {
        changeType: "DELETION",
        changedFields: keysOf(vars.beforeState default {}) as Array,
        previousState: vars.beforeState default {}
    }
    case "UPDATE" -> {
        changeType: "MODIFICATION",
        changedFields: keysOf(diffStates(vars.beforeState default {}, vars.afterState default {})) as Array,
        fieldChanges: diffStates(vars.beforeState default {}, vars.afterState default {})
    }
    else -> {
        changeType: upper(vars.auditAction default "UNKNOWN"),
        changedFields: []
    }
}

---
{
    auditId: generateId(),
    timestamp: now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"},
    correlationId: correlationId,
    
    // Who
    actor: {
        userId: vars.userId default "system",
        clientId: vars.apiKeyClientId default vars.jwtSubject default "unknown",
        sourceIp: attributes.remoteAddress default "unknown",
        userAgent: attributes.headers.'user-agent' default "unknown"
    },
    
    // What
    action: {
        type: vars.auditAction default "UNKNOWN",
        description: (vars.auditAction default "UNKNOWN") ++ " " ++ (vars.entityType default "Entity") ++ " [" ++ (vars.entityId default "unknown") ++ "]"
    },
    
    // On what
    resource: {
        entityType: vars.entityType default "Unknown",
        entityId: vars.entityId default "unknown",
        path: attributes.requestPath default attributes.requestUri default "unknown"
    },
    
    // Change details
    changes: changeDetails,
    
    // Context
    context: {
        applicationName: app.name default "mule-app",
        environment: Mule::p('mule.env') default "local",
        sensitivity: sensitivityLevel(vars.auditAction default "READ", vars.entityType default "Unknown"),
        method: attributes.method default "UNKNOWN",
        statusCode: vars.httpStatus default 200
    },

    // Additional metadata
    metadata: vars.auditMetadata default {}
}
