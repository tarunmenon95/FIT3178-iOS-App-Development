//  Stock.swift
//  bazaar


import UIKit

//Class for stock item

class Stock: NSObject {

    var name: String
    var descript: String
    
    init(newName: String, newDescript:String) {
        self.name = newName
        self.descript = newDescript
    }
}
