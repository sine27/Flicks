//
//  HelperFunctions.swift
//  FlicksCollection
//
//  Created by Shayin Feng on 2/2/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class HelperFunctions: NSObject {
    
    

    // MARK : Activity indicator >>>>>
    fileprivate var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    fileprivate var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        
    func activityIndicator(sender : AnyObject) {
        
        blur.frame = CGRect(x: 30, y: 30, width: 80, height: 80)
        blur.layer.cornerRadius = 10
        blur.center = sender.view.center
        blur.clipsToBounds = true
        blur.alpha = 0
        
        spinner.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        spinner.isHidden = false
        spinner.center = sender.view.center
        spinner.startAnimating()
        spinner.alpha = 0
        
        sender.view.addSubview(blur)
        sender.view.addSubview(spinner)
        
        UIView.animate(withDuration: 0.6, animations: {
            self.blur.alpha = 1
            self.spinner.alpha = 1
        })
    }
    
    open func stopActivityIndicator() {
        spinner.stopAnimating()
        UIView.animate(withDuration: 0.4, animations: {
            self.blur.alpha = 0
            self.spinner.alpha = 0
        })
        spinner.removeFromSuperview()
        blur.removeFromSuperview()
    }
    // <<<<<< Activity indicator
    
    
    
}
