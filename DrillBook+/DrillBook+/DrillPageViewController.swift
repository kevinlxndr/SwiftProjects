//
//  DrillPageViewController.swift
//  DrillBook+
//
//  Created by Kevin Ramsussen on 11/15/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit
import UserNotifications
import MapKit
import AVFoundation

class DrillPageViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, CLLocationManagerDelegate {

    let model = Model.sharedInstance
    var locationManager = Model.sharedLocationManager
    var metronomeTimer = Timer()
    var metronomeIsOn = false
    var metronomeSoundPlayer : AVAudioPlayer?
    
    @IBOutlet weak var drillScrollView: UIScrollView!
    @IBOutlet weak var setTitle: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var moveLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var nextMoveLabel: UILabel!
    @IBOutlet weak var horizontalLabel: UILabel!
    @IBOutlet weak var verticalLabel: UILabel!
    @IBOutlet weak var drillNumberTextField: UITextField!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var fieldImageView: UIImageView!
    @IBOutlet weak var tempoTextField: UITextField!
    @IBOutlet weak var toggleMetronomeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drillScrollView.delegate = self
        drillScrollView.contentSize = self.view.bounds.size
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        model.notificationCheck = true
        
        let soundURL =  Bundle.main.url(forResource: "metronomeSound", withExtension: ".mp3")
        do{
            metronomeSoundPlayer = try AVAudioPlayer(contentsOf: soundURL!)
        }
        catch{
            print(error)
            metronomeSoundPlayer = nil
        }
    }
    override func viewDidAppear(_ animated: Bool) {

        checkButtons()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidLayoutSubviews), name: NSNotification.Name("Trigger"), object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(drillNumberTextField!.endEditing(_:))))
    }
    override func viewDidLayoutSubviews() {
                loadInfo(index: model.currentDrillSet)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
  @objc func loadInfo(index:Int){
        setTitle.title = "Set \(model.currentDrillSet)"
        moveLabel.text = "Move: \(model.move(drillIndex:index))"
        countLabel.text = "Count: \(model.getTotalCount(index: index))"
        horizontalLabel.text = model.horizontal(drillIndex: index).text
        verticalLabel.text = model.vertical(drillIndex: index).text
        nextMoveLabel.text = "Move To Next Set: \(model.nextSetCount())"
        fieldImageView.image = UIImage(named: model.fieldType())
        checkButtons()
        addPoint()
    if model.notificationCheck{
       sendNotification()
        model.notificationCheck = false
    }
    }
    //8to5 8 to 15
    func addPoint(){
        clearField()
        let stepSize = 1.875
        let horizontalMult = fieldImageView.frame.width / 300.00
        let horizontal = model.horizontal(drillIndex: model.currentDrillSet)
        
        let verticalMult = fieldImageView.frame.height / 160.00
        var vertical = model.vertical(drillIndex: model.currentDrillSet)
        
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
        model.updateVertical(vertical)
        
        let size = fieldImageView.frame.width / 40.0
        let temp = CGRect(x: 0, y: 0, width: size, height: size)
        let person = UIImageView.init(frame: temp)
        person.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "redcircle")
        person.image = image
        fieldImageView.addSubview(person)
        person.center = CGPoint(x: CGFloat(horizontal.distance) * horizontalMult, y: CGFloat(vertical.distance) * verticalMult)
    }

    @IBAction func checkCorrect(){
        //SOH CAH TOA
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined, .denied:
                locationManager.requestWhenInUseAuthorization()
            default:
                break
            }
        }
        
        locationManager.startUpdatingLocation()

        if model.checkForCoordinates(){
        let horizontal = model.horizontal(drillIndex: model.currentDrillSet)
        let vertical = model.vertical(drillIndex: model.currentDrillSet)
        let angle = atan((horizontal.distance+1)/(vertical.distance+1))
        let fieldCoordinate = model.fieldCoordinates(fieldName:model.currentFieldName())
        let fieldLocation = CLLocation(latitude: fieldCoordinate.latitude, longitude: fieldCoordinate.longitude)

        let userCoordinate = locationManager.location!
        let hypotenuse = fieldLocation.distance(from: userCoordinate) * 3.281
        let horizontalDistance = horizontal.distance
        let verticalDistance = 160 - vertical.distance
        let trueHorizontal = sin(angle) * hypotenuse
        let trueVertical = cos(angle) * hypotenuse
        let horizontalDifference = horizontalDistance - trueHorizontal + 1
        let verticalDifference = verticalDistance - trueVertical + 1
        
        locationManager.stopUpdatingLocation()
            
        if horizontalDifference <= 0.5 && horizontalDifference >= -0.5 && verticalDifference <= 0.5 && verticalDifference >= -0.5{
            let alertView = UIAlertController(title: "Correct!", message: nil, preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertView.addAction(actionCancel)
            self.present(alertView, animated: true, completion: nil)
        }
        else{
            let alertView = UIAlertController(title: "Incorrect!", message: "You are off by \(-horizontalDifference) ft horizontally and \(-verticalDifference) ft vertically." , preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertView.addAction(actionCancel)
            self.present(alertView, animated: true, completion: nil)
            }
        }
        else{
            let alertView = UIAlertController(title: "Field Needed", message: "Please assign a field to use this feature.", preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertView.addAction(actionCancel)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    func clearField(){
        for subview in fieldImageView.subviews{
            subview.removeFromSuperview()
        }
    }
    
    @IBAction func prevDrillSet(_ sender: Any) {
        if model.currentDrillSet != 0{
            model.currentDrillSet -= 1
        }
        checkButtons()
        loadInfo(index:model.currentDrillSet)
         model.notificationCheck = true
    }
    
    @IBAction func nextDrillSet(_ sender: Any) {
        if model.currentDrillSet < model.numberOfDrillSets()-1 {
             model.currentDrillSet += 1
        }
        checkButtons()
        loadInfo(index:model.currentDrillSet)
         model.notificationCheck = true
    }
    @IBAction func snapToDrill(_ sender: Any) {
        
        if let number = Int(drillNumberTextField.text!){
            if number < model.numberOfDrillSets(){
                model.currentDrillSet = number
                loadInfo(index: number)
                model.notificationCheck = true
                checkButtons()
            }
            else{
            let alertView = UIAlertController(title: "Error", message: "No drill set \(number) exists.", preferredStyle: .alert)
            
            let actionCancel = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertView.addAction(actionCancel)
                self.present(alertView, animated: true, completion: nil)
            }
           drillNumberTextField.text = ""
            drillNumberTextField.resignFirstResponder()
        }
    }
    
    @IBAction func toggleMetronome(_ sender: UIButton){
        if metronomeIsOn {
            metronomeIsOn = false
            metronomeTimer.invalidate()
            toggleMetronomeButton.setTitle("Start", for: .normal)
            tempoTextField.isEnabled = true
        }
        else {
            metronomeIsOn = true
            let tempo = Double(tempoTextField.text!)!
            let metronomeTimeInterval:TimeInterval = 60.0 / tempo
                        metronomeTimer = Timer.scheduledTimer(timeInterval: metronomeTimeInterval, target: self, selector: #selector(playSound), userInfo: nil, repeats: true)
            metronomeTimer.fire()
            toggleMetronomeButton.setTitle("Stop",for:.normal)
            tempoTextField.resignFirstResponder()
            tempoTextField.isEnabled = false
        }
    }
    
  @objc func playSound() {
        metronomeSoundPlayer?.play()
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        model.currentShow = ""
        model.currentDrillSet = 0
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        dismiss(animated: true, completion: nil)
    }
    
    func checkButtons(){
        if model.currentDrillSet != model.numberOfDrillSets()-1{
            nextButton.isEnabled = true
            nextButton.alpha = 1.0
        }
        else{
            nextButton.isEnabled = false
            nextButton.alpha = 0.5
        }
        if model.currentDrillSet != 0{
            prevButton.isEnabled = true
            prevButton.alpha = 1.0
        }
        else{
            prevButton.isEnabled = false
            prevButton.alpha = 0.5
        }
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: (CGFloat(50.0)+(keyboardSize?.height)!), right: 0)
        drillScrollView.contentInset = contentInsets
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if !editing{
            drillNumberTextField?.resignFirstResponder()
        }
    }
    
    @objc
    func keyboardWillHide(notification:Notification) {
        drillScrollView.contentInset = UIEdgeInsets.zero
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddDrillFromPage"{
            model.currentDrillSet = model.numberOfDrillSets()
        }
    }
    
    func sendNotification(){
        model.scheduleNotification(inSeconds: 1, completion: { success in
            if success {
                print("Successfully scheduled notification")
            } else {
                print("Error scheduling notification")
            }
        })
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
