//
//  MountainsApp.swift
//  Mountains
//
//  Created by Tim Mitra on 2024-05-19.
//

import SwiftUI
import SwiftData

@main
struct MountainsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            .modelContainer(container)
        }
    }
  @MainActor
  var container: ModelContainer {
    do {
      let container = try ModelContainer(for: MountainModel.self, migrationPlan: MountainModelMigrationPlan.self)
      return container
    } catch {
      fatalError("Could not create ModelContainer with migration plan: \(error.localizedDescription)")
    }
  }
}
