//
//  ParksCollectionViewController.swift
//  Parks
//
//  Created by Kevin Ramsussen on 9/29/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ParkCollectionCell"

class ParksCollectionViewController: UICollectionViewController {
    
    let model = Model.sharedInstance
    var collapsed : [Bool] = []
    var canRevert = true
    var storedIndexPath : IndexPath = IndexPath()
    var currentScrollView : UIScrollView?
    var imageIsZoomed = false
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0..<model.totalParkCount{
            collapsed.append(false)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return model.totalParkCount
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if collapsed[section] == true{
            return 0
        }
        else{
            return model.parkImageCount(section)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ParksCollectionViewCell
    
        // Configure the cell
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(thumbnailTapped(tappedImage:)))
         let imageName = model.picture(indexPath)
        cell.parkImageView.image = UIImage(named: imageName)
        cell.parkImageView.contentMode = .scaleAspectFit
        cell.parkImageView.addGestureRecognizer(tapGestureRecognizer)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ParkHeader", for: indexPath) as! ParksCollectionReusableView
        headerView.sectionTitle.text = model.parkName(indexPath.section)
        headerView.collapseButton.tag = indexPath.section
        return headerView
    }
    
    @IBAction func collapseAction(_ sender: UIButton) {
        let sectionNumber = sender.tag
        let indexset :IndexSet = IndexSet.init(integer:sectionNumber)
        collapsed[sectionNumber] = !collapsed[sectionNumber]
        
        collectionView?.reloadSections(indexset)
    }
    
    @objc func thumbnailTapped(tappedImage: UITapGestureRecognizer){
        imageIsZoomed = true
        let tappedView = tappedImage.view as! UIImageView
        
        let cell = tappedView.superview?.superview as! ParksCollectionViewCell
        let overView = UIScrollView(frame: CGRect(origin: CGPoint(x:0,y:0), size: self.view.bounds.size))
        self.view.addSubview(overView)
        overView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        let newImageView = UIImageView()
        let originalFrame = tappedView.convert(tappedView.frame, to: overView)
        newImageView.frame = originalFrame
        newImageView.image = tappedView.image
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
        currentScrollView = overView
        storedIndexPath = (collectionView?.indexPath(for: cell))!
    }
    
    @objc func imageTapped(tappedImage: UITapGestureRecognizer){
        let tappedView = tappedImage.view as! UIImageView
        let temp = tappedView.superview as! UIScrollView
        if temp.zoomScale==1.0{
           let cell = collectionView?.cellForItem(at: storedIndexPath) as! ParksCollectionViewCell
            let originalFrame = cell.convert(cell.parkImageView.frame, to: temp)
            
            
            UIView.animate(withDuration: 2, delay: 0.2, animations: {
                tappedView.frame = originalFrame
            },completion:{finished in
                
                tappedView.removeFromSuperview()
                temp.removeFromSuperview()
                self.imageIsZoomed = false
            })
        }
    }
    
    override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
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
            imageView.frame.size = size
            
        }
        
    }
   
    /*@objc func imageZoom(zoomingImage: UIPinchGestureRecognizer){
        var zoomScale = zoomingImage.scale
        if zoomingImage.scale < 0.5{
            zoomScale = 1.0
        }
        else if zoomingImage.scale > 10.0{
            zoomScale = 10.0
        }
        if zoomingImage.state == .began || zoomingImage.state == .changed{
            zoomingImage.view?.transform = (zoomingImage.view?.transform.scaledBy(x: zoomScale, y: zoomScale))!
        }
        else if zoomingImage.state == .ended{
            if zoomScale <= 1{
                canRevert = true
            }
            else{
                canRevert = false
            }
        }
    }*/

}
