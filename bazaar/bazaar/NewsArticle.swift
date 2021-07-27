//  NewsArticle.swift
//  bazaar


import UIKit

//Class for NewsArticle object
class NewsArticle: NSObject {
    
    var title : String
    var descript : String?
    var imageUrl : String?
    var url: String
    
    init(newTitle:String, newDescript:String?, newImageUrl:String?, newUrl:String) {
        title = newTitle
        descript = newDescript
        imageUrl = newImageUrl
        url = newUrl
    }
}
