//
//  Model.swift
//  Pentominoes
//
//  Created by John Hannan on 8/28/18.
//  Copyright (c) 2018 John Hannan. All rights reserved.
//

import Foundation

// identifies placement of a single pentomino on a board
struct Position : Codable {
    var x : Int
    var y : Int
    var isFlipped : Bool
    var rotations : Int
}

struct Shape : Codable{
    let shapeName : String
    let shapeLetter : String
    var originalPosition : Position
    var currentPosition : Position
}


// A solution is a dictionary mapping piece names ("T", "F", etc) to positions
// All solutions are read in and maintained in an array
typealias Solution = [String:Position]
typealias Solutions = [Solution]

class Model {
    var shapeArray : [Shape]
    var currentButtonTag = 0
    var piecesOnBoard = false
    var hintCount = 0
    
    let allSolutions : Solutions //[[String:[String:Int]]]
    
    init () {
        let mainBundle = Bundle.main
        let solutionURL = mainBundle.url(forResource: "Solutions", withExtension: "plist")
        
        do {
            let data = try Data(contentsOf: solutionURL!)
            let decoder = PropertyListDecoder()
            allSolutions = try decoder.decode(Solutions.self, from: data)
        } catch {
            print(error)
            allSolutions = []
        }
        let defaultPosition = Position(x:0,y:0,isFlipped:false,rotations:0)
        var _shapeArray = [Shape]()
        
        for shape in allSolutions[0]{
            _shapeArray.append(Shape(shapeName: "Piece\(shape.key)", shapeLetter: "\(shape.key)",originalPosition: defaultPosition, currentPosition: defaultPosition))
        }
        shapeArray = _shapeArray
    }

    func shapeName( index i :Int) -> String{
        return shapeArray[i].shapeName
    }
    
    func numberOfShapes() ->Int{
        return shapeArray.count
    }
    
    func getLetter( i: Int) -> String{
        return shapeArray[i].shapeLetter
    }
    func getYSolution(i: Int, shapeLetter: String ) ->Int{
        return allSolutions[i][shapeLetter]!.y
    }
    func getXSolution(i: Int, shapeLetter: String) ->Int{
        return allSolutions[i][shapeLetter]!.x
    }
    
    func getRotationSolution(i: Int, shapeLetter: String) -> Int{
        return allSolutions[i][shapeLetter]!.rotations
        
    }
    func getFlippedSolution(i: Int, shapeLetter: String) -> Bool{
        return allSolutions[i][shapeLetter]!.isFlipped
        
    }
    func getShapeStruct(_ name:String)-> Shape?{
        for item in shapeArray{
            if item.shapeName == name{
                return item
            }
        }
        return nil
    }

    func updateShapeArray(_ shapeIndex : Int,_ newX : Int,_ newY : Int, _ newRotations : Int,_ newFlip: Bool){
        shapeArray[shapeIndex].currentPosition.x = newX
        shapeArray[shapeIndex].currentPosition.y = newY
        shapeArray[shapeIndex].currentPosition.rotations = newRotations
        shapeArray[shapeIndex].currentPosition.isFlipped = newFlip
        
    }
    
}
