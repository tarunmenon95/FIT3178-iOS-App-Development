//  generalisedItem.swift
//  bazaar


import UIKit

//Class for GeneralisedItem, used to store Stocks, Cryptos, Currencies
class GeneralisedItem: NSObject {

    var name: String
    var value: Double
    var type: String
    var symbol: String
    
    init(newName: String, newValue: Double, newType: String, newSymbol:String) {
        self.name = newName
        self.value = newValue
        self.symbol = newSymbol
        self.type = newType
    }
}
