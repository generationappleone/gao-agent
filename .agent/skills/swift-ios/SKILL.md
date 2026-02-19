---
name: Swift / iOS
description: Skill for native iOS development with Swift — covering SwiftUI, UIKit, Combine, async/await, Core Data, networking, navigation, and App Store deployment.
---

# Swift / iOS Skill

## Overview
Swift is Apple's programming language for iOS, macOS, watchOS, and tvOS development. This skill covers SwiftUI as the modern standard.

**Reference**: [Swift Documentation](https://developer.apple.com/swift/)

## SwiftUI View
```swift
import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel = UserViewModel()
    @State private var searchText = ""

    var filteredUsers: [User] {
        searchText.isEmpty ? viewModel.users :
        viewModel.users.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredUsers) { user in
                NavigationLink(destination: UserDetailView(user: user)) {
                    HStack {
                        AsyncImage(url: URL(string: user.avatarUrl)) { image in
                            image.resizable().frame(width: 40, height: 40).clipShape(Circle())
                        } placeholder: { ProgressView() }
                        VStack(alignment: .leading) {
                            Text(user.name).font(.headline)
                            Text(user.email).font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Users")
            .refreshable { await viewModel.fetchUsers() }
            .task { await viewModel.fetchUsers() }
        }
    }
}
```

## ViewModel (MVVM)
```swift
@MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: String?

    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func fetchUsers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            users = try await apiService.get("/users")
        } catch {
            self.error = error.localizedDescription
        }
    }
}
```

## Networking
```swift
class APIService {
    static let shared = APIService()
    private let baseURL = URL(string: "https://api.example.com")!

    func get<T: Decodable>(_ path: String) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            throw APIError.invalidResponse
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **SwiftUI** | Preferred over UIKit for new projects |
| **MVVM** | ViewModel with `@ObservableObject` |
| **async/await** | Use for all async operations |
| **`@MainActor`** | UI updates on main thread |
| **Combine** | For reactive data pipelines |
| **Swift Concurrency** | `Task`, `TaskGroup`, `Actor` |
| **Core Data / SwiftData** | For local persistence |
| **SPM** | Swift Package Manager for dependencies |
