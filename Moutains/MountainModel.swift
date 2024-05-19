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
//typealias MountainModel = MountainModelSchemaV2.MountainModel
typealias MountainModel = MountainModelSchemaV3.MountainModel
typealias MountainCountryModel = MountainModelSchemaV3.MountainCountryModel


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
//    addVersion2Data(modelContext: container.mainContext)
    // Version 3
    addVersion3Data(modelContext: container.mainContext)
    
    return container
  }
  
  static func addVersion3Data(modelContext: ModelContext) {
    // Mountains
    let rainier = MountainModel(name: "Mount Rainier", elevation: 14_409, image: UIImage(resource: .rainier).pngData()!)
    let denali = MountainModel(name: "Denali", elevation: 20_308, image: UIImage(resource: .denali).pngData()!)
    let fuji = MountainModel(name: "Mount Fuji", elevation: 12_388,image: UIImage(resource: .fuji).pngData()!)
    let kita = MountainModel(name: "Mount Kita", elevation: 10_476,image: UIImage(resource: .kita).pngData()!)
    let blanc = MountainModel(name: "Mount Blanc", elevation: 15_777, image: UIImage(resource: .blanc).pngData()!)
    let matterhorn = MountainModel(name: "Matterhorn", elevation: 14_692, image: UIImage(resource: .matterhorn).pngData()!)
    
    //Countries
    let usa = MountainCountryModel(name: "United States")
    let japan = MountainCountryModel(name: "Japan")
    let switzerland = MountainCountryModel(name: "Switzerland")
    
    modelContext.insert(usa)
    usa.mountains = [rainier, denali]
    modelContext.insert(japan)
    japan.mountains = [fuji, kita]
    modelContext.insert(switzerland)
    switzerland.mountains = [blanc, matterhorn]
  }

}

// MARK: - Migration Plan
enum MountainModelMigrationPlan: SchemaMigrationPlan {
  static var schemas: [any VersionedSchema.Type] {
    // Step 1 Append new versions to this array
    [
      MountainModelSchemaV1.self,
      MountainModelSchemaV2.self,
      MountainModelSchemaV3.self
    ]
  }
    // Step 2 define your migration steps as lightweight or custom
    static let migrateV1toV2 = MigrationStage.lightweight(
      fromVersion: MountainModelSchemaV1.self,
      toVersion: MountainModelSchemaV2.self)
  
  // Mountain-to-country for migrateV2toV3
  static var mountainToCountryDictionary: [String: String] = [:]
  
  static let migrateV2toV3 = MigrationStage.custom(
    fromVersion: MountainModelSchemaV2.self,
    toVersion: MountainModelSchemaV3.self,
    willMigrate: { modelContext in
      // willMigrate before migration
      guard let mountains = try? modelContext.fetch(FetchDescriptor<MountainModelSchemaV2.MountainModel>()) else {
        return
      }
       // save the mapping of mountain name to country
      mountainToCountryDictionary = mountains.reduce(into: [:], { $0[$1.name] = $1.country })
    }, didMigrate: { modelContext in
      // after migration
      let uniqueCountries = Set(mountainToCountryDictionary.values)
      // Add Countries
      for country in uniqueCountries {
        modelContext.insert(MountainModelSchemaV3.MountainCountryModel(name: country))
      }
      try? modelContext.save()
      
      guard let mountains = try? modelContext.fetch(FetchDescriptor<MountainModelSchemaV3.MountainModel>()) else {
        return
      }
      guard let countries = try? modelContext.fetch(FetchDescriptor<MountainModelSchemaV3.MountainCountryModel>()) else {
        return
      }
      // Match mountains to countries
      for mtnToCountry in mountainToCountryDictionary {
        guard let mtnModel = mountains.first(where: { $0.name == mtnToCountry.key}) else { return }
        guard let countryModel = countries.first(where: { $0.name == mtnToCountry.value}) else { return }
        mtnModel.country = countryModel
        try? modelContext.save()
      }
    })
  
  static var stages: [MigrationStage] {
    // Step 3 append new stages to this array
    [migrateV1toV2, migrateV2toV3]
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
    [MountainModel.self, MountainCountryModel.self]
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
      country: MountainCountryModel? = nil,
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
