//
//  ContentView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 5/5/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject private var ckManager: CloudKitManager
    @AppStorage("onboarding") var isonBoardingViewActive: Bool = true
    var body: some View {
        ZStack{
            if isonBoardingViewActive{
                OnboardingView()
            } else{
                LoginView()
            }
        }
        .onAppear(){
            Task{
                try? await ckManager.populateBus()
                try? await ckManager.populateUsers()
                for (idx,bus) in ckManager.buses.enumerated(){
                    await ckManager.setBusStartTime(editedBus: bus, startTime: Date().addingTimeInterval(TimeInterval(3600 + (idx * 5 * 60))))
                    try? await ckManager.populateSeats(busId: bus.busId)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
