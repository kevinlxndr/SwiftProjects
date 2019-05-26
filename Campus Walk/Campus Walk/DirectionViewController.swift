//
//  DirectionViewController.swift
//  Campus Walk
//
//  Created by Kevin Ramsussen on 10/19/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

let model = Model.sharedInstance

class DirectionViewController: UIViewController {

    @IBOutlet weak var toLocation: UILabel!
    @IBOutlet weak var fromLocation: UILabel!
    @IBOutlet weak var selectBuilding1: UIButton!
    @IBOutlet weak var selectBuilding2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {

        toLocation.text = model.Direction1
        fromLocation.text = model.Direction2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectToBuilding(_ sender: UIButton) {
        model.currentDirectionChange = sender.tag
        performSegue(withIdentifier: "DirectionToTable", sender: nil)
    }
    
    @IBAction func cancelDirectionAction(_ sender: UIButton) {
        
        if sender.tag == 0 {
            model.setDirections = false
        }
        else{
            model.setDirections = true
        }
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
