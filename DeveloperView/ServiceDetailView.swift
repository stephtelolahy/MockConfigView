//
//  ServiceDetailView.swift
//  DeveloperView
//
//  Created by Hugues Stéphano TELOLAHY on 24/07/2025.
//
import SwiftUI

struct ServiceDetailView: View {
    @State private var service: ServiceConfig
    @Environment(\.presentationMode) var presentationMode

    init(service: ServiceConfig) {
        _service = State(initialValue: service)
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    Text("Key: \(service.key)")
                    Text("Domain: \(service.domain)")
                    Text("Tags: \(service.tags.joined(separator: ", "))")
                }
            }
            .font(.caption)

            Section(header: Text("Mode")) {
                Picker("Service Mode", selection: $service.mode) {
                    ForEach(ServiceConfig.ServiceMode.allCases, id: \.rawValue) { mode in
                        Text(mode.rawValue.capitalized).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: service.mode) { _ in
                    if service.mode == .real {
                        service.selectedMock = nil
                    }
                }
            }

            if service.mode == .mock {
                Section(header: Text("Select Mock")) {
                    Picker("Mock", selection: Binding(
                        get: { service.selectedMock },
                        set: { service.selectedMock = $0 }
                    )) {
                        ForEach(service.availableMocks, id: \.name) { mock in
                            Text(mock.name).tag(Optional(mock))
                        }
                    }
                }
            }
        }
        .navigationTitle(service.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    updatePersistedService(service)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    private func updatePersistedService(_ updatedService: ServiceConfig) {
        guard var existing = UserDefaults.standard.loadServiceConfigs() else {
            fatalError("unable to load existing services")
        }

        guard let index = existing.firstIndex(where: { $0.key == updatedService.key }) else {
            fatalError("missing service to update")
        }

        existing[index] = updatedService
        UserDefaults.standard.saveServiceConfigs(existing)
    }
}
