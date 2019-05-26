//
//  ViewController.swift
//  Campus Walk
//
//  Created by Kevin Ramsussen on 10/13/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit
import MapKit

class NormalPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title : String?
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
class FavoritePin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title : String?
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var toggleFavoriteButton: UIBarButtonItem!
    
    @IBOutlet weak var ETALabel: UILabel!
    @IBOutlet weak var directionStepLabel: UILabel!
    @IBOutlet weak var directionDisplayView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userToolBar: UIToolbar!
    
    
    let model = Model.sharedInstance
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        model.populateInfo()
        model.screenSize = self.view.bounds.size
        let location = model.initialLocation
        let coordinate = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: model.spanDelta, longitudeDelta: model.spanDelta)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let userButton = MKUserTrackingBarButtonItem.init(mapView: mapView)
        var userOptions = userToolBar.items!
        userOptions.append(spacer)
        userOptions.append(userButton)
        userToolBar.setItems(userOptions, animated: true)
        
        mapView.delegate = self
        locationManager.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            default:
                break
                
            }
        }
        
        if model.setDirections{
            if !mapView.overlays.isEmpty{
                clearDirections()
            }
            requestDirections()
            directionDisplayView.isHidden = false
        }
        
        if(model.selectedBuildingIndexPath != nil && model.changePin == true){
            let building = model.building(at: model.selectedBuildingIndexPath!)
            let coordinate = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
            var Annotation : MKAnnotation
            
            for temp in mapView.annotations{
                if temp.isKind(of: NormalPin.self){
                    mapView.removeAnnotation(temp)
                }
            }
            
            Annotation = NormalPin(title: building.name , coordinate: coordinate)
            mapView.addAnnotation(Annotation)
            model.currentNormalAnnotation = Annotation
            
            let span = MKCoordinateSpan(latitudeDelta: model.zoomDelta, longitudeDelta: model.zoomDelta)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
            model.changePin = false
        }
        
        if( model.showFavorites == true){
            showFavorites()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            mapView.showsUserLocation = false
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
        default:
            break
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is NormalPin:
            return annotationView(forNormalPin: annotation as! NormalPin)
        case is FavoritePin:
            return annotationView(forFavoritePin: annotation as! FavoritePin)
        default:
            return nil
        }
    }
    
    func annotationView(forNormalPin droppedPin:NormalPin) -> MKAnnotationView {
        let identifier = "NormalPin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: droppedPin, reuseIdentifier: identifier)
            view.pinTintColor = MKPinAnnotationView.purplePinColor()
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    
    
    func annotationView(forFavoritePin droppedPin:FavoritePin) -> MKAnnotationView {
        let identifier = "FavoritePin"
        var view: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: droppedPin, reuseIdentifier: identifier)
            view.pinTintColor = MKPinAnnotationView.greenPinColor()
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        switch view.annotation {
        case is NormalPin:
            let place = view.annotation as! NormalPin
            let alertView = UIAlertController(title: place.title, message: nil, preferredStyle: .actionSheet)
            
            let actionPresentDetail = UIAlertAction(title: "More Info", style: .default, handler:{ (action) in self.presentDetail()
            })
            alertView.addAction(actionPresentDetail)
            
            let actionDirection = UIAlertAction(title: "Get Directions", style: .default) { (action) in
                self.startDirections(pin:place.title!)
            }
            alertView.addAction(actionDirection)
            
            let actionCancel = UIAlertAction(title: "Clear", style: .cancel, handler: nil)
            alertView.addAction(actionCancel)
            
            let actionRemovePin = UIAlertAction(title: "Remove Pin", style: .default, handler: {(action) in self.clearPin()
            })
            alertView.addAction(actionRemovePin)
            
            /*let image = model.image(at: place.title!)
            let frame = CGRect(x: 0 , y: -(model.screenSize.height) * (0.5) - 10, width: model.screenSize.width - 20, height: model.screenSize.height * (0.5))
            let imageView = UIImageView.init(frame: frame)
            imageView.contentMode = .scaleAspectFit
            imageView.image = image*/
            self.present(alertView, animated: true, completion: {
                //alertView.view.addSubview(imageView)
            })
            
        case is FavoritePin:
            let place = view.annotation as! FavoritePin
            let alertView = UIAlertController(title: place.title, message: nil, preferredStyle: .actionSheet)
            

            let actionPresentDetail = UIAlertAction(title: "More Information", style: .default, handler:{ (action) in self.presentDetail()
            })
            alertView.addAction(actionPresentDetail)

            
            let actionDirection = UIAlertAction(title: "Get Directions", style: .default) { (action) in
                self.startDirections(pin:place.title!)
            }
            alertView.addAction(actionDirection)
            
            let actionCancel = UIAlertAction(title: "Clear", style: .cancel, handler: nil)
            alertView.addAction(actionCancel)
            
   let actionRemovePin = UIAlertAction(title: "Unfavorite Pin", style: .default, handler: {(action) in self.clearPin()
            })
            alertView.addAction(actionRemovePin)
            
            /*let image = model.image(at: place.title!)
             let frame = CGRect(x: 0 , y: -(model.screenSize.height) * (0.5) - 10, width: model.screenSize.width - 20, height: model.screenSize.height * (0.5))
             let imageView = UIImageView.init(frame: frame)
             imageView.contentMode = .scaleAspectFit
             imageView.image = image*/
            self.present(alertView, animated: true, completion: {
                //alertView.view.addSubview(imageView)
            })

            
        default:
            break
        }
        
    }
    
    
    
   
    
    func requestDirections() {
        let request = MKDirectionsRequest()
        if model.Direction1 != model.Direction2{
            
            if model.Direction1 == "User Location"{
                request.source = MKMapItem.forCurrentLocation()
            }
            else{
                let building1 = model.building(named: model.Direction1)
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: building1.latitude, longitude: building1.longitude)))
            }
            
            if model.Direction2 == "User Location"{
                request.destination = MKMapItem.forCurrentLocation()
            }
            else{
                let building2 = model.building(named: model.Direction2)
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: building2.latitude, longitude: building2.longitude)))
            }
            request.transportType = .walking
            
            let directions = MKDirections(request: request)
            
            directions.calculate { (response, error) in
                guard error == nil else {print(error?.localizedDescription as Any); return}
                
                let route = response?.routes.first!
                self.mapView.add((route?.polyline)!)
                self.model.currentOverlay = route?.polyline
                print(route!.steps)
                self.model.routeSteps = route!.steps
                
                if self.model.routeSteps.count != 1{
                    self.directionStepLabel.text = self.model.routeSteps[1].instructions
                    self.model.currentDirectionStep = 1
                    self.ETALabel.text = self.model.currentETA(time: route!.expectedTravelTime)
                }
            }
            
            model.setDirections = false
        }
    }
    
    func startDirections( pin:String){
        model.Direction1 = "User Location"
        model.Direction2 = pin
         model.currentTablePurpose = "Directions"

        //present(DirectionViewController, animated: true, completion: nil)
        performSegue(withIdentifier: "MapToDirection", sender: nil)
        
    }
    
    func presentDetail(){
        performSegue(withIdentifier: "PresentDetailView", sender: nil)
    }
    
    @IBAction func mapToTable(_ sender: Any) {
        performSegue(withIdentifier: "MapToTable", sender: nil)
    }
    
    @IBAction func changeMapType(_ sender: UISegmentedControl) {
        let selected = sender.selectedSegmentIndex
        if selected == 0{
            mapView.mapType = .standard
        }
        else if selected == 1{
            mapView.mapType = .satellite
        }
        else{
            mapView.mapType = .hybrid
        }
    }
    
    @IBAction func toggleFavorites(_ sender: UIBarButtonItem) {
        if model.showFavorites{
            sender.title = "Show Favorites"
            removeFavorites()
        }
        else{
            sender.title = "Hide Favorites"
            showFavorites()
        }
        model.showFavorites = !model.showFavorites
    }
    
    func clearPin() {
        let annotation = mapView.selectedAnnotations[0]
        
        if mapView.selectedAnnotations[0].isKind(of: NormalPin.self){
            model.currentNormalAnnotation = nil
            model.selectedBuildingIndexPath = nil
        }
        else{
            //let favoriteIndex = model.buildingNames.index(of: annotation.title!!)!
            model.Favorites[annotation.title!!] = !model.Favorites[annotation.title!!]!
            let index = model.favoriteAnnotations.index(where: {$0.title == annotation.title!!})!
            model.favoriteAnnotations.remove(at: index)
        }
        mapView.removeAnnotation(annotation)
    }
    
    
    func showFavorites(){
        removeFavorites()
        let buildingList = model.favoritedBuildings()
        model.favoriteAnnotations = []
        for building in buildingList{
            let coordinate = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
            let favoriteAnnotation = FavoritePin(title: building.name , coordinate: coordinate)
            mapView.addAnnotation(favoriteAnnotation)
            model.favoriteAnnotations.append(favoriteAnnotation)
            toggleFavoriteButton.title = "Hide Favorites"
        }
        
    }
    
    func removeFavorites(){
        for annotation in model.favoriteAnnotations{
            mapView.removeAnnotation(annotation)
        }
        
    }
    
    func clearDirections(){
        let overlay = mapView.overlays[0]
        mapView.remove(overlay)
        model.currentOverlay = nil
        model.routeETA = nil
        self.model.setDirections = false
        directionDisplayView.isHidden = true
    }
    
    @IBAction func progressDirectionSteps(_ sender: UIButton) {
        if sender.tag == 0{
            if model.currentDirectionStep < model.routeSteps.count-1{
                model.currentDirectionStep += 1
                directionStepLabel.text = model.routeSteps[model.currentDirectionStep].instructions
            }
        }
        else{
            if model.currentDirectionStep > 0 {
                model.currentDirectionStep -= 1
                directionStepLabel.text = model.routeSteps[model.currentDirectionStep].instructions
            }
        }
    }
    
    @IBAction func clearDirectionAction(_ sender: Any) {
        clearDirections()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case is MKPolyline:
            let line = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            line.strokeColor = UIColor.blue
            line.lineWidth = 4.0
            return line
        default:
            assert(false, "unhandled overlay")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case "MapToDirection":
            model.currentTablePurpose = "Directions"
        case "MapToTable":
            model.currentTablePurpose = "Map"
        case "PresentDetailView":
            let detail = segue.destination as! DetailViewController
            let buildingName = mapView.selectedAnnotations[0].title
            detail.configure(building: model.building(named: buildingName!!))
        default:
            break
        }
    }
    
}
