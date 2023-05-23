//
//  KeyValueModel.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 23/5/23.
//

import Foundation
import CloudKit

enum KeyValueModelKeys: String {
    case type = "CKKeyValueModel"
    case sortKey = "busId"
    case createdAt = "createdAt"
}

struct KeyValueModel {
    var recordId: CKRecord.ID?
    var key: String
    var value: String
    var createdAt: Date

    var record: CKRecord {
        let record = CKRecord(recordType: KeyValueModelKeys.type.rawValue)
        record["key"] = key
        record["value"] = value
        record["createdAt"] = createdAt
        return record
    }
}

extension KeyValueModel {
    init?(record: CKRecord) {

        guard let key = record["key"] as? String,
              let value = record["value"] as? String,
              let createdAt = record["createdAt"] as? Date else {
            return nil
        }
        self.init(recordId: record.recordID, key: key, value: value, createdAt: createdAt)
    }
}

