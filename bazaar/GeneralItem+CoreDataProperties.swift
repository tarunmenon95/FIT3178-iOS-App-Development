//  GeneralItem+CoreDataProperties.swift
//  bazaar


import Foundation
import CoreData


extension GeneralItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GeneralItem> {
        return NSFetchRequest<GeneralItem>(entityName: "GeneralItem")
    }

    @NSManaged public var name: String
    @NSManaged public var value: Double
    @NSManaged public var symbol: String
    @NSManaged public var type: String

}

extension GeneralItem : Identifiable {

}
