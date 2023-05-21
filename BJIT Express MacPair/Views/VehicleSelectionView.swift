//
//  VehicleSelectionView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 19/5/23.
//

import SwiftUI
import MapKit

struct VehicleSelectionView: View {
    struct Mode: Identifiable{
        let id = UUID()
        let vehicleType: MKDirectionsTransportType
        let buttontext: String
        let icon: String
    }
    let modes: [Mode] = [Mode(vehicleType: .automobile, buttontext: "Car", icon: "car.fill"), Mode(vehicleType: .transit, buttontext: "Bus", icon: "bus.fill"), Mode(vehicleType: .walking, buttontext: "Walk", icon: "figure.walk")]
    @Binding var selectedVehicle : MKDirectionsTransportType
    @Namespace private var animation
    var body: some View {
        
        HStack{
            ForEach(modes){ mode in
                Button(action:{
                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7)){
                        selectedVehicle = mode.vehicleType
                    }
                }){
                    HStack{
                        Image(systemName: mode.icon)
                        Text(mode.buttontext)
                    }
                    .foregroundColor(Color("startButtonColor"))
                    .padding(.horizontal, 21)
                    .padding(.vertical, 5)
                    .background{
                        if selectedVehicle == mode.vehicleType{
                            Rectangle()
                                .fill(.blue.opacity(0.3))
                                .matchedGeometryEffect(id: "buttonID", in: animation)
                        } else{
                            Rectangle()
                                .fill(.blue.opacity(0.0))
                        }
                    }
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
            }
        }
    }
}



struct VehicleSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleSelectionView(selectedVehicle: Binding.constant(.automobile))
    }
}
