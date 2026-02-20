---
name: Swift / iOS
description: Skill for native iOS development with Swift — covering SwiftUI, UIKit, Combine, async/await, Core Data, networking, navigation, and App Store deployment.
---

# Swift / iOS Skill

## Overview
Swift is Apple's programming language for iOS, macOS, and watchOS development. Modern iOS uses SwiftUI for declarative UI, async/await for concurrency, Combine for reactive programming, and MVVM architecture.

**References**:
- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)

---

## SwiftUI Views

```swift
struct ProductListView: View {
    @StateObject private var viewModel = ProductViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.products) { product in
                NavigationLink(destination: ProductDetailView(product: product)) {
                    ProductRowView(product: product)
                }
            }
            .navigationTitle("Products")
            .searchable(text: $viewModel.searchQuery)
            .refreshable { await viewModel.loadProducts() }
            .overlay { if viewModel.isLoading { ProgressView() } }
        }
        .task { await viewModel.loadProducts() }
    }
}

struct ProductRowView: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: product.imageUrl)) { image in
                image.resizable().scaledToFill()
            } placeholder: { Color.gray.opacity(0.2) }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name).font(.headline)
                Text("$\(product.price / 100).\(String(format: "%02d", product.price % 100))").foregroundColor(.indigo).fontWeight(.bold)
                HStack { Image(systemName: "star.fill").foregroundColor(.yellow).font(.caption); Text("\(product.rating, specifier: "%.1f")").font(.caption) }
            }
        }
        .padding(.vertical, 4)
    }
}
```

---

## ViewModel

```swift
@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    
    private let apiService = APIService.shared
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await apiService.getProducts(search: searchQuery)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
```

---

## Networking

```swift
class APIService {
    static let shared = APIService()
    private let baseURL = "https://api.myapp.com"
    
    func getProducts(search: String = "") async throws -> [Product] {
        var components = URLComponents(string: "\(baseURL)/api/products")!
        if !search.isEmpty { components.queryItems = [URLQueryItem(name: "search", value: search)] }
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw APIError.invalidResponse }
        return try JSONDecoder().decode(PaginatedResponse<Product>.self, from: data).data
    }
}

struct Product: Codable, Identifiable {
    let id: String
    let name: String
    let slug: String
    let price: Int
    let rating: Double
    let imageUrl: String
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **SwiftUI** | Declarative UI with NavigationStack |
| **async/await** | Modern concurrency with task/await |
| **@MainActor** | ViewModels on main thread |
| **@Published** | Observable state properties |
| **Codable** | JSON encoding/decoding |
| **AsyncImage** | Async image loading |
| **MVVM** | ViewModel separates logic from view |
| **NavigationStack** | Type-safe navigation (iOS 16+) |
| **searchable** | Built-in search modifier |
| **refreshable** | Pull-to-refresh support |

---

## Rules Integration
- **UI**: SwiftUI with NavigationStack and modifiers
- **Architecture**: MVVM with ObservableObject
- **Networking**: async/await with URLSession
- **Data**: Codable for JSON, Core Data for persistence
