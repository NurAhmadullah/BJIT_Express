//
//  SeatModel.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 18/5/23.
//

import Foundation
import CloudKit

enum SeatModelKeys: String {
    case type = "CKSeatModel"
    case sortKey = "seatId"
}

struct SeatModel {
    var recordId: CKRecord.ID?
    var seatId: String
    var busId: String
    var seatNumber: Int
    var bookedBy: String
    var isReserved: Bool = false
    var isFilled: Bool = false
    
    var record: CKRecord {
        let record = CKRecord(recordType: SeatModelKeys.type.rawValue)
        
        record["seatId"] = seatId
        record["busId"] = busId
        record["seatNumber"] = seatNumber
        record["bookedBy"] = bookedBy
        record["isReserved"] = isReserved
        record["isFilled"] = isFilled
        return record
    }
}

extension SeatModel {
    init?(record: CKRecord, busId:String) {
        
        guard let seatNumber = record["seatNumber"] as? Int,
              let seatId = record["seatId"] as? String,
              let bookedBy = record["bookedBy"] as? String,
              let isReserved = record["isReserved"] as? Bool,
              let isFilled = record["isFilled"] as? Bool else {
            return nil
        }
        self.init(recordId: record.recordID, seatId: seatId, busId: busId, seatNumber: seatNumber, bookedBy: bookedBy, isReserved: isReserved, isFilled: isFilled)
    }
}
