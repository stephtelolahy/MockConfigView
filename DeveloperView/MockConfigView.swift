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
        NavigationView {
            List {
                ForEach(viewModel.filteredServices.keys.sorted(), id: \.self) { domain in
                    Section(header: Text(domain)) {
                        ForEach(viewModel.filteredServices[domain]!, id: \.key) { service in
                            ServiceConfigRow(service: service)
                        }
                    }
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Mock Config")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Search by name, key, domain, tag")
        }
    }
}

#Preview {
    MockConfigView()
}
