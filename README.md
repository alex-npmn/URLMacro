# URLMacro

A Swift macro that provides compile-time URL validation with `#URL("…")` syntax.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS-lightgrey.svg)](https://github.com/alex-npmn/URLMacro)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

## Features

✅ **Compile-time URL validation** - catch invalid URLs at build time, not runtime  
✅ **Zero runtime overhead** - expands to simple `URL(string:)!` calls  
✅ **Clear error messages** - descriptive compiler errors for invalid URLs  
✅ **Cross-platform** - works on iOS, macOS, tvOS, watchOS  

## Usage

```swift
import URLMacro

// ✅ Valid URLs - compile successfully
let apple = #URL("https://www.apple.com")
let github = #URL("https://github.com/user/repo")
let file = #URL("file:///tmp/document.pdf")

// ❌ Invalid URLs - compile-time errors
let invalid = #URL("not-a-url")            // Error: Invalid URL
let empty = #URL("")                       // Error: URL must not be empty
let interpolated = #URL("https://\(host)") // Error: String interpolation not allowed
```

## Installation

### Swift Package Manager

#### Xcode
1. File → Add Package Dependencies
2. Enter: `https://github.com/alex-npmn/URLMacro.git`
3. Add `URLMacro` to your target

#### Package.swift
```swift
dependencies: [
    .package(url: "https://github.com/alex-npmn/URLMacro.git", from: "1.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "URLMacro", package: "URLMacro")
    ])
]
```

## Requirements

- **Swift 5.9+** (Xcode 15+)
- **iOS 15.0+** / **macOS 12.0+** / **tvOS 15.0+** / **watchOS 8.0+**

## How it works

The `#URL` macro validates URLs at compile time and expands to regular `Foundation.URL` calls:

```swift
// This code:
let url = #URL("https://example.com")

// Becomes:
let url = Foundation.URL(string: "https://example.com")!
```

## Validation Rules

The macro ensures:
- ✅ URL string is not empty
- ✅ URL has a valid scheme (http, https, file, etc.)  
- ✅ URL has a valid host (except for file:// URLs)
- ✅ Only string literals are allowed (no interpolation)

## License

URLMacro is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

