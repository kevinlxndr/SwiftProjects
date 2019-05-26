//
//  SplitTableViewController.swift
//  Parks
//
//  Created by Kevin Ramsussen on 10/5/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class SplitTableViewController: UITableViewController {
    let model = Model.sharedInstance
    var collapsed : [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<model.totalParkCount{
            collapsed.append(false)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.totalParkCount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if collapsed[section] == true{
            return 0
        }
        else{
            return model.parkImageCount(section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkCell", for: indexPath) as! ParkTableViewCell
        cell.parkCaptionLabel.text = model.pictureCaption(indexPath)
        let pictureName = model.picture(indexPath)
        cell.parkImageView.image = UIImage(named: pictureName)
        cell.parkImageView.contentMode = .scaleAspectFit
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkHeaderCell") as! ParksHeaderTableViewCell
        
        cell.sectionTitle.text = model.parkName(section)
        cell.collapseButton.tag = section
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? ParksHeaderTableViewCell{
            headerView.sectionTitle.text = model.parkName(section)
            //headerView.collapseButton.setTitle("-", for: .normal)
        }
    }
    
    @IBAction func collapseAction(_ sender: UIButton) {
        let sectionNumber = sender.tag
        let indexset :IndexSet = IndexSet.init(integer:sectionNumber)
        collapsed[sectionNumber] = !collapsed[sectionNumber]
        
        tableView.reloadSections(indexset, with: .fade)
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        if imageIsZoomed{
//            let scroll = currentScrollView!
//            var image = UIImageView()
//            for temp in scroll.subviews{
//                if temp as? UIImageView != nil{
//                    image = temp as! UIImageView
//                }
//            }
//            let imageView = image
//            scroll.frame.size = size
//            scroll.frame.origin.y = tableView.contentOffset.y
//            imageView.frame.size = size
//
//        }
//
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier{
        case "DetailSegue":
            let navController = segue.destination as! UINavigationController
            let detail = navController.topViewController as! DetailViewController
            
            let indexPath = tableView.indexPathForSelectedRow!
            let image = UIImage(named: model.picture(indexPath))!
            let caption = model.pictureCaption(indexPath)
            
            detail.configure(image: image,caption: caption)
        default:
            assert(false, "Unhandled Segue")
        }
    }


}
