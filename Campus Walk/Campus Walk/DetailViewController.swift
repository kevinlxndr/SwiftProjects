//
//  DetailViewController.swift
//  Campus Walk
//
//  Created by Kevin Ramsussen on 10/28/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var buildingName: UINavigationItem!
    @IBOutlet weak var buildingImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let model = Model.sharedInstance
    let imagePicker = UIImagePickerController()
    var currentTextView : UITextView?
    
    var currentBuilding : Building?

    override func viewDidLoad() {
        super.viewDidLoad()
        buildingName.title = currentBuilding!.name
        imagePicker.delegate = self
        createTextView()
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        buildingImage.image = model.image(at: currentBuilding!.name)
        adjustTextView(textView: currentTextView!)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(currentTextView!.endEditing(_:))))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createTextView(){
        let frame = CGRect(x: 50, y: self.view.frame.height/2.0 + 50, width: self.view.frame.width - 100.0, height: 100)
        let textView = UITextView(frame: frame)
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 20.0)
        textView.isScrollEnabled = false
        scrollView.addSubview(textView)
        textView.text = model.information[currentBuilding!.name]
        currentTextView = textView

    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextView(textView: textView)
    }
    
    func adjustTextView(textView:UITextView){
        let size = CGSize(width: self.view.frame.width - 100, height: .infinity)
        let calculatedSize = textView.sizeThatFits(size)
        let frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y, width: self.view.frame.width-100.0, height: calculatedSize.height)
        textView.frame = frame
        model.changeInformation(at:currentBuilding!.name, to:textView.text)
        let testHeight = calculatedSize.height + self.view.frame.height/2 + 50.0
        let scrollHeight = scrollView.contentSize.height
        if testHeight > scrollHeight {
            let difference = testHeight - scrollHeight
            scrollView.contentSize.height = scrollView.contentSize.height + difference
        }
        else if testHeight < scrollHeight{
            if testHeight < self.view.frame.height{
                scrollView.contentSize.height = self.view.frame.height
            }
            else{
                let difference = testHeight - scrollHeight
                scrollView.contentSize.height = scrollView.contentSize.height + difference
            }
        }
        
    }
    
    func configure( building: Building){
        currentBuilding = building
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
            currentTextView?.resignFirstResponder()
        }
    }
    
    @objc
    func keyboardWillHide(notification:Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }

    @IBAction func dismissDetail(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeImage(_ sender: UIButton) {
        let alertView = UIAlertController(title: "Change Photo", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            let actionLibrary = UIAlertAction(title: "From Library", style: .default, handler:{ (action) in
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            })
            alertView.addAction(actionLibrary)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            
            let actionPhoto = UIAlertAction(title: "Take Photo", style: .default, handler:{ (action) in
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.present(self.imagePicker, animated: true, completion: nil)
            })
            alertView.addAction(actionPhoto)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertView.addAction(actionCancel)
        
        self.present(alertView, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let picked = info[UIImagePickerControllerOriginalImage] as? UIImage{
            let building =  model.building(named: buildingName.title!)
            model.changeImage(at: building.name, to: picked)
        }
        dismiss(animated: true, completion: nil)
    }
}
