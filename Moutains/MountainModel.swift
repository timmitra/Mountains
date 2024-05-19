//
//  MountainModel.swift
//  Moutains
//
//  Created by Tim Mitra on 2024-05-19.
//

import Foundation
import SwiftData
import UIKit

// MARK: - STEP 1: UPDATE TYPE ALIASES
//typealias MountainModel = MountainModelSchemaV1.MountainModel
typealias MountainModel = MountainModelSchemaV2.MountainModel


/*@Model
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
}*/

extension MountainModel {
  @MainActor
  static var preview: ModelContainer {
    let container = try! ModelContainer(for: MountainModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    // Version 1
//    addVersion1Data(modelContext: container.mainContext)
    // Version 2
    addVersion2Data(modelContext: container.mainContext)
    
    return container
  }
  
  static func addVersion2Data(modelContext: ModelContext) {
    modelContext.insert(MountainModel(name: "Mount Rainier", country: "United States", elevation: 14_409, image: UIImage(resource: .rainier).pngData()!))
    modelContext.insert(MountainModel(name: "Denali", country: "United States", elevation: 20_308, image: UIImage(resource: .denali).pngData()!))
    modelContext.insert(MountainModel(name: "Mount Fuji", country: "Japan", elevation: 12_388,image: UIImage(resource: .fuji).pngData()!))
    modelContext.insert(MountainModel(name: "Mount Kita", country: "Japan", elevation: 10_476,image: UIImage(resource: .kita).pngData()!))
    modelContext.insert(MountainModel(name: "Mount Blanc", country: "Switzerland", elevation: 15_777, image: UIImage(resource: .blanc).pngData()!))
    modelContext.insert(MountainModel(name: "Matterhorn", country: "Switzerland", elevation: 14_692, image: UIImage(resource: .matterhorn).pngData()!))
  }

}

// MARK: - Migration Plan
enum MountainModelMigrationPlan: SchemaMigrationPlan {
  static var schemas: [any VersionedSchema.Type] {
    // Step 1 Append new versions to this array
    [MountainModelSchemaV1.self, MountainModelSchemaV2.self]
  }
    // Step 2 define your migration steps as lightweight or custom
    static let migrateV1toV2 = MigrationStage.lightweight(
      fromVersion: MountainModelSchemaV1.self,
      toVersion: MountainModelSchemaV2.self)
  
  static var stages: [MigrationStage] {
    // Step 3 append new stages to this array
    [migrateV1toV2]
  }

}

// MARK: - Version 1
enum MountainModelSchemaV1: VersionedSchema {
  static var versionIdentifier = Schema.Version(1, 0, 0)
  
  static var models: [any PersistentModel.Type] {
    [MountainModel.self]
  }
  
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
}

// MARK: - Version 2
enum MountainModelSchemaV2: VersionedSchema {
  static var versionIdentifier = Schema.Version(2, 0, 0)
  
  static var models: [any PersistentModel.Type] {
    [MountainModel.self]
  }
  
  @Model
  class MountainModel {
    var name: String
    var country: String
    var elevation: Int = 0
    var image: Data? = nil
    
    init(
      name: String,
      country: String,
      elevation: Int,
      image: Data? = nil
    ) {
      self.name = name
      self.country = country
      self.elevation = elevation
      self.image = image
    }
  }
}

// MARK: - Version 3
enum MountainModelSchemaV3: VersionedSchema {
  static var versionIdentifier = Schema.Version(3, 0, 0)
  
  static var models: [any PersistentModel.Type] {
    [MountainModel.self]
  }
  
  @Model
  class MountainModel {
    var name: String
    // New Relationship
    @Relationship(inverse: \MountainCountryModel.mountains)
    var country: MountainCountryModel?
    var elevation: Int = 0
    var image: Data? = nil
    
    init(
      name: String,
      country: MountainCountryModel?,
      elevation: Int,
      image: Data? = nil
    ) {
      self.name = name
      self.country = country
      self.elevation = elevation
      self.image = image
    }
  }
  
  @Model
  class MountainCountryModel {
    @Attribute(.unique)
    var name: String
    var mountains: [MountainModel] = []
    
    init(name: String, mountains: [MountainModel] = []) {
      self.name = name
      self.mountains = mountains
    }
  }
}

// MARK: - EXTENSIONS
extension MountainModel {
  var viewImage: UIImage {
    guard let image = image else { return UIImage(resource: .newMountain) }
    return UIImage(data: image) ?? UIImage(resource: .newMountain)
  }
  
  // Version 02
  var viewElevation: Measurement<UnitLength> {
    Measurement(value: Double(elevation), unit: UnitLength.feet)
  }
}
