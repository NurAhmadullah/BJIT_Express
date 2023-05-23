//
//  BusModel.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 18/5/23.
//

import Foundation
import CloudKit

enum BusModelKeys: String {
    case type = "CKBusModel"
    case sortKey = "busId"
}

struct BusModel {
    var recordId: CKRecord.ID?
    var name: String
    var busId: String       // bus number
    var startTime: Date     // daily start time
    
    var record: CKRecord {
        let record = CKRecord(recordType: BusModelKeys.type.rawValue)
        record["name"] = name
        record["busId"] = busId
        record["startTime"] = startTime
        return record
    }
}

extension BusModel {
    init?(record: CKRecord) {
        
        guard let name = record["name"] as? String,
              let busId = record["busId"] as? String,
              let startTime = record["startTime"] as? Date else {
            return nil
        }
        self.init(recordId: record.recordID, name: name, busId: busId, startTime: startTime)
    }
}
