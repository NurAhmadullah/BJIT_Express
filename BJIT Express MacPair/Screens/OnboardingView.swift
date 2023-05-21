//
//  OnboardingView.swift
//  BJIT XPRESS
//
//  Created by BJIT on 28/4/23.
//


import SwiftUI

struct OnboardingView: View {
    @AppStorage("onboarding") var isonBoardingViewActive: Bool = true
    @State private var buttonWidth = UIScreen.main.bounds.width - 80
    @State private var isAnimating = false
//    @State private var buttonOffset: CGFloat = 0
//    @State private var imageOffset: CGSize = .zero
//    @State private var indicatorOpacity = 1.0
    @State private var textTitle = "BJIT Xpress"
    
    var body: some View {
        ZStack{
            VStack{
                Text(textTitle)
                    .font(.system(size: 40))
                    .fontWeight(.heavy)
                    .foregroundColor(.green)
                    .transition(.opacity)
                    .padding(.vertical, 10)
                
                Image("onboardingImage")
                    .resizable()
                    .scaledToFit()
                    .opacity(isAnimating ? 1: 0)
                    .animation(.easeInOut(duration: 0.5), value: isAnimating)
                    .padding(.bottom, 20)
//                Spacer()
                Text("Welcome to BJIT Xpress!")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
                Text("For a optimized life!")
                    .fontWeight(.semibold)
                    .padding(.vertical, 10)
                Spacer()
                Button(action: {
                    isonBoardingViewActive = false
                }, label: {
                    Text("Get Started")
                        .foregroundColor(.white)
                        .frame(width: buttonWidth, height: 40, alignment: .leading)
                        .offset(x: 20)
                        
                    Image(systemName: "arrowtriangle.right.fill")
                        .offset(x: -20)
                        .foregroundColor(.white)
                })
                .buttonStyle(.borderless)
                .background(Color.green, alignment: .center)
                .cornerRadius(10)
            }
            
        }.onAppear{
            isAnimating.toggle()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
