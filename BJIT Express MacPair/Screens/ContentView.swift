//
//  ContentView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 5/5/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @AppStorage("onboarding") var isonBoardingViewActive: Bool = true
    var body: some View {
        ZStack{
            if isonBoardingViewActive{
                OnboardingView()
            } else{
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
