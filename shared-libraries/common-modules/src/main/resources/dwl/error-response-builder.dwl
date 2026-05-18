%dw 2.0
output application/json

/**
 * Error Response Builder
 * Constructs a standardized error response JSON from a Mule error object.
 *
 * Expected inputs (via variables or inline):
 *   - error: The Mule error object
 *   - correlationId: The request correlation ID
 *   - attributes: The HTTP request attributes (for path extraction)
 *   - vars.httpStatus: Optional override for the HTTP status code
 */

import * from dwl::common-transforms

// Map Mule error types to HTTP status codes
var errorTypeMapping = {
    "APIKIT:BAD_REQUEST": { code: 400, message: "Bad Request" },
    "APIKIT:NOT_FOUND": { code: 404, message: "Not Found" },
    "APIKIT:METHOD_NOT_ALLOWED": { code: 405, message: "Method Not Allowed" },
    "APIKIT:NOT_ACCEPTABLE": { code: 406, message: "Not Acceptable" },
    "APIKIT:UNSUPPORTED_MEDIA_TYPE": { code: 415, message: "Unsupported Media Type" },
    "HTTP:UNAUTHORIZED": { code: 401, message: "Unauthorized" },
    "HTTP:FORBIDDEN": { code: 403, message: "Forbidden" },
    "HTTP:NOT_FOUND": { code: 404, message: "Not Found" },
    "HTTP:CONNECTIVITY": { code: 503, message: "Service Unavailable" },
    "HTTP:TIMEOUT": { code: 504, message: "Gateway Timeout" },
    "HTTP:TOO_MANY_REQUESTS": { code: 429, message: "Too Many Requests" },
    "HTTP:BAD_REQUEST": { code: 400, message: "Bad Request" },
    "HTTP:INTERNAL_SERVER_ERROR": { code: 500, message: "Internal Server Error" },
    "VALIDATION:INVALID_BOOLEAN": { code: 400, message: "Bad Request" },
    "VALIDATION:INVALID_NUMBER": { code: 400, message: "Bad Request" },
    "VALIDATION:INVALID_SIZE": { code: 400, message: "Bad Request" },
    "VALIDATION:BLANK_STRING": { code: 400, message: "Bad Request" },
    "VALIDATION:NULL": { code: 400, message: "Bad Request" },
    "RETRY_EXHAUSTED": { code: 503, message: "Service Unavailable" },
    "EXPRESSION": { code: 500, message: "Internal Server Error" },
    "STREAM_MAXIMUM_SIZE_EXCEEDED": { code: 413, message: "Payload Too Large" },
    "TRANSFORMATION": { code: 500, message: "Internal Server Error" },
    "ROUTING": { code: 500, message: "Internal Server Error" },
    "SECURITY": { code: 403, message: "Forbidden" },
    "CLIENT_SECURITY": { code: 401, message: "Unauthorized" },
    "SERVER_SECURITY": { code: 500, message: "Internal Server Error" },
    "DUPLICATE_MESSAGE": { code: 409, message: "Conflict" }
}

// Resolve the error type key
var errorTypeKey = (error.errorType.namespace default "MULE") ++ ":" ++ (error.errorType.identifier default "UNKNOWN")

// Look up the mapped error or default to 500
var mappedError = errorTypeMapping[errorTypeKey] default { code: 500, message: "Internal Server Error" }

// Allow explicit override via httpStatus variable
var resolvedCode = vars.httpStatus default mappedError.code
var resolvedMessage = if (vars.httpStatus != null and vars.httpStatus != mappedError.code) 
    "Error" 
    else mappedError.message

// Sanitize error detail — never expose stack traces in non-dev environments
var safeDetail = if ((Mule::p('mule.env') default "local") == "prod")
    mappedError.message
    else error.description default "An unexpected error occurred."

---
{
    correlationId: correlationId,
    timestamp: now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"},
    errorCode: resolvedCode,
    message: resolvedMessage,
    detail: safeDetail,
    path: attributes.requestPath default attributes.requestUri default "unknown"
}
