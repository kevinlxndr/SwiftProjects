//
//  hintViewController.swift
//  Pentominoes
//
//  Created by Kevin Ramsussen on 9/17/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import Foundation

import UIKit

protocol HintDelegate : class {
    func dismissMe()
}

class hintViewController: UIViewController{
    
    @IBOutlet weak var hintBoard : UIImageView!
    
    weak var delegate : HintDelegate?
    var completionBlock : (() -> Void)?
    
    var model : Model!
    var currentBoardId:Int?
    //ADD HINTCOUNT TO  MODEL ADD FORLOOP FOR PIECE DISPLAY
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    override func viewDidLoad(){
        super.viewDidLoad()
        let currentBoardId = model.currentButtonTag
        hintBoard.image = UIImage(named:"Board\(currentBoardId)button.png")
        
        for i in 0...(model.hintCount - 1){
            let shape = model.shapeArray[i]
            let shapeLetter = shape.shapeLetter
            let newX = 30 * model.getXSolution(i: currentBoardId - 1,shapeLetter: shapeLetter)
            let newY = 30 * model.getYSolution(i: currentBoardId - 1,shapeLetter: shapeLetter)
            let rotations = model.getRotationSolution(i:currentBoardId - 1,shapeLetter:shapeLetter)
            let convertedRotation = CGFloat.pi * CGFloat(rotations) / 2.0
            let flipped = model.getFlippedSolution(i:currentBoardId - 1,shapeLetter:shapeLetter)
            
            let shapeName = shape.shapeName
            let shapeView = UIImageView(image: UIImage(named:shapeName))
            hintBoard.addSubview(shapeView)
            if flipped{
                shapeView.transform = CGAffineTransform.identity.rotated(by:convertedRotation).scaledBy(x:-1.0,y:1.0)
            }
            else{
                shapeView.transform = CGAffineTransform.identity.rotated(by:convertedRotation).scaledBy(x:1.0,y:1.0)
            }
            shapeView.frame.origin.x = CGFloat(newX)
            shapeView.frame.origin.y = CGFloat(newY)
        }
    }
    
   
    
    func configure(with model:Model){
        self.model = model
            }
    @IBAction func dismissByDelegate(_ sender: Any) {
        delegate?.dismissMe()
    }
    
}
