//
//  DetailViewController.swift
//  Parks
//
//  Created by Kevin Ramsussen on 10/5/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var detailImage:UIImage?
    var captionText:String?
   
    @IBOutlet weak var detailPicture: UIImageView!
    @IBOutlet weak var detailCaption: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailPicture.image = detailImage
        detailPicture.contentMode = .scaleAspectFit
        detailCaption.text = captionText
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configure(image: UIImage, caption: String){
        detailImage = image
        captionText = caption
        
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
