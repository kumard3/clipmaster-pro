//
//  clip_board_appApp.swift
//  clip-board-app
//
//  Created by Kumar Deepanshu on 8/19/24.
//

import SwiftUI

@main
struct clip_board_appApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
