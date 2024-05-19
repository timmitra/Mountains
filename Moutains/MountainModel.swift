//
//  MountainModel.swift
//  Moutains
//
//  Created by Tim Mitra on 2024-05-19.
//

import Foundation
import SwiftData
import UIKit

@Model
class MountainModel {
  var name: String
  var country: String
  var image: Data? = nil
  
  init(
    name: String,
    country: String,
    image: Data? = nil
  ) {
    self.name = name
    self.country = country
    self.image = image
  }
}

extension MountainModel {
  @MainActor
  static var preview: ModelContainer {
    let container = try! ModelContainer(for: MountainModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    // Version 1
    addVersion1Data(modelContext: container.mainContext)
    
    return container
  }
  
  static func addVersion1Data(modelContext: ModelContext) {
    modelContext.insert(MountainModel(name: "Mount Rainier", country: "United States", image: UIImage(resource: .rainier).pngData()!))
    modelContext.insert(MountainModel(name: "Denali", country: "United States", image: UIImage(resource: .denali).pngData()!))
    modelContext.insert(MountainModel(name: "Mount Fuji", country: "Japan", image: UIImage(resource: .fuji).pngData()!))
    modelContext.insert(MountainModel(name: "Mount Kita", country: "Japan", image: UIImage(resource: .kita).pngData()!))
    modelContext.insert(MountainModel(name: "Mount Blanc", country: "Switzerland", image: UIImage(resource: .blanc).pngData()!))
    modelContext.insert(MountainModel(name: "Matterhorn", country: "Switzerland", image: UIImage(resource: .matterhorn).pngData()!))
  }
}

extension MountainModel {
  
  var viewImage: UIImage {
      guard let image = image else { return UIImage(resource: .newMountain) }
      return UIImage(data: image) ?? UIImage(resource: .newMountain)
  }
}
