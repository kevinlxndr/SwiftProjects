//
//  ParkModel.swift
//  Parks
//
//  Created by Kevin Ramsussen on 9/23/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import Foundation

struct Park : Codable {
    var name : String
    var photos : [Photo]
}
struct Photo : Codable {
    var imageName : String
    var caption : String
}

typealias Content = [Park]
typealias Contents = [Content]

class Model {
    
    static let sharedInstance = Model()
    let allContent : Content
    let totalParkCount : Int
    var currentPark = 0
    let labelHeight = 60
    var setup = false
    let numberWalkthroughImages = 3
    var parkNames : [String] = []
    var walkthroughImages : [String] = []

    init(){
        let mainBundle = Bundle.main
        let contentURL = mainBundle.url(forResource: "StateParks", withExtension: "plist")
        
        do {
            let data = try Data(contentsOf: contentURL!)
            let decoder = PropertyListDecoder()
            allContent = try decoder.decode(Content.self, from: data)
            
        } catch {
            print(error)
            allContent = []
        }
        totalParkCount = allContent.count
        
        for i in 1...numberWalkthroughImages{
            walkthroughImages.append("WalkthroughImage\(i)")
        }
        
        for park in allContent{
            parkNames.append(park.name)
        }
    }
    
    func parkImageCount(_ index:Int) ->Int{
        return allContent[index].photos.count
    }
    
    func parkName(_ index:Int) ->String{
        return allContent[index].name
    }
    func pictureCaption(_ index:IndexPath)->String{
        return allContent[index.section].photos[index.row].caption
    }
    func picture(_ index:IndexPath)->String{
        return allContent[index.section].photos[index.row].imageName
    }
    
    func walkthroughImage(_ index: Int) ->String{
        return walkthroughImages[index]
    }
   
    }

