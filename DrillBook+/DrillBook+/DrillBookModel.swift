//
//  DrillBookModel.swift
//  DrillBook+
//
//  Created by Kevin Ramsussen on 11/11/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import Foundation
import MapKit
import UserNotifications

struct DrillCoordinate:Codable{
    var setNumber:Int
    var moveCount:Int
    var horizontal: Position
    var vertical: Position
   // var countToNext:Int
   // var tempo:Int
    var notes: String
}

struct Position:Codable{
    var text: String
    var steps: Double
    var line: Int
    var location: Int
    var side: Int
    var distance: Double
    init() {
        text = ""
        steps = 0.0
        line = 0
        location = 0
        side = 0
        distance = 0.0
    }
}

struct Field:Codable{
    var fieldName:String
    var fieldType:String
    var latitude:Double
    var longitude:Double
}

struct Show:Codable{
    var showName:String
    var fieldType:String
    var fieldName:String
    var coordinates:[DrillCoordinate]
}

typealias DrillCoordinates = [DrillCoordinate]
typealias Shows = [Show]
typealias Fields = [Field]

class Model{
    var allShows : Shows
    var allFields : Fields
    let showURL : URL
    let fieldURL : URL
    let notificationID = "DrillSet"
    static let sharedInstance = Model()
    static let sharedLocationManager = CLLocationManager()
    var currentShow : String = ""
    var currentDrillSet : Int = 0
    var showIndex:Int{ return findShow(title: currentShow)}
    var notificationCheck = true
    
    fileprivate init(){
        let fileManager = FileManager.default
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var destinationURL = documentURL.appendingPathComponent("DrillCoordinates.archive")
        showURL = destinationURL
        var fileExists = fileManager.fileExists(atPath: destinationURL.path)
        if !fileExists{
            let mainBundle = Bundle.main
            let contentURL = mainBundle.url(forResource: "DrillCoordinates", withExtension: "plist")
            do {
                let data = try Data(contentsOf: contentURL!)
                let decoder = PropertyListDecoder()
                allShows = try decoder.decode(Shows.self, from: data)
            }
            catch {
                print(error)
                allShows = []
            }
        }
        else{
            do{
                let data = try Data(contentsOf: destinationURL)
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                allShows = unarchiver.decodeDecodable(Shows.self, forKey: NSKeyedArchiveRootObjectKey)!
            }
            catch{
                print("Error decoding archive")
                allShows = []
            }
        }
        
        destinationURL = documentURL.appendingPathComponent("FieldData.archive")
        fieldURL = destinationURL
        fileExists = fileManager.fileExists(atPath: destinationURL.path)
        if !fileExists{
            let mainBundle = Bundle.main
            let contentURL = mainBundle.url(forResource: "FieldData", withExtension: "plist")
            do {
                let data = try Data(contentsOf: contentURL!)
                let decoder = PropertyListDecoder()
                allFields = try decoder.decode(Fields.self, from: data)
            }
            catch {
                print(error)
                allFields = []
            }
        }
        else{
            do{
                let data = try Data(contentsOf: destinationURL)
                let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
                allFields = unarchiver.decodeDecodable(Fields.self, forKey: NSKeyedArchiveRootObjectKey)!
            }
            catch{
                print("Error decoding archive")
                allFields = []
            }
        }
    }
    
    func saveData(){
        
        var archiver = NSKeyedArchiver()
        do{
            try archiver.encodeEncodable(allShows, forKey: NSKeyedArchiveRootObjectKey)
            try archiver.encodedData.write(to: showURL)
        }
        catch{
            print("error archiving")
            
        }
        archiver = NSKeyedArchiver()
        if allFields.count != 0{
        do{
            try archiver.encodeEncodable(allFields, forKey: NSKeyedArchiveRootObjectKey)
            try archiver.encodedData.write(to: fieldURL)
        }
        catch{
            print("error archiving")
        }
        }
    }
    
    func createNewShow(title:String,field:String){
        let show = Show(showName: title, fieldType: field, fieldName: "", coordinates:[])
        allShows.append(show)
        saveData()
    }
    
    func createNewDrill(move:Int,horizontal:Position, vertical:Position){
        let showIndex = findShow(title: currentShow)
        let newDrill = DrillCoordinate(setNumber: allShows[showIndex].coordinates.count, moveCount: move, horizontal: horizontal, vertical: vertical, notes: "Enter Notes Here...")
        allShows[showIndex].coordinates.append(newDrill)
        saveData()
    }
    
