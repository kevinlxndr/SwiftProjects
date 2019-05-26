//
//  ViewController.swift
//  Pentominoes
//
//  Created by Kevin Ramsussen on 9/8/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate, HintDelegate {
    func dismissMe() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var boardButtons: [UIButton]!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!
    
    @IBOutlet weak var boardImageView: UIImageView!
    @IBOutlet weak var boardView: UIView!
    @IBOutlet weak var pieceStorage: UIView!
    @IBOutlet var mainView: UIView!
    
    var imageViewArray : [UIView] = []
    let model = Model()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      
        super.viewDidLoad()
        self.view.bringSubview(toFront: boardView)
        
        for shape in model.shapeArray{
            let shapeName = shape.shapeName
            let shapeView = UIImageView(image: UIImage(named:shapeName))
            shapeView.layer.shadowColor = UIColor.black.cgColor
            shapeView.layer.shadowOpacity = 0.0
            shapeView.layer.masksToBounds = true
            shapeView.layer.shadowRadius = 1
            shapeView.layer.shadowOffset = CGSize(width: -5, height: -5)
            pieceStorage.addSubview(shapeView)
        
            let doubleTapGesture = UITapGestureRecognizer(target: self,action: #selector(ViewController.flipShape(_:)))
            doubleTapGesture.numberOfTapsRequired = 2
            shapeView.addGestureRecognizer(doubleTapGesture)
            
            let tapGesture = UITapGestureRecognizer(target: self,action: #selector(ViewController.rotateShape(_:)))
            shapeView.addGestureRecognizer(tapGesture)
            tapGesture.require(toFail: doubleTapGesture)
            
            let panGesture = UIPanGestureRecognizer(target: self,action: #selector(ViewController.moveShape(_:)))
            shapeView.addGestureRecognizer(panGesture)
            shapeView.isUserInteractionEnabled = true
        	
        imageViewArray.append(shapeView)
        }
        
    boardView.isUserInteractionEnabled = true
    adjustShapes()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        adjustShapes()
    }
    
    @objc func moveShape(_ sender:UIPanGestureRecognizer){
        let shape = sender.view!
        let shapeIndex = imageViewArray.index(of: shape)!
        var shapeStored = model.shapeArray[shapeIndex]
        let currentPosition = shape.frame
        let boardPosition = boardView.convert(currentPosition,from: shape.superview)
        
       // let originalTransform = shape.transform
        switch sender.state{
        case .began:
            
            boardView.addSubview(shape)
            mainView.bringSubview(toFront:boardView)
            shape.frame.origin = boardPosition.origin
            shape.transform = shape.transform.scaledBy(x:1.25, y:1.25)
            shape.layer.masksToBounds = false
            shape.layer.shadowOpacity = 0.5
            self.view.bringSubview(toFront:imageViewArray[shapeIndex])
        case .changed:
            let translation = sender.translation(in: self.view)
            shape.frame.origin.x += translation.x
            shape.frame.origin.y += translation.y
            sender.setTranslation(CGPoint.zero, in: self.view)
            shapeStored.currentPosition.x = Int(shape.frame.origin.x)
            shapeStored.currentPosition.y = Int(shape.frame.origin.y)
            
        case .ended:
            shape.layer.masksToBounds = true
            shape.layer.shadowOpacity = 0.0
            if boardView.frame.contains(sender.location(in: mainView)) == true {
                let newPoint = roundingForBoard(shape.frame.origin)
                
                UIView.animate(withDuration: 0.2, delay:0.1, animations:{
                     shape.transform = shape.transform.scaledBy(x: 0.8, y: 0.8)
                    shape.frame.origin = newPoint
                },completion: {finished in
                shapeStored.currentPosition.x = Int(newPoint.x)
                shapeStored.currentPosition.y = Int(newPoint.y)
                self.model.piecesOnBoard = true
                
                })
                model.updateShapeArray(shapeIndex, Int(newPoint.x), Int(newPoint.y), shapeStored.currentPosition.rotations, shapeStored.currentPosition.isFlipped)
            }
            else{
                self.view.bringSubview(toFront:imageViewArray[shapeIndex])
                let currentPosition = shape.frame
                let boardPosition = pieceStorage.convert(currentPosition,from: shape.superview)
                let newX = shapeStored.originalPosition.x
                let newY = shapeStored.originalPosition.y
                
                shape.frame.origin = boardPosition.origin
                	444
                shapeStored.currentPosition.x = newX
                shapeStored.currentPosition.y = newY
                shapeStored.currentPosition.rotations = 0
                shapeStored.currentPosition.isFlipped = false
                
                model.updateShapeArray(shapeIndex, Int(newX), Int(newY), shapeStored.currentPosition.rotations, shapeStored.currentPosition.isFlipped)
                
              pieceStorage.addSubview(imageViewArray[shapeIndex])
                
            }
            
        case .possible:
            break
        case .cancelled:
            break
        case .failed:
            break
        }
    }

    @objc func rotateShape(_ sender:UITapGestureRecognizer){
        let shape = sender.view!
        let shapeIndex = imageViewArray.index(of: shape)!
        var shapeStored = model.shapeArray[shapeIndex]
        let frameStore  = shape.frame.origin
        if shape.superview! == boardView{
        UIView.animate(withDuration: 0.2, delay:0.1, animations:{
            self.imageViewArray[shapeIndex].transform = self.imageViewArray[shapeIndex].transform.rotated(by: CGFloat.pi / 2.0 )
            if ((Int(self.imageViewArray[shapeIndex].frame.origin.x) % 30 != 0 ) || (Int(self.imageViewArray[shapeIndex].frame.origin.y) % 30 != 0)){
                self.imageViewArray[shapeIndex].frame.origin = frameStore
            }
        })
            if shapeStored.currentPosition.isFlipped{
              shapeStored.currentPosition.rotations = shapeStored.currentPosition.rotations - 1
            }
            else{
                shapeStored.currentPosition.rotations = shapeStored.currentPosition.rotations + 1
            }
        if shapeStored.currentPosition.rotations == 4{
            shapeStored.currentPosition.rotations = 0
        }
        if shapeStored.currentPosition.rotations == -1{
            shapeStored.currentPosition.rotations = 3
        }
        model.updateShapeArray(shapeIndex, Int(shape.frame.origin.x), Int(shape.frame.origin.y), shapeStored.currentPosition.rotations, shapeStored.currentPosition.isFlipped)
        }
        }
    
    @objc func flipShape(_ sender:UITapGestureRecognizer){
        let shape = sender.view!
        let shapeIndex = imageViewArray.index(of: shape)!
        var shapeStored = model.shapeArray[shapeIndex]
        if shape.superview! == boardView{
        UIView.animate(withDuration: 0.2, delay:0.1, animations:{
            self.imageViewArray[shapeIndex].transform = self.imageViewArray[shapeIndex].transform.scaledBy(x: -1.0, y: 1.0)
        })
        
            shapeStored.currentPosition.isFlipped = !shapeStored.currentPosition.isFlipped
        
        model.updateShapeArray(shapeIndex, Int(imageViewArray[shapeIndex].frame.origin.x), Int(imageViewArray[shapeIndex].frame.origin.y), shapeStored.currentPosition.rotations, shapeStored.currentPosition.isFlipped)
    }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setBoard(_ sender: UIButton) {
        if(sender.tag != model.currentButtonTag){
            model.hintCount = 0
        }
        boardImageView.image = sender.currentImage
        model.currentButtonTag = sender.tag
        if sender.tag == 0{
            hintButton.isEnabled = false
            hintButton.isHidden = true
        }
        else{
            hintButton.isEnabled = true
            hintButton.isHidden = false
        }
    }
    
    @IBAction func resetBoard(_ sender: Any) {
        
        if(model.piecesOnBoard == true){
        solveButton.isEnabled = true
        boardButtons.forEach { (button) in
            button.isEnabled = true
            }
            
        for i in 0...model.shapeArray.count-1{
            var shape = model.shapeArray[i]
            let newX = shape.originalPosition.x
            let newY = shape.originalPosition.y
            let currentPosition = imageViewArray[i].frame
            let boardPosition = pieceStorage.convert(currentPosition,from: imageViewArray[i].superview)
            
            
            mainView.bringSubview(toFront:pieceStorage)
            imageViewArray[i].frame.origin = boardPosition.origin
             pieceStorage.addSubview(imageViewArray[i])
            UIView.animate(withDuration: 1.0, delay:0.5, animations:{
                self.imageViewArray[i].transform = CGAffineTransform.identity
                self.imageViewArray[i].frame.origin.x = CGFloat(newX)
                self.imageViewArray[i].frame.origin.y = CGFloat(newY)
            })
            
            shape.currentPosition.x = newX
            shape.currentPosition.y = newY
            shape.currentPosition.rotations = 0
            shape.currentPosition.isFlipped = false
            
            model.updateShapeArray(i, Int(newX), Int(newY), 0, false)
            
            model.piecesOnBoard = false
            
        }
        }
    }
    
    @IBAction func solveBoard(_ sender: Any) {
        
        if(model.currentButtonTag != 0){
        solveButton.isEnabled = false
        model.piecesOnBoard = true
            boardButtons.forEach { (button) in
                button.isEnabled = false
            }
            
            mainView.bringSubview(toFront:boardView)
            
        for i in 0...model.shapeArray.count-1{
            let index = model.currentButtonTag-1
            var shape = model.shapeArray[i]
            let shapeLetter = shape.shapeLetter
            let newX = 30 * model.getXSolution(i: index,shapeLetter: shapeLetter)
            let newY = 30 * model.getYSolution(i: index,shapeLetter: shapeLetter)
            let rotations = model.getRotationSolution(i:index,shapeLetter:shapeLetter)
            let convertedRotation = CGFloat.pi * CGFloat(rotations) / 2.0
            let flipped = model.getFlippedSolution(i:index,shapeLetter:shapeLetter)
            let currentPosition = imageViewArray[i].frame
            let boardPosition = imageViewArray[i].superview!.convert(currentPosition,to: boardView)
            
            
            boardView.addSubview(imageViewArray[i])
            imageViewArray[i].frame.origin = boardPosition.origin

            UIView.animate(withDuration: 1, delay: 0.5,  animations:{
                self.imageViewArray[i].transform = CGAffineTransform.identity
                if flipped{
                self.imageViewArray[i].transform = CGAffineTransform.identity.rotated(by:convertedRotation).scaledBy(x:-1.0,y:1.0)
                }
                else{
                    self.imageViewArray[i].transform = CGAffineTransform.identity.rotated(by:convertedRotation).scaledBy(x:1.0,y:1.0)
                }
               
                self.imageViewArray[i].frame.origin.x = CGFloat(newX)
                self.imageViewArray[i].frame.origin.y = CGFloat(newY)


                })
            
            
            shape.currentPosition.x = newX
            shape.currentPosition.y = newY
            shape.currentPosition.rotations = rotations
            shape.currentPosition.isFlipped = flipped
            model.updateShapeArray(i, Int(newX), Int(newY), shape.currentPosition.rotations, shape.currentPosition.isFlipped)

        }
    }
    }
    
    func adjustShapes(){
        let xIncrement = pieceStorage.frame.width / 7
        var xPosition = Int(xIncrement) - 75
        var yPosition = 10
        
        for i in 0...model.numberOfShapes()-1{
            let shapeView = imageViewArray[i]
            model.shapeArray[i].originalPosition.x = xPosition
            model.shapeArray[i].originalPosition.y = yPosition
            if shapeView.superview != boardView{
                shapeView.frame.origin = CGPoint(x: xPosition, y: yPosition)
                model.shapeArray[i].currentPosition.x = xPosition
                model.shapeArray[i].currentPosition.y = yPosition
            }
            
            xPosition += Int(xIncrement)
            
            if i == (model.numberOfShapes() - 1 ) / 2{
                xPosition = Int(xIncrement) - 75
                yPosition += 130
            }
    }
    }
    func roundingForBoard(_ originalPosition: CGPoint) -> CGPoint{
        let originalX = Int(originalPosition.x)
        let originalY = Int(originalPosition.y)
        let differenceX = originalX - (originalX % 30)
        let differenceY = originalY - (originalY % 30)
        let newPoint = CGPoint(x: differenceX, y: differenceY)
        return newPoint
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if model.hintCount != model.numberOfShapes(){
        model.hintCount += 1
        }
        let hintViewController = segue.destination as! hintViewController
        hintViewController.configure(with: model)
        hintViewController.delegate = self
        hintViewController.completionBlock = {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

