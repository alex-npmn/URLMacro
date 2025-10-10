import Foundation

/// A Swift macro that provides compile-time URL validation.
///
/// Use `#URL("https://example.com")` to create a validated URL at compile time.
///
/// - Important: The URL string must be a static string literal. String interpolation
///   and dynamic values are not supported and will result in compile-time errors.
@freestanding(expression)
public macro URL(_ string: StaticString) -> Foundation.URL =
#externalMacro(module: "URLMacroPlugin", type: "URLMacro")
