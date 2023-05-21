//
//  MapTopView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 20/5/23.
//

import SwiftUI

struct MapTopView: View {
    var body: some View {
        HStack(spacing: 0){
            VStack(spacing: 0){
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 3)
                    .overlay(content: {
                        Circle()
                            .frame(width: 10)
                            .foregroundColor(.blue)
                    })
                    .frame(width: 20)
                    .padding(.bottom, 5)
                Circle()
                    .frame(width: 3)
                    .foregroundColor(.gray.opacity(0.8))
                    .padding(.vertical, 3)
                Circle()
                    .frame(width: 3)
                    .foregroundColor(.gray.opacity(0.8))
                    .padding(.vertical, 3)
                Circle()
                    .frame(width: 3)
                    .foregroundColor(.gray.opacity(0.8))
                    .padding(.vertical, 3)
                    .padding(.bottom, 5)
                Image(systemName: "mappin.circle")
                    .foregroundColor(.red)
                    .font(Font.system(size: 20))
                    .padding(.bottom, 5)
                
            }
            .padding(.leading, 20)
            .padding(.top, 8)
            VStack{
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                
                    .frame(height: 40)
                    .overlay(content: {
                        Text("Your Location")
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                    .padding(.horizontal, 10)
                
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                
                    .frame(height: 40)
                    .overlay(content: {
                        Text("Notun Bazar, fire station")
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                    .padding(.horizontal, 10)
            }
        }
        .padding(.vertical, 10)
    }
}

struct MapTopView_Previews: PreviewProvider {
    static var previews: some View {
        MapTopView()
    }
}
