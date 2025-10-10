// Host-only entry point for the compiler plugin.
// Guarded to avoid compiling when running iOS tests.
#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct URLMacroPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [URLMacro.self]
}

#endif

