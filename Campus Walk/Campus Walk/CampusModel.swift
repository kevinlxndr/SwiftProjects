//
//  CampusModel.swift
//  Campus Walk
//
//  Created by Kevin Ramsussen on 10/13/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import Foundation
import MapKit

struct Building: Codable {
    var name : String
    var opp_bldg_code : Int
    var year_constructed :Int
    var latitude : Double
    var longitude : Double
    var photo : String
}

typealias Buildings = [Building]

class Model {
    
    static let sharedInstance = Model()
    let allBuildings : Buildings
    var buildings : Buildings
    var buildingNames : [String] = []
    var initials : [String] = []
    var buildingInitials : [String :[Building]] = [:]
    var favoriteAnnotations : [MKAnnotation] = []
    var currentNormalAnnotation : MKAnnotation?
    var screenSize : CGSize = CGSize()
    var Favorites : [String:Bool] = [:]
    var changePin = false 

    let initialLocation = CLLocation(latitude: 40.794978, longitude: -77.860785)
    let spanDelta = 0.01
    let zoomDelta = 0.0075
    var numberOfBuildings : Int
    var numberOfInitials : Int
    var selectedBuildingIndexPath : IndexPath?
    var showFavorites = false
    
    var currentTablePurpose = "Map"
    var currentDirectionChange = 1
    var Direction1 = "User Location"
    var Direction2 = "User Location"
    var setDirections = false
    var routeSteps : [MKRouteStep] = []
    var routeETA : String?
    var currentOverlay : MKPolyline?
    var currentDirectionStep = 0
    
    var pictures : [String:UIImage] = [:]
    var information : [String:String] = [:]
    
    init(){
        let mainBundle = Bundle.main
        let contentURL = mainBundle.url(forResource: "buildings", withExtension: "plist")
        
        do {
            let data = try Data(contentsOf: contentURL!)
            let decoder = PropertyListDecoder()
            allBuildings = try decoder.decode(Buildings.self, from: data)
            
            for building in allBuildings{
                buildingNames.append(building.name)
                Favorites[building.name] = false
            }
            buildingNames = buildingNames.sorted()
            
            for building in buildingNames{
                let initial = String(building[building.startIndex])
                 let temp = allBuildings.first(where: {$0.name == building})!
                if buildingInitials[initial]?.append(temp) == nil{
                    buildingInitials[initial] = [temp]
                }
               
            }
            buildings = allBuildings
            initials = buildingInitials.keys.sorted()
            
            numberOfInitials = initials.count
            numberOfBuildings = buildingNames.count
        } catch {
            print(error)
            allBuildings = []
            buildings = []
            numberOfBuildings = 0
            numberOfInitials = 0
        }

    }
    
    func numberOfBuildings(at index: Int) -> Int{
        let initial = initials[index]
        return buildingInitials[initial]!.count
    }
    
    func building(at indexPath:IndexPath)-> Building{
        let key = initials[indexPath.section]
        let buildings = buildingInitials[key]!
        let theBuilding = buildings[indexPath.row]
        return theBuilding
    }
    
    func buildingName(at indexPath:IndexPath) -> String {
        let theBuilding = building(at: indexPath)
        return theBuilding.name
    }
    
    func buildingLatitude(at indexPath:IndexPath) -> Double {
        let theBuilding = building(at: indexPath)
        return theBuilding.latitude
    }
    
    func buildingLongitude(at indexPath:IndexPath) -> Double {
        let theBuilding = building(at: indexPath)
        return theBuilding.longitude
    }
    func isBuildingFavorited(indexPath:IndexPath) -> Bool{
        let theBuilding = building(at: indexPath)
        return Favorites[theBuilding.name]!
    }
    func invertFavorite(indexPath: IndexPath){
        let theBuilding = building(at: indexPath)
        Favorites[theBuilding.name]! = !Favorites[theBuilding.name]!
    }
    
    func favoritedBuildings() -> [Building] {
        var buildings : [Building] = []
        for i in 0..<buildingNames.count{
            let name = buildingNames[i]
            let favorited = Favorites[name]
            if favorited!{
                let newBuilding = building(named: name)
                buildings.append(newBuilding)
            }
        }
        return buildings
    }
    
    func building(named name:String)->Building{
        let key = String(name[name.startIndex])
        let buildingList = buildingInitials[key]
        return (buildingList?.first(where:{ $0.name == name}))!

    }
    
    func imageName(at name:String)->String{
        let tempBuilding = building(named: name)
        if tempBuilding.photo != ""{
            return tempBuilding.photo
        }
        else{
            return "NoBuilding"
        }
    }
    
    func image(at name:String)->UIImage{
        return pictures[name]!
    }
    
    func populateInfo(){
        for buildingName in buildingNames{
            pictures[buildingName] = UIImage(named: imageName(at: buildingName))
            information[buildingName] = "Add Information Here."
        }
    }
    func currentETA(time:TimeInterval)-> String?{
       
            let timeFormatter = DateComponentsFormatter()
            timeFormatter.unitsStyle = .abbreviated
            timeFormatter.allowedUnits = [.minute, .second]
            timeFormatter.zeroFormattingBehavior = .pad
            let convertedTime = timeFormatter.string(from: time)!
        
            routeETA = convertedTime
            return convertedTime
        
    }
    
    func changeImage(at name: String, to newImage: UIImage){
        pictures[name] = newImage
    }
    func changeInformation(at name: String, to newInfo: String){
        if newInfo != ""{
            information[name] = newInfo
        }
        else{
            information[name] = "Add Information Here"
        }
    }
    
    func updateFilter(filter: String){
      //  buildingInitials.filter({$0.value.contains(where:{$0.name.contains(filter) || $0.year_constructed.description.contains(filter)})})
        if filter == ""{
            buildings = allBuildings.filter({(building:Building) in true})
        }
        else{
            buildings = allBuildings.filter({$0.name.contains(filter) || ($0.year_constructed.description.contains(filter) && $0.year_constructed != 0)})
        }
        buildingNames = []
        buildingInitials = [:]
        
        for building in buildings{
            buildingNames.append(building.name)
            let initial = String(building.name[building.name.startIndex])
            let temp = buildings.first(where: {$0.name == building.name})!
            if buildingInitials[initial]?.append(temp) == nil{
                buildingInitials[initial] = [temp]
            }
            
        }
        buildingNames = buildingNames.sorted()
        initials = buildingInitials.keys.sorted()
        
        numberOfInitials = initials.count
        numberOfBuildings = buildingNames.count
        
    }
}
