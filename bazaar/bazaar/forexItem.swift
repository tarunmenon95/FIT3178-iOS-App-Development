//  forexItem.swift
//  bazaar


import UIKit

//Class for forexItem
class forexItem: NSObject {
    var descript : String
    var display : String
    var symbol: String
    
    init(newDesc: String, newDis:String, newSymb:String) {
        descript = newDesc
        display = newDis
        symbol = newSymb
    }
}
