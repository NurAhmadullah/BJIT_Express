//
//  LoginView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 10/5/23.
//

import SwiftUI

struct LoginView: View {
    @State private var buttonWidth = UIScreen.main.bounds.width - 80
    @State private var employeeID: String = ""
    @State private var isValidEmployeeID = false
    @State private var navigateToSecondView = false
    var body: some View {
        NavigationView {
            ZStack {
                VStack{
                    Text("Enter Your Employee ID")
                        .font(.system(size: 25))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .transition(.opacity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Use a valid BJIT employee ID, 5 digit ID")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    TextField("", text: $employeeID)
                        .padding(10)
                        .padding(.leading, 25)
                        .background(
                            HStack {
                                Image("bjit-logo")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.vertical, 8)
                                if employeeID.isEmpty{
                                    Text("Your Employee ID")
                                        .font(.system(.callout))
                                        .opacity(0.5)
                                }
                            },
                            alignment: .leading
                        )
                        .padding(.horizontal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2)
                        )
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .onChange(of: employeeID) { newValue in
                            isValidEmployeeID = validateEmployeeID(newValue)
                        }
                    
                    Spacer()
                    
                    Button(action: {
                        navigateToSecondView = true
                    }, label: {
                        Text("Continue")
                            .foregroundColor(.white)
                            .frame(width: buttonWidth, height: 40)
                            .opacity(isValidEmployeeID ? 1 : 0.5)
                    })
                    .buttonStyle(BorderlessButtonStyle())
                    .background(Color.green, alignment: .center)
                    .cornerRadius(10)
                    .contentShape(Rectangle())
                    .disabled(!isValidEmployeeID)
                    
                    NavigationLink(destination: TabViews(), isActive: $navigateToSecondView) {
                        EmptyView()
                    }
                }
            }
        }
    }
    func validateEmployeeID(_ input: String) -> Bool {
        let pattern = #"^\d{5}$"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(input.startIndex..<input.endIndex, in: input)
        return regex.matches(in: input, range: range).count == 1
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
