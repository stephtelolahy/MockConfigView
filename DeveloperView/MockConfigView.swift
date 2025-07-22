//
//  MockConfigView.swift
//  DeveloperView
//
//  Created by Hugues Stéphano TELOLAHY on 22/07/2025.
//


import SwiftUI

struct MockConfigView: View {
    @StateObject private var viewModel = MockConfigViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredServices.keys.sorted(), id: \.self) { domain in
                    Section(header: Text(domain)) {
                        ForEach(viewModel.filteredServices[domain]!, id: \.key) { service in
                            ServiceConfigRow(service: service) { updated in
                                viewModel.updateService(updated)
                            }
                        }
                    }
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Mock Config")
            .searchable(text: $viewModel.searchText, prompt: "Search by name, key, domain, tag")
        }
    }
}

#Preview {
    MockConfigView()
}

struct ServiceConfigRow: View {
    @State var service: ServiceConfig
    var onUpdate: (ServiceConfig) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(service.name).font(.headline)
                Spacer()
                Picker("Mode", selection: $service.mode) {
                    ForEach(ServiceConfig.ServiceMode.allCases, id: \.rawValue) { mode in
                        Text(mode.rawValue.capitalized).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: service.mode) { _, _ in
                    if service.mode == .real {
                        service.selectedMock = nil
                    }
                    onUpdate(service)
                }
            }

            if service.mode == .mock {
                Picker("Mock", selection: $service.selectedMock) {
                    ForEach(service.availableMocks, id: \.name) { mock in
                        Text(mock.name).tag(Optional(mock))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: service.selectedMock) { _, _ in
                    onUpdate(service)
                }
            }

            VStack(alignment: .leading) {
                Text("Key: \(service.key)").font(.caption)
                Text("Domain: \(service.domain)").font(.caption)
                Text("Tags: \(service.tags.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 6)
    }
}
