//
//  PassengerListView.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 13/5/23.
//

import SwiftUI

struct DataItem {
    let id: Int
    let remTime: TimeInterval
    let isOnboard: Bool
}

struct PassengerListView: View {
    
    @EnvironmentObject private var ckManager: CloudKitManager
    
    
    var body: some View {
        
        List{
            Section {
                ListRowView(column1: "Employee ID", column2: "Remaining time", column3: nil, column4: "Status")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ForEach(ckManager.users, id: \.recordId) { item in
                    HStack {
                        ListRowView(column1: item.employeeId, column2: getFormatedDate(date: item.startTime), column3: nil, column4: item.isActive ? "Active" : "Inactive")
                    }
                }
            }
        }.onAppear(perform: {
            Task{
                try? await ckManager.populateUsers()
            }
        })
        
    }
    func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeInterval) ?? ""
    }
    func getFormatedDate(date: Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // Specify your desired date format
        
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}

struct PassengerListView_Previews: PreviewProvider {
    static var previews: some View {
        PassengerListView()
    }
}
