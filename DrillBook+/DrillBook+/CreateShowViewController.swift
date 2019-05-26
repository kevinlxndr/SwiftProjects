//
//  CreateShowViewController.swift
//  DrillBook+
//
//  Created by Kevin Ramsussen on 11/13/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class CreateShowViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var showTitleField: UITextField!
    @IBOutlet weak var fieldType: UISegmentedControl!
    
    let model = Model.sharedInstance
    
    override func viewDidLoad() {
        showTitleField.delegate = self
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createShow(_ sender: UIButton) {
        let text = showTitleField.text
        let field = fieldType.titleForSegment(at: fieldType.selectedSegmentIndex)!
        if text == nil || text == ""{
            let alertView = UIAlertController(title: "Error", message: "The show must have a title.", preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertView.addAction(actionCancel)
            self.present(alertView, animated: true, completion: nil)
        }
        else{
            model.createNewShow(title: text!,field: field)
            dismiss(animated: true, completion: nil)
        }
        
    }
    

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if !editing{
            showTitleField.resignFirstResponder()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
