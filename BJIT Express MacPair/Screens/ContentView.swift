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
                var busStartTime = Calendar.current.startOfDay(for: Date())
                    .addingTimeInterval(TimeInterval(3600 * 7))
                    .addingTimeInterval(TimeInterval(60 * 30))
                for bus in ckManager.buses{
                    await ckManager.setBusStartTime(editedBus: bus, startTime: busStartTime)
                    try? await ckManager.populateSeats(busId: bus.busId)
                    busStartTime = busStartTime.addingTimeInterval(TimeInterval(60 * 10))
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