    func editDrill(move:Int,horizontal:Position, vertical:Position){
        let showIndex = findShow(title: currentShow)
        let newDrill = DrillCoordinate(setNumber: currentDrillSet, moveCount: move, horizontal: horizontal, vertical: vertical, notes:allShows[showIndex].coordinates[currentDrillSet].notes)
        allShows[showIndex].coordinates[currentDrillSet] = newDrill
        saveData()
    }
    
    func findShow(title:String)-> Int{
        return allShows.index(where: {$0.showName == title})!
    }
    
    func getTotalCount(index:Int) -> Int{
        var total = 0
        for i in 0...index{
            let coordinate =  allShows[showIndex].coordinates[i]
            total += coordinate.moveCount
        }
        return total
    }
    
    func checkForCoordinates()->Bool{
        let show = allShows[showIndex]
        if allFields.index(where: {$0.fieldName == show.fieldName}) != nil{
            return true
        }
        else{
            return false
        }
    }
    
    func fieldCoordinates(fieldName:String)->CLLocationCoordinate2D{
        var coordinate = CLLocationCoordinate2D()
        let field = allFields.first(where: {$0.fieldName == fieldName})
        coordinate.latitude = field!.latitude
        coordinate.longitude = field!.longitude
        return coordinate
    }
    
    func checkForFieldName()->Bool{
        let show = allShows[showIndex]
        if show.fieldName != ""{
        return false
        }
        return true
    }
    
    func changeField(to index:Int){
        allShows[showIndex].fieldName = fieldName(at: index)
        allShows[showIndex].fieldType = allFields[index].fieldType
        saveData()
    }
    
    func updateVertical(_ vertical:Position){
        allShows[showIndex].coordinates[currentDrillSet].vertical = vertical
    }
    func updateNotes(_ notes:String){
        allShows[showIndex].coordinates[currentDrillSet].notes = notes
        saveData()
    }

    func scheduleNotification(inSeconds: TimeInterval, completion: @escaping (Bool) -> ()) {
        if currentShow != "" {
             UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            
            let notificationContent = UNMutableNotificationContent()
            let index = currentDrillSet
            notificationContent.title = "Drill Set \(currentDrillSet)"
            notificationContent.body = "Move: \(move(drillIndex:index))\nLeft-Right: \(horizontal(drillIndex: index).text)\nBack-Front:\(vertical(drillIndex: index).text)\nMove To Next Set: \(nextSetCount())"

            notificationContent.categoryIdentifier = "AdvanceDrill"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)

            let request = UNNotificationRequest(identifier: notificationID, content: notificationContent, trigger: trigger)

            // Add this notification to the UserNotificationCenter
           
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                if error != nil {
                    print(error!)
                    completion(false)
                } else {
                    completion(true)
                }
            })
            }
        
    }

    
    func addNewField(field:Field){
        allFields.append(field)
        saveData()
    }
    func fieldName(at index:Int) -> String{
        return allFields[index].fieldName
    }
    func currentFieldName() ->String{
        return allShows[showIndex].fieldName
    }
    func fieldType()->String{
        return allShows[showIndex].fieldType
    }

    func checkForDrill(index:Int) -> Bool{
        return !allShows[index].coordinates.isEmpty
    }
    
    func numberOfDrillSets()->Int{
        return allShows[showIndex].coordinates.count
    }
    
    func move(drillIndex:Int)->Int{
        return allShows[showIndex].coordinates[drillIndex].moveCount
    }
    func horizontal(drillIndex:Int)->Position{
        return allShows[showIndex].coordinates[drillIndex].horizontal
    }
    func vertical(drillIndex:Int)->Position{
        return allShows[showIndex].coordinates[drillIndex].vertical
    }
    func currentField()-> String{
        return allShows[showIndex].fieldType
    }
    func notes()->String{
        return allShows[showIndex].coordinates[currentDrillSet].notes
    }
    func nextSetCount()->Int{
        if currentDrillSet != numberOfDrillSets()-1{
            return allShows[showIndex].coordinates[currentDrillSet+1].moveCount
        }
        else{
            return 0
        }
    }
    
    
}
