//
//  ServiceConfigRow.swift
//  DeveloperView
//
//  Created by Hugues Stéphano TELOLAHY on 24/07/2025.
//
import SwiftUI

struct ServiceConfigRow: View {
    let service: ServiceConfig

    var body: some View {
        NavigationLink(destination: ServiceDetailView(service: service)) {
            VStack(alignment: .leading) {
                HStack {
                    Text(service.name).font(.headline)
                    Spacer()
                    Text(service.mode.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if service.mode == .mock {
                    Text(service.selectedMock?.name ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}


struct ServiceConfigRowOld: View {
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
