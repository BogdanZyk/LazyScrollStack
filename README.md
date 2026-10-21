# LazyScrollStack

![iOS 16+](https://img.shields.io/badge/iOS-16%2B-000000?logo=apple) ![Swift 6](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white) ![SwiftUI](https://img.shields.io/badge/SwiftUI-supported-5E5CE6?logo=swift&logoColor=white) ![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?logo=swift&logoColor=white) ![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)

`LazyScrollStack` is an optimized scrolling container for large SwiftUI collections. It reuses rows around the viewport, supports fixed and changing heights, and exposes layout and scroll controls. In the included 1,000-row benchmark, it recorded the lowest total hitch time and peak RAM compared with SwiftUI `List` and `LazyVStack`.

Explore the [demo app](Example/LazyScrollStackDemo/README.md) for focused examples of the supported layouts and scrolling scenarios.

## 📕 Features

- **Lazy row hosting:** creates rows around the visible range and reuses hosted controllers while scrolling.
- **Flexible sizing:** supports fixed, variable, and dynamically changing row sizes.
- **Collection updates:** accepts read-only collections or bindings for editable rows.
- **Two axes:** works as a vertical list or a horizontal scrolling stack.
- **Scroll control:** configures bounce behavior, indicators, and user scrolling.
- **Measurements:** reports estimated or exact content size without adding a `GeometryReader` to every row.
- **Scroll metrics:** reports offset, progress, velocity, direction, and activity.
- **Pagination and animations:** supports a footer plus separate insertion, removal, and pagination transitions.
- **No third-party dependencies:** built with SwiftUI, UIKit, Foundation, and Core Graphics.

## 📋 Requirements

- iOS 16 or later
- Swift 6

## 🛠️ Usage

### Basic list

```swift
import LazyScrollStack
import SwiftUI

struct Item: Identifiable {
    let id: Int
    let title: String
}

struct ItemsView: View {
    let items: [Item]

    var body: some View {
        LazyScrollStack(items, spacing: 8) { item in
            Text(item.title)
                .padding()
        }
    }
}
```

Item IDs must be unique and stable. Changing an ID replaces the corresponding row.

### Mutable rows

Pass a binding when row content needs to edit the source collection:

```swift
LazyScrollStack($items, spacing: 8) { $item in
    Toggle(item.title, isOn: $item.isEnabled)
        .padding()
}
```

### Horizontal layout

```swift
LazyScrollStack(items, axis: .horizontal, spacing: 12) { item in
    ItemCard(item: item)
}
.frame(height: 160)
```

### Pagination footer

Use a footer as the loading trigger for the next page:

```swift
LazyScrollStack(items, spacing: 8) { item in
    ItemRow(item: item)
}
.footer {
    ProgressView()
        .padding()
        .task {
            await loadNextPage()
        }
}
```

### Scroll metrics

`ScrollMetrics` reports offset, normalized progress, velocity, direction, and activity:

```swift
LazyScrollStack(items) { item in
    ItemRow(item: item)
}
.onScrollMetricsChange { metrics in
    scrollProgress = metrics.progress
}
```

Use `onContentSizeChange` when the estimated or exact content size is needed:

```swift
.onContentSizeChange { measurement in
    print(measurement.size, measurement.measuredHeight.formatted)
}
```

### Item animations

```swift
LazyScrollStack(items) { item in
    ItemRow(item: item)
}
.itemAnimations(
    insertion: .scale(0.96).combined(with: .opacity),
    removal: .opacity,
    pagination: .opacity
)
```

## ⚙️ Configuration

| API | Purpose |
|---|---|
| `axis` | Selects vertical or horizontal layout. |
| `spacing` | Sets the distance between rows. |
| `footer` | Adds content after the last row, commonly a pagination loader. |
| `onContentSizeChange` | Reports the current size and whether its height is estimated or exact. |
| `onScrollMetricsChange` | Reports offset, progress, velocity, direction, and activity. |
| `alwaysBounce` | Allows bouncing when content is smaller than the viewport. |
| `bounces` | Enables or disables the rubber-band effect. |
| `showsIndicators` | Shows or hides native scroll indicators. |
| `isScrollEnabled` | Enables or disables user-driven scrolling. |
| `itemAnimations` | Configures insertion, removal, and pagination transitions. |

## 📊 Performance

Results from a 20-second fast-scroll test with 1,000 rows on an iPhone 15 running iOS 27. Measurements were collected in Instruments.

| Approach | Hitch time | Max hitch | Peak RAM |
|---|---:|---:|---:|
| SwiftUI `List` | 5.01 s | 33.33 ms | 34.7 MB |
| `ScrollView` + `LazyVStack` | 266.44 ms | 16.67 ms | 48.2 MB |
| `LazyScrollStack` | 33.28 ms | 16.67 ms | 30.8 MB |

Each approach used the same content and was tested for the same duration on the same physical device. The measurements show this test setup, not a guarantee for every workload.

The benchmark used the SwiftUI `List`, `LazyVStack`, and `LazyScrollStack` screens defined in [ListComparison.swift](Example/LazyScrollStackDemo/LazyScrollStackDemo/Screens/ListComparison.swift).

## 📄 License

`LazyScrollStack` is available under the MIT License. See [LICENSE](LICENSE) for details.
