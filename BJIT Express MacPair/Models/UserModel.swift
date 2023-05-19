//
//  UserModel.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 18/5/23.
//

import Foundation
import CloudKit

enum UserModelKeys: String {
    case type = "CKUserModel"
    case sortKey = "employeeId"
//    case taskName = "taskName"
//    case dateAssigned = "dateAssigned"
//    case isCompleted = "isCompleted"
//    case name: String = ""
//    case employeeId: String
//    case isActive: Bool = false
//    case startTime: Date
}

struct UserModel {
    var recordId: CKRecord.ID?
    var name: String
    var employeeId: String
    var isActive: Bool = false
    var startTime: Date
    
    var record: CKRecord {
        let record = CKRecord(recordType: UserModelKeys.type.rawValue)
        record["name"] = name
        record["employeeId"] = employeeId
        record["isActive"] = isActive
        record["startTime"] = startTime
        return record
    }
}

extension UserModel {
    init?(record: CKRecord) {
        
        guard let name = record["name"] as? String,
              let employeeId = record["employeeId"] as? String,
              let startTime = record["startTime"] as? Date else {
            return nil
        }
        self.init(recordId: record.recordID, name: name, employeeId: employeeId, startTime: startTime)
    }
}

