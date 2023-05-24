//
//  BusListView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 22/5/23.
//

import SwiftUI

struct BusListView: View {
    @EnvironmentObject private var ckManager: CloudKitManager
    @EnvironmentObject private var homeViewModel: HomeViewModel
//    let numbers = [1, 2, 3, 4, 5]
    @AppStorage("employeeID") var savedEmployeeID: String = ""
    @State var numberOfReserved = 30
    @State var numberOfFilled = 15
    var body: some View {
        NavigationView {
            List{
                ListRowView(column1: "Bus", column2: "Seats Booked", column3: "Number of seats", column4: "Departure time")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ForEach(ckManager.buses, id: \.recordId) { bus in //ForEach(buses, id: \.recordId) { bus in
                    NavigationLink(destination: DetailsView(busid: bus.busId))  {
                        ListRowView(column1: bus.name, column2: "\(bus.busId)", column3: "50", column4: getFormatedDate(date: bus.startTime))                    }
                }
            }
            .navigationTitle("Bus List")
            .navigationBarTitleDisplayMode(.inline)
        }.onAppear(perform: {
            Task{
                await allocateBus()            }
        })
    }
    func getFormatedDate(date: Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // Specify your desired date format
        
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func allocateBus() async{
        var reserveDone = false
        for bus in ckManager.buses{
            let busDepartureDuration = abs(Int(Date().timeIntervalSince(bus.startTime)))
            if homeViewModel.durationInSecond < busDepartureDuration{
                // allocate to empty seat
                let isReserved = try? await ckManager.allocateSeat(busId: bus.busId, employeeId: savedEmployeeID)
                if isReserved == true{
                    reserveDone = true
                    break
                }
                else{
                    print("no seat in the bus: \(bus.name) of id: \(bus.busId), trying next bus")
                }
            }
        }
        if reserveDone == false{
            print("oops! no seat available on any bus")
        }
    }
}

struct BusListView_Previews: PreviewProvider {
    static var previews: some View {
        BusListView()
    }
}
