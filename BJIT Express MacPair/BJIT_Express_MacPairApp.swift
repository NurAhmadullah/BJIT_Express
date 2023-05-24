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
    @StateObject var homeViewModel = HomeViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(ckManager)
                .environmentObject(homeViewModel)
        }
    }
}
