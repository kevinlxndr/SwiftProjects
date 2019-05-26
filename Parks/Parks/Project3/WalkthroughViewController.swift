//
//  WalkthroughViewController.swift
//  Parks
//
//  Created by Kevin Ramsussen on 10/7/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController {

    @IBOutlet weak var walkthroughImage: UIImageView!
    @IBOutlet weak var proceedButton: UIButton!
    var imageName: String?
    var walkthroughIndex: Int?
    var enableButton: Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        walkthroughImage.image = UIImage(named:imageName!)
        proceedButton.isHidden = enableButton!
        self.view.bringSubview(toFront: proceedButton)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(_ image : String,_ buttonVisible : Bool) {
        imageName = image
        enableButton = buttonVisible
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
