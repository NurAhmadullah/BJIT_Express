//
//  CloudKitManager.swift
//  BJIT Express MacPair
//
//  Created by BJIT on 18/5/23.
//

import Foundation
import CloudKit

/*
class CloudKitDefaults{
    static let shared = CloudKitDefaults()
    let isInitialSetupDone = "isInitialSetupDone"
    private init(){}

    func setBooleanValue(key:String, boolValue: Bool){
        keyValueStore.set(boolValue, forKey: key)
    }
    func getBooleanValue(key:String)->Bool{
        keyValueStore.bool(forKey: key)
    }
}
*/



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
    @Published private var busDictionary: [CKRecord.ID: BusModel] = [:]
    @Published private var seatsDictionary: [CKRecord.ID: SeatModel] = [:]
    @Published private var keyValuesDictionary: [CKRecord.ID: KeyValueModel] = [:]
    
    var users: [UserModel] {
        usersDictionary.values.compactMap { $0 }
    }
    var seats: [SeatModel] {
        seatsDictionary.values.compactMap { $0 }
    }
    var buses: [BusModel] {
        busDictionary.values.compactMap { $0 }
    }
    var keyValues: [KeyValueModel] {
        keyValuesDictionary.values.compactMap { $0 }
    }
    var currentBusId = "1"
    var currentBusSeats: [SeatModel] {          // used on bus detail-view
        seats.filter{$0.busId == currentBusId}
    }

    /*
    func setupInitialBussesAndSeats() async{
        if !CloudKitDefaults.shared.getBooleanValue(key: CloudKitDefaults.shared.isInitialSetupDone){
            do{
                try? await addBus(bus: BusModel(name: "BJIT Bus", busId: "1", startTime: Date()))
                try? await addBus(bus: BusModel(name: "Gulshan Chaka", busId: "2", startTime: Date()))
                try? await addBus(bus: BusModel(name: "Dhaka Chaka", busId: "3", startTime: Date()))

                var allSeatCnt = 0
                for bus in self.buses{
                    for seatNumber in 1...50{
                        try? await addSeat(seat: SeatModel(seatId: "\(allSeatCnt)", busId: bus.busId, seatNumber: seatNumber, bookedBy: ""))
                        allSeatCnt += 1
                    }
                }
            }
        }
        CloudKitDefaults.shared.setBooleanValue(key: CloudKitDefaults.shared.isInitialSetupDone, boolValue: true)
    }
    */
    
    func populateKeyValue() async throws {

        let query = CKQuery(recordType: KeyValueModelKeys.type.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: KeyValueModelKeys.sortKey.rawValue, ascending: false)]
        let result = try await db.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }

        records.forEach { record in
            keyValuesDictionary[record.recordID] = KeyValueModel(record: record)
        }
    }
    
    func setKeyValue(key: String, value: String) async throws {
        if let keyVal = isKeyExists(key: key){
            // update key value
            return
        }
        else{
            let keyValue = KeyValueModel(key: key, value: value, createdAt: Date())
            let record = try await db.save(keyValue.record)
            guard let keyValue = KeyValueModel(record: record) else { return }
            keyValuesDictionary[keyValue.recordId!] = keyValue
        }
    }
    private func isKeyExists(key:String)->KeyValueModel?{
        let keyVal = keyValues.filter {
            return $0.key == key
        }
        return keyVal.first
    }

