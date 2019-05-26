//
//  CreateFieldViewController.swift
//  DrillBook+
//
//  Created by Kevin Ramsussen on 11/23/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit
import MapKit

class CreateFieldViewController: UIViewController, CLLocationManagerDelegate{
    let model = Model.sharedInstance
    var locationManager = Model.sharedLocationManager
    var coordinate = CLLocationCoordinate2D()
    var heading : CLHeading?
    @IBOutlet weak var fieldNameText: UITextField!
    @IBOutlet weak var fieldTypeSelector: UISegmentedControl!
    @IBOutlet weak var addButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        addButton.isEnabled = false
        addButton.alpha = 0.5

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined, .denied:
                locationManager.requestWhenInUseAuthorization()
            default:
                break
            }
        }
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(fieldNameText!.endEditing(_:))))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordCoordinates(_ sender: UIButton) {
        coordinate = locationManager.location!.coordinate
        addButton.isEnabled = true
        addButton.alpha = 1.0
    }
    
    @IBAction func addField(_ sender: UIButton) {

        if fieldNameText.text != "" && fieldNameText.text != nil{
        let fieldName = fieldNameText.text!
        let fieldType = fieldTypeSelector.titleForSegment(at: fieldTypeSelector.selectedSegmentIndex)!
        let field = Field(fieldName: fieldName, fieldType:fieldType, latitude: coordinate.latitude, longitude: coordinate.longitude)
            
        model.addNewField(field:field)
            
        locationManager.stopUpdatingLocation()
            
        dismiss(animated: true, completion: nil)
        }
        else{
            let alertView = UIAlertController(title: "Error", message: "The field must have a name.", preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertView.addAction(actionCancel)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    //0.0011
    //40.430924, 280.242511  40.430952, 280.244045
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if !editing{
            fieldNameText.resignFirstResponder()
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
