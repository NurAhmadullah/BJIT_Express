//
//  DetailsView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 22/5/23.
//

import SwiftUI

struct DetailsView: View {
    @State private var selection = 0
    var seatsReserved: Int
    var seatsFilled: Int
    var busid: String
    var body: some View {
        
        VStack() {
            Picker("", selection: $selection) {
                Text("Bus Seats").tag(0)
                Text("Pessengers details").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 10)
            
            if selection == 0 {
                BusLayoutView(seatsReserved: seatsReserved, seatsFilled: seatsFilled, busId: busid)
            } else {
                PassengerListView(busid: busid)
            }
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(seatsReserved: 20, seatsFilled: 10, busid: "1")
    }
}
