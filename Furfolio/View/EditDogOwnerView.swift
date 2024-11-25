//
//  SidebarView.swift
//  Furfolio
//
//  Created by mac on 11/20/24.
//

import SwiftUI

struct SidebarView: View {
    @Binding var dogOwners: [DogOwner]
    @Binding var selectedDogOwner: DogOwner?
    var onAddOwner: () -> Void
    var onShowMetrics: () -> Void

    var body: some View {
        List {
            ForEach(dogOwners, id: \.id) { owner in
                Button {
                    selectedDogOwner = owner
                } label: {
                    DogOwnerRowView(dogOwner: owner)
                }
            }
            .onDelete(perform: { offsets in deleteDogOwners(at: offsets) })
        }
        .navigationTitle("Furfolio")
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button("Metrics") {
                    onShowMetrics()
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Add") {
                    onAddOwner()
                }
            }
        }
    }

    private func deleteDogOwners(at offsets: IndexSet) {
        for index in offsets {
            let owner = dogOwners[index]
            dogOwners.remove(at: index)
            // Assuming delete logic to remove from modelContext
        }
    }
}

