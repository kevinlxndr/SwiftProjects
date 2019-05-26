//
//  PageViewController.swift
//  Parks
//
//  Created by Kevin Ramsussen on 10/6/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var walkthroughViewController : UIPageViewController?
    let model = Model.sharedInstance
    var pageControl = UIPageControl()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        walkthroughViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        walkthroughViewController!.dataSource = self
        walkthroughViewController!.delegate = self
        
        let firstPage =  contentController(at: 0)
        walkthroughViewController!.setViewControllers([firstPage], direction: .forward, animated: false, completion: nil)
        
        // need these so that pageViewController delegate is told about orientation changes
        self.addChildViewController(walkthroughViewController!)
        walkthroughViewController?.didMove(toParentViewController: self)
        
        self.view.addSubview(walkthroughViewController!.view)
        
        configurePageControl()
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func contentController(at index:Int) -> WalkthroughViewController {
        let content = self.storyboard?.instantiateViewController(withIdentifier: "WalkthroughViewController") as! WalkthroughViewController
        var buttonInvisible = true
        let imageName = model.walkthroughImage(index)
        content.walkthroughIndex = index
        if index == model.numberWalkthroughImages - 1{
            
            buttonInvisible = false
        }
        content.configure(imageName, buttonInvisible)
        return content
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let contentViewController = viewController as! WalkthroughViewController
        let index = contentViewController.walkthroughIndex!
        
        guard index > 0 else {return nil}
        
        let newController =  contentController(at: index-1)
        return newController

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let contentViewController = viewController as! WalkthroughViewController
        let index = contentViewController.walkthroughIndex!
        
        guard index < model.numberWalkthroughImages - 1 else {return nil}
        
        let newController =  contentController(at: index+1)
        return newController

    }
    
    func configurePageControl(){
        let controlFrame = CGRect(x: 0, y: self.view.bounds.height - 40, width: self.view.bounds.width , height: 40)
        pageControl = UIPageControl(frame: controlFrame)
        self.pageControl.numberOfPages = model.numberWalkthroughImages
        self.pageControl.currentPage = 0
        self.view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0] as! WalkthroughViewController
        self.pageControl.currentPage = pageContentViewController.walkthroughIndex!
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
