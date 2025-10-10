// The macro implementation must only build on the host toolchain.
// Guard it to avoid accidental compilation when running iOS tests.
#if canImport(SwiftCompilerPlugin)
import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

enum URLDiag {
  struct NotStringLiteral: DiagnosticMessage {
    let message = "`#URL` expects a string literal"
    let diagnosticID = MessageID(domain: "URLMacro", id: "not_string_literal")
    let severity = DiagnosticSeverity.error
  }

  struct InterpolationNotAllowed: DiagnosticMessage {
    let message = "`#URL` does not allow string interpolation"
    let diagnosticID = MessageID(domain: "URLMacro", id: "no_interpolation")
    let severity = DiagnosticSeverity.error
  }

  struct EmptyURL: DiagnosticMessage {
    let message = "URL must not be empty"
    let diagnosticID = MessageID(domain: "URLMacro", id: "empty")
    let severity = DiagnosticSeverity.error
  }

  struct InvalidURL: DiagnosticMessage {
    let s: String
    var message: String { "Invalid URL: \"\(s)\"" }
    let diagnosticID = MessageID(domain: "URLMacro", id: "invalid_url")
    let severity = DiagnosticSeverity.error
  }
}

public struct URLMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {
    // SwiftSyntax 601+ uses 'arguments', earlier versions use 'argumentList'
    #if canImport(SwiftSyntax601)
    let argExpr = node.arguments.first?.expression
    #else
    let argExpr = node.argumentList.first?.expression
    #endif
    
    guard let argExpr else {
      context.diagnose(Diagnostic(node: Syntax(node), message: URLDiag.NotStringLiteral()))
      return "Foundation.URL(string: \"\")!"
    }

    // Only accept a *plain* string literal (no interpolation).
    guard let literal = argExpr.as(StringLiteralExprSyntax.self) else {
      context.diagnose(Diagnostic(node: Syntax(argExpr), message: URLDiag.NotStringLiteral()))
      return "Foundation.URL(string: \"\")!"
    }

    if literal.segments.count != 1 {
      context.diagnose(Diagnostic(node: Syntax(argExpr), message: URLDiag.InterpolationNotAllowed()))
      return "Foundation.URL(string: \"\")!"
    }

    let raw = literal.segments.reduce(into: "") { acc, seg in
      if case .stringSegment(let s) = seg { acc += s.content.text }
    }

    if raw.isEmpty {
      context.diagnose(Diagnostic(node: Syntax(literal), message: URLDiag.EmptyURL()))
      return "Foundation.URL(string: \"\")!"
    }

    // Validate using URLComponents; require a scheme and host (except for file://).
    if let comps = URLComponents(string: raw),
       let scheme = comps.scheme, !scheme.isEmpty,
       (comps.host?.isEmpty == false || scheme.lowercased() == "file")
    {
      // Emit a normal expression using the original literal.
      return ExprSyntax("Foundation.URL(string: \(literal))!")
    } else {
      context.diagnose(Diagnostic(node: Syntax(literal), message: URLDiag.InvalidURL(s: raw)))
      return "Foundation.URL(string: \"\")!"
    }
  }
}
#endif
