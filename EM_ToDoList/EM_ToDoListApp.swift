//
//  EM_ToDoListApp.swift
//  EM_ToDoList
//
//  Created by Мария Александрова on 09.08.2026.
//

import SwiftUI
import CoreData

@main
struct EM_ToDoListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
