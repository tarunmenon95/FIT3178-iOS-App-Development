//  DatabaseProtocol.swift
//  bazaar


//Database Protocol which acts as an interface for our main CoreDataController

import Foundation

//Database change operations
enum DatabaseChange {
    case add
    case remove
    case update
}

//ListenerTypes
enum ListenerType {
    case generalItem
}
//Listener changes
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onGeneralItemChange(change:DatabaseChange, generalItem: [GeneralItem])
    
}

//Define database functions
protocol DatabaseProtocol:AnyObject {
    func cleanup()
    
    func createDefaultGeneralItems()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addGeneralItem(name: String, value: Double, type:String, symbol: String) -> GeneralItem
    func removeGeneralItem(generalItem: GeneralItem)
    
    func fetchAllGeneralItems() -> [GeneralItem]
    func editItem(name:String, value:Double, symbol:String, type:String)
    
}
