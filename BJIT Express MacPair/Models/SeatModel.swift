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
}

struct SeatModel {
    var recordId: CKRecord.ID?
    var seatNumber: String
    var bookedBy: String
    var isReserved: Bool = false
    var isFilled: Bool = false
    
    var record: CKRecord {
        let record = CKRecord(recordType: SeatModelKeys.type.rawValue)
        record["seatNumber"] = seatNumber
        record["bookedBy"] = bookedBy
        record["isReserved"] = isReserved
        record["isFilled"] = isFilled
        return record
    }
}

extension SeatModel {
    init?(record: CKRecord) {
        
        guard let seatNumber = record["seatNumber"] as? String,
              let bookedBy = record["bookedBy"] as? String,
              let isReserved = record["isReserved"] as? Bool,
              let isFilled = record["isFilled"] as? Bool else {
            return nil
        }
        self.init(recordId: record.recordID, seatNumber: seatNumber, bookedBy: bookedBy, isReserved: isReserved, isFilled: isFilled)
    }
}
