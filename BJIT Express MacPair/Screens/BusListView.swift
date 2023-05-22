//
//  BusListView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 22/5/23.
//

import SwiftUI

struct BusListView: View {
    let numbers = [1, 2, 3, 4, 5]
    @State var numberOfReserved = 30
    @State var numberOfFilled = 15
    var body: some View {
        NavigationView {
            List{
                ListRowView(column1: "Bus", column2: "Seats Booked", column3: "Number of seats", column4: "Departure time")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ForEach(numbers, id: \.self) { bus in //ForEach(buses, id: \.recordId) { bus in
                    NavigationLink(destination: DetailsView(seatsReserved: numberOfReserved, seatsFilled: bus))  {
                        ListRowView(column1: "bus\(bus)", column2: "\(bus)", column3: "50", column4: getFormatedDate(date: Date()))                    }
                }
            }
            .navigationTitle("Bus List")
            .navigationBarTitleDisplayMode(.inline)
        }
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
