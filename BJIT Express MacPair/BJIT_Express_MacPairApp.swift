//
//  BJIT_Express_MacPairApp.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 5/5/23.
//

import SwiftUI

@main
struct BJIT_Express_MacPairApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var ckManager = CloudKitManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(ckManager)
        }
    }
}
