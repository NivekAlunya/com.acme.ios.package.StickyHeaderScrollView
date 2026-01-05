# StickyHeaderScrollView

A SwiftUI component that provides horizontal scrolling with sticky headers that remain visible at the left edge and smoothly transition as new headers approach.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0+-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## Features

✨ **Sticky Headers** - Headers stick to the left edge as you scroll
🔄 **Smooth Transitions** - Headers are elegantly pushed out by subsequent headers
🎨 **Fully Customizable** - Complete control over header and cell appearance
📦 **Type-Safe** - Built with Swift generics for maximum flexibility
🎯 **SwiftUI Native** - Uses modern SwiftUI APIs and follows best practices

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/NivekAlunya/com.acme.ios.package.StickyHeaderScrollView.git", from: "1.0.0")
]
```

Or in Xcode:
1. File > Add Package Dependencies
2. Enter the repository URL
3. Select version and add to your project

## Usage

### Basic Example

```swift
import SwiftUI
import StickyHeaderScrollView

struct ContentView: View {
    let items = [
        Product(id: "1", name: "Item 1", category: "Electronics"),
        Product(id: "2", name: "Item 2", category: "Electronics"),
        Product(id: "3", name: "Item 3", category: "Books"),
        Product(id: "4", name: "Item 4", category: "Books"),
    ]
    
    let headers: [String: CategoryHeader] = [
        "1": CategoryHeader(title: "Electronics", icon: "bolt"),
        "3": CategoryHeader(title: "Books", icon: "book")
    ]
    
    var body: some View {
        StickyHeaderScrollView(
            items: items,
            headers: headers
        ) { header in
            // Customize your header view
            HStack {
                Image(systemName: header.icon)
                Text(header.title)
            }
            .padding(8)
            .background(Color.blue)
            .cornerRadius(8)
        } cellBuilder: { index, item in
            // Customize your cell view
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text(item.category)
                    .font(.caption)
            }
            .frame(width: 200)
            .padding()
        }
    }
}
```

### Advanced Example

```swift
struct HeaderData {
    let title: String
    let subtitle: String
    let color: Color
}

struct MyView: View {
    let items: [MyItem]
    
    var body: some View {
        StickyHeaderScrollView(
            items: items,
            headers: createHeaders()
        ) { header in
            VStack(alignment: .leading, spacing: 4) {
                Text(header.title)
                    .font(.headline)
                Text(header.subtitle)
                    .font(.caption)
            }
            .padding()
            .background(header.color.opacity(0.2))
            .cornerRadius(12)
        } cellBuilder: { index, item in
            CustomCellView(item: item, index: index)
        }
    }
    
    func createHeaders() -> [String: HeaderData] {
        var headers: [String: HeaderData] = [:]
        // Add header data for specific items
        headers["item1"] = HeaderData(
            title: "Section 1",
            subtitle: "Description",
            color: .blue
        )
        return headers
    }
}
```

## How It Works

The `StickyHeaderScrollView` uses SwiftUI's geometry tracking to monitor the position of cells as they scroll. When a cell with a header scrolls past the left edge, the header "sticks" to the left side of the screen. As the next header approaches, it pushes the current header out of view with a smooth animation and fade effect.

### Key Concepts

- **Sticky Positioning**: Headers use `.position()` modifier with calculated offsets to stay at the left edge
- **Collision Detection**: Headers detect when the next header is approaching and adjust their position accordingly
- **Fade Effect**: Headers gradually fade out as they're pushed off-screen
- **Generic Design**: Works with any `Identifiable` item type and custom header data

## API Documentation

### StickyHeaderScrollView

```swift
struct StickyHeaderScrollView<Item: Identifiable, Header, HeaderContent: View, CellContent: View>: View
```

#### Initializer

```swift
init(
    items: [Item],
    headers: [Item.ID: Header],
    @ViewBuilder headerBuilder: @escaping (Header) -> HeaderContent,
    @ViewBuilder cellBuilder: @escaping (Int, Item) -> CellContent
)
```

**Parameters:**
- `items`: Array of items to display in the scroll view
- `headers`: Dictionary mapping item IDs to their header data. Only items with entries in this dictionary will have sticky headers
- `headerBuilder`: ViewBuilder closure to create custom header views
- `cellBuilder`: ViewBuilder closure to create custom cell views (receives index and item)

## Examples

Check out the `Examples` folder for complete working examples including:
- Basic usage with simple headers
- Advanced styling with custom designs
- Integration with real-world data models
- Multiple header styles in one view

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Kevin Launay - [@NivekAlunya](https://github.com/NivekAlunya/)

## Acknowledgments

- Built with SwiftUI
- Inspired by common UI patterns in modern iOS apps
- Thanks to the Swift community for feedback and suggestions

## Support

If you find this package useful, please consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs and issues
- 💡 Suggesting new features
- 📖 Improving documentation

---

Made with ❤️ using SwiftUI
