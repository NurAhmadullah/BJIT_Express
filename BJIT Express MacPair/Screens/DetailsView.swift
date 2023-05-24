//
//  DetailsView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 22/5/23.
//

import SwiftUI

struct DetailsView: View {
    @State private var selection = 0
    @EnvironmentObject private var ckManager: CloudKitManager
    @State var seatsReserved: Int = 0
    @State var seatsFilled: Int = 0
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
        .onAppear(){
            Task{
                ckManager.currentBusId = busid
                try? await ckManager.populateSeats(busId: busid)
                seatsFilled = ckManager.currentBusSeats.filter{$0.isFilled}.count
                seatsReserved = ckManager.currentBusSeats.filter{$0.isReserved}.count
            }
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(seatsReserved: 20, seatsFilled: 10, busid: "1")
    }
}
