# URLMacro

A Swift macro that provides compile-time URL validation with `#URL("…")` syntax.

## Usage

```swift
import URLMacro

let url = #URL("https://www.apple.com")
```

This will automatically generate the following code:

```swift
URL(string: "https://www.apple.com")!
```

## Installation

Using Swift Package Manager in Xcode: File → Add Packages… → введите URL репозитория и выберите продукт `URLMacro` для вашего App target (плагин добавлять не нужно).

В `Package.swift` другого пакета:

```swift
.package(url: "https://github.com/your-repo/URLMacro.git", from: "1.0.0"),
.target(name: "YourApp", dependencies: [
  .product(name: "URLMacro", package: "URLMacro")
])
```

## Requirements

- Xcode 15+/Swift 5.9+
- iOS 15.0+, macOS 12.0+, tvOS 15.0+, watchOS 8.0+

## Validation

The macro performs compile-time validation to ensure:

- The URL string is not empty
- The URL has a valid scheme (http, https, file, etc.)
- The URL has a valid host (except for file:// URLs)
- String interpolation is not allowed

Invalid URLs will produce compile-time errors with descriptive messages. The macro runs on the host (macOS) during compilation; in iOS/macOS binaries остаётся только сгенерированный код.

## Example iOS App

Минимальный пример см. в каталоге `Examples/App` (simple SwiftUI app, использует `#URL("https://example.com")`).

## License

`URLMacro` is available under the MIT license. See the LICENSE file for more info.

