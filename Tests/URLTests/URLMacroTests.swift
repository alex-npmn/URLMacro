import URLMacro
import XCTest
#if canImport(SwiftSyntaxMacrosTestSupport) && canImport(URLMacroPlugin) && os(macOS)
import URLMacroPlugin
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
#endif

final class URLMacroTests: XCTestCase {

  // MARK: - Valid URLs

  func testValidHTTPURL() {
    let url = #URL("https://www.apple.com")
    XCTAssertEqual(url.absoluteString, "https://www.apple.com")
  }

  func testValidHTTPSURL() {
    let url = #URL("https://api.example.com/v1/users")
    XCTAssertEqual(url.absoluteString, "https://api.example.com/v1/users")
  }

  func testValidFileURL() {
    let url = #URL("file:///Users/username/Documents/file.txt")
    XCTAssertEqual(url.absoluteString, "file:///Users/username/Documents/file.txt")
  }

  func testValidLocalhostURL() {
    let url = #URL("http://localhost:8080/api")
    XCTAssertEqual(url.absoluteString, "http://localhost:8080/api")
  }

  func testValidURLWithQueryParameters() {
    let url = #URL("https://api.example.com/search?q=swift&limit=10")
    XCTAssertEqual(url.absoluteString, "https://api.example.com/search?q=swift&limit=10")
  }

  func testValidURLWithFragment() {
    let url = #URL("https://example.com/page#section")
    XCTAssertEqual(url.absoluteString, "https://example.com/page#section")
  }

  // MARK: - Error Cases (Compile-time validation)

  // Note: These test cases demonstrate what happens when invalid inputs are provided.
  // The actual error cases cannot be tested directly as they produce compile-time errors.

  func testMacroValidatesURLsCorrectly() {
    // Test that valid URLs work correctly
    let validHTTP = #URL("http://example.com")
    XCTAssertEqual(validHTTP.scheme, "http")

    let validHTTPS = #URL("https://example.com")
    XCTAssertEqual(validHTTPS.scheme, "https")

    let validFile = #URL("file:///path/to/file")
    XCTAssertEqual(validFile.scheme, "file")
  }

  /*
   The following error cases are validated at compile-time:

   1. Invalid URL formats:
   #URL("not-a-valid-url")
   → Error: Invalid URL: "not-a-valid-url"

   2. Empty URLs:
   #URL("")
   → Error: URL must not be empty

   3. String interpolation:
   let host = "example.com"
   #URL("https://\(host)")
   → Error: `#URL` does not allow string interpolation

   4. Non-literal strings:
   let dynamicString = "https://example.com"
   #URL(dynamicString)
   → Error: `#URL` expects a string literal

   5. Missing scheme:
   #URL("example.com")
   → Error: Invalid URL: "example.com"

   6. Invalid schemes:
   #URL("invalid://example.com")
   → Error: Invalid URL: "invalid://example.com" (depending on URLComponents validation)
   */

  // MARK: - Edge Cases

  func testURLWithSpecialCharacters() {
    let url = #URL("https://example.com/path%20with%20spaces")
    XCTAssertEqual(url.absoluteString, "https://example.com/path%20with%20spaces")
  }

  func testURLWithUnicodeCharacters() {
    let url = #URL("https://пример.рф")
    // Unicode domains are converted to punycode by Foundation.URL
    XCTAssertEqual(url.absoluteString, "https://xn--e1afmkfd.xn--p1ai")
  }

  func testMinimalValidURL() {
    let url = #URL("https://a.b")
    XCTAssertEqual(url.absoluteString, "https://a.b")
  }

  // MARK: - Additional Tests for Robustness

  func testURLsWithDifferentSchemes() {
    // Test FTP URL
    let ftpURL = #URL("ftp://files.example.com/file.zip")
    XCTAssertEqual(ftpURL.scheme, "ftp")

    // Test custom scheme
    let customURL = #URL("myapp://settings")
    XCTAssertEqual(customURL.scheme, "myapp")
  }

  func testComplexURL() {
    let complexURL = #URL("https://user:pass@example.com:8080/path/to/resource?param=value&other=123#fragment")
    XCTAssertEqual(complexURL.scheme, "https")
    XCTAssertEqual(complexURL.host, "example.com")
    XCTAssertEqual(complexURL.port, 8080)
    XCTAssertEqual(complexURL.path, "/path/to/resource")
    XCTAssertEqual(complexURL.query, "param=value&other=123")
    XCTAssertEqual(complexURL.fragment, "fragment")
  }

  // MARK: - Macro expansion & diagnostics (host-only)
#if canImport(SwiftSyntaxMacrosTestSupport) && canImport(URLMacroPlugin) && os(macOS)

  func testExpansion_valid() {
    assertMacroExpansion(
      """
      #URL("https://example.com")
      """,
      expandedSource: """
      Foundation.URL(string: "https://example.com")!
      """,
      macros: ["URL": URLMacro.self]
    )
  }

  func testExpansion_file() {
    assertMacroExpansion(
      """
      #URL("file:///tmp/file.txt")
      """,
      expandedSource: """
      Foundation.URL(string: "file:///tmp/file.txt")!
      """,
      macros: ["URL": URLMacro.self]
    )
  }

  func testDiagnostics_invalid() {
    assertMacroExpansion(
      """
      #URL("not-a-valid-url")
      """,
      expandedSource: """
      Foundation.URL(string: "")!
      """,
      diagnostics: [DiagnosticSpec(message: "Invalid URL: \"not-a-valid-url\"", line: 1, column: 6)],
      macros: ["URL": URLMacro.self]
    )
  }

  func testDiagnostics_empty() {
    assertMacroExpansion(
      """
      #URL("")
      """,
      expandedSource: """
      Foundation.URL(string: "")!
      """,
      diagnostics: [DiagnosticSpec(message: "URL must not be empty", line: 1, column: 6)],
      macros: ["URL": URLMacro.self]
    )
  }
  
  func testDiagnostics_interpolation() {
    assertMacroExpansion(
      """
      #URL("https://\\(host)")
      """,
      expandedSource: """
      Foundation.URL(string: "")!
      """,
      diagnostics: [DiagnosticSpec(message: "`#URL` does not allow string interpolation", line: 1, column: 6)],
      macros: ["URL": URLMacro.self]
    )
  }
#endif

  /*
   Note: The following cases would produce compile-time errors and demonstrate
   the macro's validation capabilities:

   1. #URL("not-a-valid-url") → Invalid URL error
   2. #URL("") → Empty URL error
   3. #URL("example.com") → Invalid URL (missing scheme)
   4. #URL("https://") → Invalid URL (missing host)
   5. String interpolation usage → Interpolation not allowed error
   6. Non-literal string usage → String literal expected error

   These errors are caught at compile-time, making URL usage safer.
   */
}

