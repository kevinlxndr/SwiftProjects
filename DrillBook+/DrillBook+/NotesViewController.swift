//
//  NotesViewController.swift
//  DrillBook+
//
//  Created by Kevin Ramsussen on 12/8/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var navBar: UINavigationItem!
    let model = Model.sharedInstance
    var editingMode = false
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title = "Notes For Set \(model.currentDrillSet)"
        noteText.text = model.notes()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func editNotes(_ sender: Any) {
        if !editingMode{
            noteText.isEditable = true
            editingMode = !editingMode
            editButton.title = "Done"
            backButton.isEnabled = false
        }
        else{
            noteText.resignFirstResponder()
            backButton.isEnabled = true
            noteText.isEditable = false
            editingMode = !editingMode
            editButton.title = "Edit"
            model.updateNotes(noteText.text)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: (CGFloat(50.0)+(keyboardSize?.height)!), right: 0)
        noteText.contentInset = contentInsets
    }
    @objc func keyboardWillHide(notification:Notification) {
        noteText.contentInset = UIEdgeInsets.zero
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
