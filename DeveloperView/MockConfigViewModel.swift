//
//  MockConfigViewModel.swift
//  DeveloperView
//
//  Created by Hugues Stéphano TELOLAHY on 22/07/2025.
//


import Combine
import Foundation

struct ServiceConfig: Equatable, Codable {
    let key: String
    let name: String
    let domain: String
    let tags: [String]
    let availableMocks: [MockOption]
    var mode: ServiceMode = .real
    var selectedMock: MockOption? = nil

    enum ServiceMode: String, CaseIterable, Codable {
        case real
        case mock
    }

    struct MockOption: Hashable, Codable {
        let name: String
        let statusCode: Int
        let filePath: String
    }
}

class MockConfigViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var services: [ServiceConfig] = [] {
        didSet {
            UserDefaults.standard.saveServiceConfigs(services)
        }
    }

    var filteredServices: [String: [ServiceConfig]] {
        let lowercasedQuery = searchText.lowercased()
        let filtered = services.filter { service in
            searchText.isEmpty ||
            service.name.lowercased().contains(lowercasedQuery) ||
            service.key.lowercased().contains(lowercasedQuery) ||
            service.domain.lowercased().contains(lowercasedQuery) ||
            service.tags.contains { $0.lowercased().contains(lowercasedQuery) }
        }

        return Dictionary(grouping: filtered, by: { $0.domain })
    }

    init() {
        if let loaded = UserDefaults.standard.loadServiceConfigs() {
            services = loaded
        } else {
            services = ServiceConfig.mockData
        }
    }

    func updateService(_ updated: ServiceConfig) {
        if let index = services.firstIndex(where: { $0.key == updated.key }) {
            services[index] = updated
        }
    }
}

extension ServiceConfig {
    static var mockData: [Self] {
        [
            ServiceConfig(
                key: "user_profile",
                name: "UserProfileService",
                domain: "Authentication",
                tags: ["user", "profile", "auth"],
                availableMocks: [
                    .init(name: "Success", statusCode: 200, filePath: "user_success.json"),
                    .init(name: "Error", statusCode: 401, filePath: "user_error.json")
                ]
            ),
            ServiceConfig(
                key: "payment_gateway",
                name: "PaymentGatewayService",
                domain: "Authentication",
                tags: ["payment", "gateway", "checkout"],

                availableMocks: [
                    .init(name: "PaymentSuccess", statusCode: 200, filePath: "payment_success.json"),
                    .init(name: "PaymentDeclined", statusCode: 200, filePath: "payment_declined.json"),
                    .init(name: "Timeout", statusCode: 422, filePath: "payment_timeout.json")
                ]
            ),
            ServiceConfig(
                key: "content_feed",
                name: "ArticleContentService",
                domain: "ContentDelivery",
                tags: ["articles", "feed", "news"],
                availableMocks: [
                    .init(name: "FeedNormal", statusCode: 200, filePath: "feed_normal.json"),
                    .init(name: "EmptyFeed", statusCode: 200, filePath: "feed_empty.json")
                ]
            ),
            // Add more services
        ]
    }
}

extension UserDefaults {
    private var key: String { "dev_service_configs" }

    func saveServiceConfigs(_ configs: [ServiceConfig]) {
        if let data = try? JSONEncoder().encode(configs) {
            set(data, forKey: key)
        }
    }

    func loadServiceConfigs() -> [ServiceConfig]? {
        guard let data = data(forKey: key),
              let configs = try? JSONDecoder().decode([ServiceConfig].self, from: data)
        else {
            return nil
        }
        return configs
    }
}
