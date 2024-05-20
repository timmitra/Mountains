//
//  ContentView.swift
//  Moutains
//
//  Created by Tim Mitra on 2024-05-19.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var mountains: [MountainModel]
  
    var body: some View {
      NavigationStack {
        List(mountains) { mountain in
              MountainRowView(mountain: mountain)
        }.navigationTitle("Versioning")
          .toolbar {
            Button("", systemImage: "plus") {
              MountainModel.addVersion3Data(modelContext: modelContext)
            }
          }
      }
    }
}

#Preview {
    ContentView()
    .modelContainer(MountainModel.preview)
}
