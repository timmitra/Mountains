//
//  MountainRowView.swift
//  Moutains
//
//  Created by Tim Mitra on 2024-05-19.
//

import SwiftUI
import SwiftData

struct MountainRowView: View {
  let mountain: MountainModel
  
  var body: some View {
    HStack {
      Image(uiImage: mountain.viewImage)
        .resizable()
        .scaledToFill()
        .frame(width: 80.0, height: 80.0)
      
      VStack(alignment: .leading, spacing: 8.0) {
        Text(mountain.name)
          .font(.title.weight(.semibold))
          .fontWidth(.compressed)
        // Version 2
        Text(mountain.viewElevation, format: .measurement(width: .abbreviated, usage: .asProvided))
          .font(.footnote)
        // Version 3
        Text(mountain.country?.name ?? "(none)")
          .foregroundStyle(.secondary)
      }
    }
  }
}

#Preview {
  let container = try! ModelContainer(for: MountainModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
  
  // Version 3
  let mountain = MountainModel(name: "Big Mountain", elevation: 14_409, image: UIImage(resource: .newMountain).pngData()!)
  let country = MountainCountryModel(name: "United States")
  container.mainContext.insert(country)
  country.mountains = [mountain]
  
  return List {
    MountainRowView(mountain: mountain)
  }
  .modelContainer(container)
}
