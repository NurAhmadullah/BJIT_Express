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
    let seatsPerRow = 4
    let totalSeats = 50
    
    @State var seats = [Seat](repeating: Seat(available: true), count: 50)
    @State var rowCount:Int = Int(ceil(50.0 / 4.0))
    let letters = (65...90).map { String(UnicodeScalar($0)) }
    
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
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(.trailing, 55)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                VStack(spacing: 10) {
                    ForEach(0..<rowCount) { rowIndex in
                        HStack(spacing: 10) {
                            ForEach(0..<seatsPerRow) { columnIndex in
                                let seatIndex = rowIndex * seatsPerRow + columnIndex
                                if seatIndex < 50 {
                                    let seat = seats[seatIndex]
                                    Button(action: {
                                                                            if seat.available {
                                                                                seats[seatIndex].available = false
                                                                            } else {
                                                                                seats[seatIndex].available = true
                                                                            }
                                    }) {
                                        Text("\(letters[rowIndex])\( columnIndex+1)")
                                            .font(.system(size: 17))
                                            .foregroundColor(.white)
                                            .frame(width: 65, height: 65)
                                            .background(
//                                                Image("bus-seat-top-view")
//                                                    .renderingMode(.template)
//                                                    .resizable()
//                                                    .aspectRatio(contentMode: .fit)
                                                Rectangle()
                                                    .foregroundColor(seat.available ? Color.green : Color.red)
                                                    .cornerRadius(10)
//                                                    .scaleEffect(1.2)
                                            )
                                    }
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
                Spacer()
            }
        }
    }
}

struct BusLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        BusLayoutView()
    }
}
