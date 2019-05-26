//
//  CreateDrillViewController.swift
//  DrillBook+
//
//  Created by Kevin Ramsussen on 11/14/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class CreateDrillViewController: UIViewController, UITextFieldDelegate {

    let model = Model.sharedInstance
    var editMode: Int = 0
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var moveTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var LRTextField: UITextField!
    @IBOutlet weak var LRPosition: UISegmentedControl!
    @IBOutlet weak var LRSide: UISegmentedControl!
    @IBOutlet weak var LRYardLine: UISegmentedControl!
    
    @IBOutlet weak var BFTextField: UITextField!
    @IBOutlet weak var BFPosition: UISegmentedControl!
    @IBOutlet weak var BFSide: UISegmentedControl!
    @IBOutlet weak var BFLine: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNumberLabel.text = "Set \(model.currentDrillSet)"
        if model.checkForDrill(index: model.showIndex) && model.currentDrillSet != model.numberOfDrillSets(){
            let horizontal = model.horizontal(drillIndex: model.currentDrillSet)
            let vertical = model.vertical(drillIndex: model.currentDrillSet)
            moveTextField.text = "\(model.move(drillIndex: model.currentDrillSet))"
            
            LRPosition.selectedSegmentIndex = horizontal.location
            LRSide.selectedSegmentIndex = horizontal.side
            LRYardLine.selectedSegmentIndex = horizontal.line
            LRTextField.text = "\(horizontal.steps)"
            
            BFPosition.selectedSegmentIndex = vertical.location
            BFSide.selectedSegmentIndex = vertical.side
            BFLine.selectedSegmentIndex = vertical.line
            BFTextField.text = "\(vertical.steps)"
            
            editMode = 1
            addButton.isEnabled = false
            addButton.alpha = 0.5
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(BFTextField!.endEditing(_:))))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkYardLine(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 10{
            LRPosition.isEnabled = false
            LRSide.insertSegment(withTitle: "On", at: 2, animated: true)
        }
        else{
            LRPosition.isEnabled = true
            if LRSide.numberOfSegments == 3{
            LRSide.removeSegment(at: 2, animated: true)
            }
        }
    }
    
    @IBAction func doneAction(_ sender: Any) {
        if editMode == 1{
            if checkForErrors(){
            createDrill()
            dismiss(animated: true, completion: nil)
            }
        }
        else{
            model.currentDrillSet -= 1
            model.notificationCheck = false
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func addDrill(_ sender: UIButton) {
        if checkForErrors(){
        createDrill()
        let setNumber = model.numberOfDrillSets()
        model.currentDrillSet = setNumber
        setNumberLabel.text = "Set \(setNumber)"
        moveTextField.text = nil
        LRTextField.text = nil
        BFTextField.text = nil
        }
    }
    
    func checkForErrors()->Bool{
        if moveTextField.text == "" || moveTextField.text == nil {
            let alertView = UIAlertController(title: "Error", message: "Move count needs to be entered", preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertView.addAction(actionCancel)
            self.present(alertView, animated: true, completion: nil)
            return false
        }
        if LRPosition.selectedSegmentIndex != 1 || (LRYardLine.selectedSegmentIndex == 10 && LRSide.selectedSegmentIndex != 2){
            if LRTextField.text == "" || LRTextField == nil{
                let alertView = UIAlertController(title: "Error", message: "Left-Right steps need to be entered.", preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                alertView.addAction(actionCancel)
                self.present(alertView, animated: true, completion: nil)
                return false
            }
            else if Double(LRTextField.text!)! > 4.0 || Double(LRTextField.text!)! == 0{
                let alertView = UIAlertController(title: "Error", message: "Left-Right steps must be less than 4 and greater than 0.", preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                alertView.addAction(actionCancel)
                self.present(alertView, animated: true, completion: nil)
                return false
            }
        }
        if BFPosition.selectedSegmentIndex != 1 {
            if BFTextField.text == "" || BFTextField == nil{
                let alertView = UIAlertController(title: "Error", message: "Back-Front steps need to be entered.", preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: "Okay", style: .cancel, handler:nil)
                alertView.addAction(actionCancel)
                self.present(alertView, animated: true, completion: nil)
                return false
            }
            else if Double(BFTextField.text!)! > 16.0 || Double(BFTextField.text!)! == 0{
                let alertView = UIAlertController(title: "Error", message: "Back-Front steps must be less than 16 and greater than 0.", preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                alertView.addAction(actionCancel)
                self.present(alertView, animated: true, completion: nil)
                return false
            }
        }
        return true
        
    }
    
    func createDrill(){
        
        let moveCount = Int(moveTextField.text!)!
        
        let LRPositionTitle = LRPosition.titleForSegment(at: LRPosition.selectedSegmentIndex)!
        let LRYardLineTitle = LRYardLine.titleForSegment(at: LRYardLine.selectedSegmentIndex)!
        let LRSideTitle = LRSide.titleForSegment(at: LRSide.selectedSegmentIndex)!
        
        let BFPositionTitle = BFPosition.titleForSegment(at: BFPosition.selectedSegmentIndex)!
        let BFLineTitle = BFLine.titleForSegment(at: BFLine.selectedSegmentIndex)!
        let BFSideTitle = BFSide.titleForSegment(at: BFSide.selectedSegmentIndex)!
        var horizontalText = ""
        var verticalText = ""
        var horizontal = Position()
        var vertical = Position()
        let stepSize = 1.875// in feet
        
        if LRPosition.selectedSegmentIndex == 1 {
            horizontalText = "On "
            if LRYardLineTitle == "50"{
                horizontalText = horizontalText + "50 yd ln"
            }
            else{
                horizontalText = horizontalText + LRSideTitle + " " + LRYardLineTitle + " yd ln"
            }
        }
        else{
            horizontal.steps = Double(LRTextField.text!)!
            horizontalText = LRTextField.text! + " stps "
            if LRYardLineTitle == "50"{
                if LRSideTitle == "On"{
                    horizontalText = LRSideTitle + " 50 yd ln"
                }
                else{
                horizontalText = horizontalText + LRSideTitle + " of 50 yd ln"
                }
            }
            else{
                horizontalText = horizontalText + LRPositionTitle + " " + LRSideTitle + " " + LRYardLineTitle + " yd ln"
            }
        }
        
        horizontal.line = LRYardLine.selectedSegmentIndex
        horizontal.location = LRPosition.selectedSegmentIndex
        horizontal.side = LRSide.selectedSegmentIndex
        horizontal.text = horizontalText
        
        var xPosition = 0.0
        if horizontal.line < 10{
            xPosition = Double(horizontal.line * 15)
            if horizontal.side == 1{
                xPosition = Double(300 - horizontal.line * 15)
            }
        }
        else{
            xPosition = 150.0
        }
        
        let xStepSize = stepSize * horizontal.steps
        
        if (horizontal.location == 0 && horizontal.side == 0)||(horizontal.location == 2 && horizontal.side == 1){
            xPosition += xStepSize
        }
        else if (horizontal.location == 2 && horizontal.side == 0)||(horizontal.location == 0 && horizontal.side == 1){
            xPosition -= xStepSize
        }
        horizontal.distance = xPosition
        
        if BFPosition.selectedSegmentIndex == 1 {
            verticalText = "On "
            verticalText = verticalText + " " + BFSideTitle + " " + BFLineTitle
        }
        else{
            vertical.steps = Double(BFTextField.text!)!
            verticalText = BFTextField.text! + " stps "
            if BFPositionTitle == "In Front"{
                verticalText = verticalText + BFPositionTitle + " of " + BFSideTitle + " " + BFLineTitle
            }
            else{
                verticalText = verticalText + BFPositionTitle + " " + BFSideTitle + " " + BFLineTitle
            }
        }
        
        vertical.line = BFLine.selectedSegmentIndex
        vertical.location = BFPosition.selectedSegmentIndex
        vertical.side = BFSide.selectedSegmentIndex
        vertical.text = verticalText
        
        var yPosition = 0.0
        var hashLine = 0.0
        if model.currentField() == "College"{
            hashLine = 60.0
        }
        else{
            hashLine = 53.333
        }
        if vertical.line == 1 && vertical.side == 0{
            yPosition = 160.0
        }
        else if vertical.line == 1 && vertical.side == 1{
            yPosition = 0.0
        }
        else if vertical.line == 0 && vertical.side == 0{
            yPosition = 160.0 - hashLine
        }
        else{
            yPosition = hashLine
        }
        
        if vertical.location == 0{
            yPosition += vertical.steps * stepSize
        }
        else if vertical.location == 2{
            yPosition -= vertical.steps * stepSize
        }
        vertical.distance = yPosition
        
        if editMode == 0{
            model.createNewDrill(move: moveCount, horizontal: horizontal, vertical: vertical)
        }
        else{
            model.editDrill(move: moveCount, horizontal: horizontal, vertical: vertical)
        }
        model.notificationCheck = true
    }
    
    

    @objc func keyboardWillShow(notification:Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: (CGFloat(50.0)+(keyboardSize?.height)!), right: 0)
        scrollView.contentInset = contentInsets
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if !editing{
            if BFTextField.isFirstResponder{
                BFTextField.resignFirstResponder()
            }
            else if LRTextField.isFirstResponder{
            LRTextField.resignFirstResponder()
            }
            else if moveTextField.isFirstResponder{
            moveTextField.resignFirstResponder()
            }
        }
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
