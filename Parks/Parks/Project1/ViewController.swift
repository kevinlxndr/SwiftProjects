//
//  ViewController.swift
//  Parks
//
//  Created by Kevin Ramsussen on 9/23/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    let model = Model()
    var pages = [UIView]()
    
    
    @IBOutlet weak var parkScrollView: UIScrollView!
    
    @IBOutlet weak var arrowUp: UIImageView!
    @IBOutlet weak var arrowRight: UIImageView!
    @IBOutlet weak var arrowLeft: UIImageView!
    @IBOutlet weak var arrowDown: UIImageView!
    
    
    var currentParkNumber : Int {return Int(parkScrollView.contentOffset.x / self.view.bounds.width)}
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        /*for i in 0..<model.totalParkCount{
           // let parkName = model.getParkName(i)
            let newPage = UIView(frame: CGRect.zero)
            
            parkScrollView.addSubview(newPage)
            //pages.append(newPage)
        }*/
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        
        if model.setup == false{
        let screenSize = self.view.bounds.size
        //let maxCount = CGFloat(model.getLargestImageCount())
        
        parkScrollView.contentSize = CGSize(width: screenSize.width * CGFloat(model.totalParkCount), height: screenSize.height)
        
        
        
        for i in 0..<model.totalParkCount{
            
            let point = CGPoint(x: CGFloat(i) * screenSize.width, y: 0)
            //let frame = CGRect(origin: point, size: screenSize)
            //let page = pages[i]
            //page.frame = frame
            
            let pictureScrollView = UIScrollView(frame: CGRect.zero)
            pictureScrollView.isPagingEnabled = true
            pictureScrollView.frame = CGRect(origin: point ,size: screenSize)
            pictureScrollView.contentSize = CGSize(width:screenSize.width, height:  screenSize.height * CGFloat(model.parkImageCount(i)))
            pictureScrollView.isDirectionalLockEnabled = true
            pictureScrollView.delegate = self
            parkScrollView.addSubview(pictureScrollView)
            pictureScrollView.maximumZoomScale = 1.1
            let parkName = model.parkName(i)
            
            let firstView = UIView(frame: CGRect.zero)
            let label = UILabel(frame: CGRect.zero)
            
            let viewPoint = CGPoint(x: 0, y: 0)
            let viewFrame = CGRect(origin: viewPoint, size: screenSize)
            let labelFrame = CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: CGFloat(model.labelHeight))
            
            firstView.frame = viewFrame
            label.frame = labelFrame
            label.text = parkName
            label.font = label.font.withSize(50.0)
            label.textAlignment = .center
            
            firstView.addSubview(label)
            pictureScrollView.addSubview(firstView)
            
            for index in 0..<model.parkImageCount(i){
                //let imageCount = model.getParkImageCount(i)
                //let newPage = UIView(frame: CGRect.zero)
                let newView = UIScrollView(frame: CGRect.zero)
                let picture = UIImageView(image: UIImage( named: "\(parkName)0\(index+1)"))
                
                let newPoint = CGPoint(x: 0, y: screenSize.height * CGFloat(index))
                let newFrame = CGRect(origin: newPoint, size: screenSize)
                let imageFrame = CGRect(origin:CGPoint(x: 0, y: 0), size: screenSize)
                
                newView.frame = newFrame
                picture.frame = imageFrame
                picture.contentMode = .scaleAspectFit
                
                newView.maximumZoomScale = 10.0
                newView.delegate = self
                newView.addSubview(picture)
                pictureScrollView.addSubview(newView)
            }

            
        }
        model.setup = true
        
    }
    }

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(scrollView != parkScrollView){
            if scrollView.contentOffset.y != 0.0{
                parkScrollView.isScrollEnabled = false
            }
            else{
                parkScrollView.isScrollEnabled = true
            }
        }
        model.currentPark = currentParkNumber
        
        doArrows(scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func doArrows(_ scrollView:UIScrollView){
        let offset = scrollView.contentOffset
        var arrowArray : [UIImageView] = []
        if(offset.y > 0.0){
            arrowArray.append(arrowUp)
        }
        else{
            if(model.currentPark > 0){
                arrowArray.append(arrowLeft)
            }
            if(model.currentPark < model.totalParkCount-1){
                arrowArray.append(arrowRight)
            }
        }
        
        if offset.y != scrollView.contentSize.height - self.view.bounds.size.height || scrollView == parkScrollView{
            arrowArray.append(arrowDown)
        }
        
        UIView.animate(withDuration: 0.2, delay:0, animations:{
            
            for arrow in arrowArray{
                self.view.bringSubview(toFront: arrow)
                arrow.alpha = 1
                
            }
        })
        UIView.animate(withDuration: 0.2, delay:1.2, animations:{
            for arrow in arrowArray{
                arrow.alpha = 0
            }
        })
        
    }
}


