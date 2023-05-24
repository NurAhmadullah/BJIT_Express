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
            VStack{
                Text("Employee Id: \(savedEmployeeID)")
                    .font(.headline)
//<<<<<<< Updated upstream
//                    .foregroundColor(.secondary)
//
//                ForEach(ckManager.buses, id: \.recordId) { bus in //ForEach(buses, id: \.recordId) { bus in
//                    NavigationLink(destination: DetailsView(busid: bus.busId))  {
//                        ListRowView(column1: bus.name, column2: "\(bus.busId)", column3: "50", column4: getFormatedDate(date: bus.startTime))                    }
//=======
                List{
                    ListRowView(column1: "Bus", column2: "Seats Reserved", column3: "Seats Booked", column4: "Departure time")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ForEach(ckManager.buses, id: \.recordId) { bus in //ForEach(buses, id: \.recordId) { bus in
                        NavigationLink(destination: DetailsView(busid: bus.busId))  {
                            ListRowView(column1: bus.name, column2: getNumberOfFilled(busId: bus.busId), column3: getNumberOfReserved(busId: bus.busId), column4: getFormatedDate(date: bus.startTime))                    }
                    }
                }
                .navigationTitle("Bus List")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    func getNumberOfFilled(busId: String)->String{
        return String(ckManager.getSeatsByBusId(busId: busId).filter{$0.isFilled}.count)
    }
    
    func getNumberOfReserved(busId: String)->String{
        var numberofReserved = ckManager.getSeatsByBusId(busId: busId).filter{$0.isFilled}.count - ckManager.getSeatsByBusId(busId: busId).filter{$0.isReserved}.count
        if numberofReserved < 0{
            numberofReserved = 0
        }
        return String(numberofReserved)
    }
    func getFormatedDate(date: Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // Specify your desired date format
        
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    

}

struct BusListView_Previews: PreviewProvider {
    static var previews: some View {
        BusListView()
    }
}
