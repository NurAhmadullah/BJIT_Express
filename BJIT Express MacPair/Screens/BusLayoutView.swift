//
//  BusLayoutView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 11/5/23.
//

import SwiftUI

struct Seat: Identifiable {
    let id = UUID()
    var available: Bool
}

struct BusLayoutView: View {
    @EnvironmentObject private var ckManager: CloudKitManager
    let seatsPerRow = 4
    let totalSeats = 50
    var seatsReserved: Int
    var seatsFilled: Int
//    @State var seats = [Seat](repeating: Seat(available: true), count: 50)
    @State var rowCount:Int = Int(ceil(50.0 / 4.0))
    let letters = (65...90).map { String(UnicodeScalar($0)) }
    var busId:String
//    @State var busSeats: [SeatModel] = []
    
    
    var body: some View {
        ScrollView {
            HStack(spacing: 20){
                HStack{
                    Rectangle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.green)
                        .cornerRadius(5)
                    Text("Available")
                }
                HStack{
                    Rectangle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.gray)
                        .cornerRadius(5)
                    Text("Reserved")
                }
                HStack{
                    Rectangle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.red)
                        .cornerRadius(5)
                    Text("Booked")
                }
            }
            
            VStack {
                Image("steering-wheel")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(.trailing, 55)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                if ckManager.currentBusSeats.count > 0{
                    VStack(spacing: 10) {
                        ForEach(0..<rowCount) { rowIndex in
                            HStack(spacing: 10) {
                                ForEach(0..<seatsPerRow) { columnIndex in
                                    let seatIndex = rowIndex * seatsPerRow + columnIndex
                                    if seatIndex < ckManager.currentBusSeats.count {
                                        let seat = ckManager.currentBusSeats[seatIndex]
                                        Text("\(letters[rowIndex])\( columnIndex+1)")
                                            .font(.system(size: 17))
                                            .foregroundColor(.white)
                                            .frame(width: 65, height: 65)
                                            .background(
                                                //                                            Image("bus-seat-top-view")
                                                //                                                .renderingMode(.template)
                                                //                                                .resizable()
                                                //                                                .aspectRatio(contentMode: .fit)
                                                Rectangle()
                                                    .foregroundColor(getSeatColor(seatIndex: seatIndex))
                                                    .cornerRadius(10)
                                            )
                                        if (seatIndex + 1) % 2 == 0 && (seatIndex + 1) % 4 == 2{
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            //                        .padding(.vertical, 5)
                        }
                    }
                }
                Spacer()
            }
        }
        .onAppear(){
            Task{
                try? await ckManager.currentBusId = busId
                try? await ckManager.populateSeats()
            }
        }
    }
    func getSeatColor(seatIndex: Int)->Color{
        if ckManager.currentBusSeats[seatIndex].isFilled{
            return .red
        }
        else if ckManager.currentBusSeats[seatIndex].isReserved{
            return .gray
        }
        else{
            return .green
        }
        /*
        if seatIndex < seatsFilled{
            return .red
        } else if seatIndex < seatsReserved{
            return .gray
        } else{
            return .green
        }
        */
    }
}

struct BusLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        BusLayoutView(seatsReserved: 20, seatsFilled: 10, busId: "1")
    }
}
