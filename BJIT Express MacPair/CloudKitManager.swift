//
//  CloudKitManager.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 18/5/23.
//

import Foundation
import CloudKit


//var name: String
//var employeeId: String
//var isActive: Bool = false
//var startTime: Date

enum TaskError: Error {
    case operationFailed(Error)
}


struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: Error
    let guidance: String
}



@MainActor
class CloudKitManager: ObservableObject {
    private var db = CKContainer.init(identifier: "iCloud.teamMacPair.bjitgroup.upskilldev").publicCloudDatabase
    @Published private var usersDictionary: [CKRecord.ID: UserModel] = [:]
    
    var users: [UserModel] {
        usersDictionary.values.compactMap { $0 }
    }
    
    
    func populateTasks() async throws {
        
        let query = CKQuery(recordType: UserModelKeys.type.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "employeeId", ascending: false)]
        let result = try await db.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        
        records.forEach { record in
            usersDictionary[record.recordID] = UserModel(record: record)
        }
    }
    
    
    func addTask(task: UserModel) async throws {
        let record = try await db.save(task.record)
        guard let task = UserModel(record: record) else { return }
        
        usersDictionary[task.recordId!] = task
    }
    
    func deleteTask(taskToBeDeleted: UserModel) async throws {
        
        usersDictionary.removeValue(forKey: taskToBeDeleted.recordId!)
        
        do {
            let _ = try await db.deleteRecord(withID: taskToBeDeleted.recordId!)
        } catch {
            // put back the task into the tasks array
            usersDictionary[taskToBeDeleted.recordId!] = taskToBeDeleted
            // throw the exception
            throw TaskError.operationFailed(error)
        }
    }
    
    func updateTask(editedTask: UserModel) async {
        
        usersDictionary[editedTask.recordId!]?.isActive = editedTask.isActive
        
        do {
        
            let record = try await db.record(for: editedTask.recordId!)
            record["isActive"] = editedTask.isActive
            
            // save it
            try await db.save(record)
        } catch {
            
            // rollback the update
            usersDictionary[editedTask.recordId!] = editedTask
        }
    }

    
    
    
}