//    func getKeyValue(key: String) async throws {
//        let record = try await db.save(keyValue.record)
//        guard let keyValue = KeyValueModel(record: record) else { return }
//        keyValuesDictionary[keyValue.recordId!] = keyValue
//    }


    func populateUsers() async throws {
        
        let query = CKQuery(recordType: UserModelKeys.type.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: UserModelKeys.sortKey.rawValue, ascending: false)]
        let result = try await db.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        
        records.forEach { record in
            usersDictionary[record.recordID] = UserModel(record: record)
        }
    }
    
    func populateBus() async throws {
        
        let query = CKQuery(recordType: BusModelKeys.type.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: BusModelKeys.sortKey.rawValue, ascending: false)]
        let result = try await db.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        
        records.forEach { record in
            busDictionary[record.recordID] = BusModel(record: record)
        }
    }
    
    func populateSeats() async throws {
        
        let query = CKQuery(recordType: SeatModelKeys.type.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: SeatModelKeys.sortKey.rawValue, ascending: false)]
        let result = try await db.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        
        records.forEach { record in
            seatsDictionary[record.recordID] = SeatModel(record: record)
        }
    }
    
    
    func addUser(user: UserModel) async throws {
        let record = try await db.save(user.record)
        guard let user = UserModel(record: record) else { return }
        
        usersDictionary[user.recordId!] = user
    }
    
    func addBus(bus: BusModel) async throws {
        let record = try await db.save(bus.record)
        guard let bus = BusModel(record: record) else { return }
        
        busDictionary[bus.recordId!] = bus
    }
    
    func addSeat(seat: SeatModel) async throws {
        let record = try await db.save(seat.record)
        guard let seat = SeatModel(record: record) else { return }

        seatsDictionary[seat.recordId!] = seat
    }
    
    
    func deleteUser(userToBeDeleted: UserModel) async throws {
        
        usersDictionary.removeValue(forKey: userToBeDeleted.recordId!)
        
        do {
            let _ = try await db.deleteRecord(withID: userToBeDeleted.recordId!)
        } catch {
            // put back the task into the tasks array
            usersDictionary[userToBeDeleted.recordId!] = userToBeDeleted
            // throw the exception
            throw TaskError.operationFailed(error)
        }
    }
    
    func deleteBus(busToBeDeleted: BusModel) async throws {
        
        busDictionary.removeValue(forKey: busToBeDeleted.recordId!)
        
        do {
            let _ = try await db.deleteRecord(withID: busToBeDeleted.recordId!)
        } catch {
            // put back the task into the tasks array
            busDictionary[busToBeDeleted.recordId!] = busToBeDeleted
            // throw the exception
            throw TaskError.operationFailed(error)
        }
    }
    
    func deleteSeat(seatToBeDeleted: SeatModel) async throws {
        
        seatsDictionary.removeValue(forKey: seatToBeDeleted.recordId!)
        
        do {
            let _ = try await db.deleteRecord(withID: seatToBeDeleted.recordId!)
        } catch {
            // put back the task into the tasks array
            seatsDictionary[seatToBeDeleted.recordId!] = seatToBeDeleted
            // throw the exception
            throw TaskError.operationFailed(error)
        }
    }
    
    func updateUser(editedUser: UserModel) async {
        
        usersDictionary[editedUser.recordId!]?.isActive = editedUser.isActive
        
        do {
        
            let record = try await db.record(for: editedUser.recordId!)
            record["isActive"] = editedUser.isActive
            
            // save it
            try await db.save(record)
        } catch {
            
            // rollback the update
            usersDictionary[editedUser.recordId!] = editedUser
        }
    }
    
    
    func setBusStartTime(editedBus:BusModel,startTime:Date) async {
        
//        print("bus schedule test: setBusStartTime")
        busDictionary[editedBus.recordId!]?.startTime = startTime
        do {
            let record = try await db.record(for: editedBus.recordId!)
            record["startTime"] = startTime
            
            try await db.save(record)
        } catch {
            busDictionary[editedBus.recordId!] = editedBus
        }
    }

    
    func reserveSeat(editedSeat: SeatModel,EmployeeId:String) async {
        
//        print("reserve test: reserveSeat")
        seatsDictionary[editedSeat.recordId!]?.isReserved = true
        seatsDictionary[editedSeat.recordId!]?.isFilled = false
        seatsDictionary[editedSeat.recordId!]?.bookedBy = EmployeeId
        do {
            let record = try await db.record(for: editedSeat.recordId!)
            record["isReserved"] = true
            record["isFilled"] = false
            record["bookedBy"] = EmployeeId
            
            try await db.save(record)
        } catch {
            seatsDictionary[editedSeat.recordId!] = editedSeat
        }
    }
    
    func bookSeat(editedSeat: SeatModel) async {
        
//        print("reserve test: bookSeat")
        seatsDictionary[editedSeat.recordId!]?.isFilled = true
        do {
            let record = try await db.record(for: editedSeat.recordId!)
            record["isFilled"] = true
            
            try await db.save(record)
        } catch {
            seatsDictionary[editedSeat.recordId!] = editedSeat
        }
    }
    
    
    func getSeatsByBusId(busId: String)->[SeatModel]{
        
//        print("reserve test: getSeatsByBusId")
        return seats.filter{$0.busId == busId}
    }
    
    func isSeatReserved(employeeId:String)->SeatModel?{
        return seats.filter{$0.bookedBy == employeeId}.first
    }
    
    // reserve seat for
    func allocateSeat(busId: String, employeeId:String) async -> Bool{
        
//        print("reserve test: allocateSeat")
        if isSeatReserved(employeeId: employeeId) != nil{
            return true
        }
        var seatInBus = getSeatsByBusId(busId: busId)
        for seat in seatInBus{
            if seat.isReserved == false{
                do{
                    try? await reserveSeat(editedSeat: seat, EmployeeId: employeeId)
                }
                return true
            }
        }
        return false
    }
    
    
    // free up the seat from its user
    func deallocateSeat(editedSeat: SeatModel) async {
        
//        print("reserve test: deallocateSeat")
        seatsDictionary[editedSeat.recordId!]?.isReserved = false
        seatsDictionary[editedSeat.recordId!]?.isFilled = false
        seatsDictionary[editedSeat.recordId!]?.bookedBy = ""
        do {
            let record = try await db.record(for: editedSeat.recordId!)
            record["isReserved"] = false
            record["isFilled"] = false
            record["bookedBy"] = false
            
            try await db.save(record)
        } catch {
            seatsDictionary[editedSeat.recordId!] = editedSeat
        }
    }
    
}
