//
//  PassengerListView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 13/5/23.
//

import SwiftUI

//struct PassengerListView: View {
//    let items = [
//        ("Item 1", 10, "$50.00"),
//        ("Item 2", 5, "$20.00"),
//        ("Item 3", 20, "$100.00"),
//    ]
//    struct DataItem {
//        let id: Int
//        let remTime: TimeInterval
//        let isOnboard: Bool
//    }
//
//    var dataset: [DataItem] = []
//
//
//
//    var body: some View {
//        List(dataset, id: \.id) { item in
//            HStack {
//                Text("\(item.id)")
//                Spacer()
//                Text("\(Int(item.remTime))s")
//                Spacer()
//                Text(item.isOnboard ? "Onboard" : "Not onboard")
//            }
//        }
//        .onAppear(perform: {
//            populateData()
//        })
//    }
//    func populateData(){
//        for i in 1...40 {
//            let randomBool = Bool.random()
//            let randomTimeInterval = TimeInterval(Int.random(in: 0..<1200))
//            let newItem = DataItem(id: i, remTime: randomTimeInterval, isOnboard: randomBool)
//            dataset.append(newItem)
//        }
//    }
//}


struct DataItem {
    let id: Int
    let remTime: TimeInterval
    let isOnboard: Bool
}

struct PassengerListView: View {
    /*
    let dataset: [DataItem] = {
        var data: [DataItem] = []
        for i in 1...40 {
            let id = Int.random(in: 10000..<15000)
            let randomBool = Bool.random()
            let randomTimeInterval = TimeInterval(Int.random(in: 0..<300))
            let newItem = DataItem(id: id, remTime: randomTimeInterval, isOnboard: randomBool)
            data.append(newItem)
        }
        data = data.sorted(by: {$0.remTime < $1.remTime})
        return data
    }()
    */
    
    @EnvironmentObject private var ckManager: CloudKitManager
    
    
    var body: some View {

        VStack {
            Menu("Choose Bus", content: {
                Button("Bus 1", action: {
                    
                })
                Button("Bus 2", action: {
                    
                })
                Button("Bus 3", action: {
                    
                })
                Button("Bus 4", action: {
                    
                })
            })
            List{
                Section {
                    HStack {
                        Text("Employee ID")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Remaining time")
                            .frame(maxWidth: .infinity)
                        Text("Onboard or Not onboard")
                            .frame(maxWidth: .infinity)
                            .frame(alignment: .trailing)
                    }
                                        .font(.headline)
                                        .foregroundColor(.secondary)

                    ForEach(ckManager.users, id: \.recordId) { item in
                        HStack {
                            Text(String(item.employeeId))
                                .frame(maxWidth: .infinity, alignment: .leading)
//                            Text(formatTimeInterval(item.startTime))
//                                .frame(maxWidth: .infinity)
                            Text(item.isActive ? "Onboard" : "Not onboard")
                                .frame(maxWidth: .infinity)
                                .frame(alignment: .trailing)
                        }
                    }
                }
            }
        }
    }
    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeInterval) ?? ""
    }
}

struct PassengerListView_Previews: PreviewProvider {
    static var previews: some View {
        PassengerListView()
    }
}
