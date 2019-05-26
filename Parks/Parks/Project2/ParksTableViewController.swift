//
//  ParksTableViewController.swift
//  Parks
//
//  Created by Kevin Ramsussen on 9/29/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class ParksTableViewController: UITableViewController {
    let model = Model.sharedInstance
    var collapsed : [Bool] = []
    var storedIndexPath : IndexPath = IndexPath()
    var imageIsZoomed =  false
    var currentScrollView : UIScrollView?

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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if imageIsZoomed{
            let scroll = currentScrollView!
            var image = UIImageView()
            for temp in scroll.subviews{
                if temp as? UIImageView != nil{
                    image = temp as! UIImageView
                }
            }
            let imageView = image
            scroll.frame.size = size
            scroll.frame.origin.y = tableView.contentOffset.y
            imageView.frame.size = size

        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.isScrollEnabled = false
        imageIsZoomed = true
        let cell = tableView.cellForRow(at: indexPath) as! ParkTableViewCell
        let imageView = cell.parkImageView!
        let overView = UIScrollView(frame: CGRect(origin: CGPoint(x:0,y:tableView.contentOffset.y), size: self.view.bounds.size))
        self.view.addSubview(overView)
        overView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        let newImageView = UIImageView()
        var originalFrame = cell.convert(imageView.frame, to: self.view)
        originalFrame.origin.y = originalFrame.origin.y - tableView.contentOffset.y
        originalFrame.origin.x = originalFrame.origin.x - tableView.contentOffset.x
        newImageView.frame = originalFrame
        newImageView.image = imageView.image
        newImageView.contentMode = .scaleAspectFit
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tappedImage:)))
        newImageView.addGestureRecognizer(tapRecognizer)
        
        newImageView.isUserInteractionEnabled = true
        overView.maximumZoomScale = 10.0
        overView.isUserInteractionEnabled = true
        overView.delegate = self
        overView.addSubview(newImageView)
        
        UIView.animate(withDuration: 2, delay: 0.2, animations: {
            let newPoint = CGPoint(x: 0, y: 0)
            newImageView.frame.origin = newPoint
            newImageView.frame.size = self.view.bounds.size
        })
        storedIndexPath = indexPath
        currentScrollView = overView
    }
    
    @objc func imageTapped(tappedImage: UITapGestureRecognizer){

        let tappedView = tappedImage.view as! UIImageView
        let temp = tappedView.superview as! UIScrollView
        
        if temp.zoomScale==1.0{
             let cell = tableView.cellForRow(at: storedIndexPath) as! ParkTableViewCell
            let image = cell.parkImageView!
            var newFrame = cell.convert(image.frame, to: self.view)
            newFrame.origin.y = newFrame.origin.y - tableView.contentOffset.y
            UIView.animate(withDuration: 2, delay: 0.2, animations: {
                tappedView.frame = newFrame
            },completion:{finished in
                self.tableView.isScrollEnabled = true
                let temp = tappedView.superview!
                tappedView.removeFromSuperview()
                temp.removeFromSuperview()
                self.imageIsZoomed = false
                self.currentScrollView = nil
            })
        }
    }
    
    override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }

}
