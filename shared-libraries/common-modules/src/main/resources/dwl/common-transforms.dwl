%dw 2.0

/**
 * Common DataWeave Utility Functions
 * Shared across all integration modules in the enterprise platform.
 */

/**
 * Formats a DateTime to a standard ISO 8601 string.
 * @param dt - The DateTime to format
 * @param pattern - Optional format pattern (default: ISO 8601)
 * @return Formatted date string
 */
fun formatDate(dt: DateTime, pattern: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"): String =
    dt as String {format: pattern}

/**
 * Formats a Date (no time component) to a standard string.
 * @param d - The Date to format
 * @param pattern - Optional format pattern (default: yyyy-MM-dd)
 * @return Formatted date string
 */
fun formatDate(d: Date, pattern: String = "yyyy-MM-dd"): String =
    d as String {format: pattern}

/**
 * Parses a date string into a DateTime using the specified pattern.
 * @param dateStr - The date string to parse
 * @param pattern - The format pattern to use for parsing
 * @return Parsed DateTime object, or null if parsing fails
 */
fun parseDate(dateStr: String, pattern: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"): DateTime | Null =
    dateStr as DateTime {format: pattern} default null

/**
 * Parses a date string into a Date (no time) using the specified pattern.
 * @param dateStr - The date string to parse
 * @param pattern - The format pattern to use for parsing
 * @return Parsed Date object, or null if parsing fails
 */
fun parseDateOnly(dateStr: String, pattern: String = "yyyy-MM-dd"): Date | Null =
    dateStr as Date {format: pattern} default null

/**
 * Masks a string for PII protection, showing only the first and last
 * characters with asterisks in between.
 * @param value - The string to mask
 * @param visibleStart - Number of characters to show at the start (default: 1)
 * @param visibleEnd - Number of characters to show at the end (default: 1)
 * @return Masked string
 */
fun maskString(value: String, visibleStart: Number = 1, visibleEnd: Number = 1): String =
    if (sizeOf(value) <= (visibleStart + visibleEnd)) 
        ("*" * sizeOf(value))
    else 
        value[0 to visibleStart - 1] ++ ("*" * (sizeOf(value) - visibleStart - visibleEnd)) ++ value[(sizeOf(value) - visibleEnd) to -1]

/**
 * Masks an email address for safe logging.
 * user@domain.com -> u***r@domain.com
 * @param email - The email address to mask
 * @return Masked email string
 */
fun maskEmail(email: String): String = do {
    var parts = email splitBy "@"
    var localPart = parts[0] default ""
    var domainPart = parts[1] default ""
    ---
    if (sizeOf(parts) != 2) maskString(email)
    else maskString(localPart, 1, 1) ++ "@" ++ domainPart
}

/**
 * Masks a phone number, showing only the last 4 digits.
 * @param phone - The phone number to mask
 * @return Masked phone number
 */
fun maskPhone(phone: String): String = do {
    var digits = phone replace /[^\d]/ with ""
    ---
    if (sizeOf(digits) < 4) "****"
    else "***-***-" ++ digits[(sizeOf(digits) - 4) to -1]
}

/**
 * Masks a credit card number, showing only the last 4 digits.
 * @param cardNumber - The credit card number to mask
 * @return Masked credit card number
 */
fun maskCreditCard(cardNumber: String): String = do {
    var digits = cardNumber replace /[^\d]/ with ""
    ---
    if (sizeOf(digits) < 4) "****"
    else "****-****-****-" ++ digits[(sizeOf(digits) - 4) to -1]
}

/**
 * Creates a standardized paginated response wrapper.
 * @param items - The array of items for the current page
 * @param totalCount - Total number of items across all pages
 * @param page - Current page number (1-indexed)
 * @param pageSize - Number of items per page
 * @return Paginated response object
 */
fun paginate(items: Array, totalCount: Number, page: Number = 1, pageSize: Number = 20): Object = {
    data: items,
    pagination: {
        currentPage: page,
        pageSize: pageSize,
        totalItems: totalCount,
        totalPages: ceil(totalCount / pageSize),
        hasNextPage: (page * pageSize) < totalCount,
        hasPreviousPage: page > 1
    },
    metadata: {
        timestamp: now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"},
        resultCount: sizeOf(items)
    }
}

/**
 * Builds a standardized error response from error details.
 * @param errorCode - HTTP status code
 * @param message - Human-readable error message
 * @param detail - Detailed error description
 * @param path - Request path that caused the error
 * @param correlationId - Request correlation ID
 * @return Error response object
 */
fun buildErrorResponse(
    errorCode: Number, 
    message: String, 
    detail: String, 
    path: String = "unknown",
    cid: String = ""
): Object = {
    correlationId: cid,
    timestamp: now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"},
    errorCode: errorCode,
    message: message,
    detail: detail,
    path: path
}

/**
 * Generates a UUID v4 string.
 * @return UUID string
 */
fun generateId(): String = uuid()

/**
 * Calculates an MD5 checksum of the given string value.
 * Useful for comparing payloads, deduplication, and integrity checks.
 * @param value - The string to calculate the checksum for
 * @return MD5 hex-encoded checksum string
 */
fun calculateChecksum(value: String): String =
    dw::Crypto::MD5(value as Binary) as String

/**
 * Truncates a string to the specified max length, appending an ellipsis if truncated.
 * @param value - The string to truncate
 * @param maxLength - Maximum allowed length (default: 500)
 * @return Truncated string
 */
fun truncate(value: String, maxLength: Number = 500): String =
    if (sizeOf(value) > maxLength) value[0 to maxLength - 1] ++ "..."
    else value

/**
 * Converts a flat list of key-value pairs to a map.
 * @param pairs - Array of {key, value} objects
 * @return Object map
 */
fun toMap(pairs: Array<{key: String, value: Any}>): Object =
    pairs reduce ((item, acc = {}) -> acc ++ {(item.key): item.value})

/**
 * Safely coerces a value to a number, returning a default if conversion fails.
 * @param value - The value to coerce
 * @param defaultValue - Default number to return on failure
 * @return Number
 */
fun toNumber(value: Any, defaultValue: Number = 0): Number =
    value as Number default defaultValue

/**
 * Checks if a string is a valid email format.
 * @param email - The string to validate
 * @return Boolean
 */
fun isValidEmail(email: String): Boolean =
    email matches /^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/
