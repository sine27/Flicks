//
//  HelperFunctions.swift
//  FlicksCollection
//
//  Created by Shayin Feng on 2/2/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class HelperFunctions: NSObject {
    
    fileprivate var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    let notifyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
    
    let footerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
    
    open func subviewSetup (sender : AnyObject) {
        
        spinner.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        spinner.isHidden = false
        spinner.center = sender.view.center
        spinner.startAnimating()
        spinner.alpha = 0
        
        notifyLabel.numberOfLines = 1
        notifyLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
        notifyLabel.font = UIFont(name:"HelveticaNeue;", size: 30.0)
        notifyLabel.textAlignment = NSTextAlignment.center
        notifyLabel.center = sender.view.center
        notifyLabel.contentMode = UIViewContentMode.scaleAspectFit
        notifyLabel.alpha = 0
        
        footerLabel.numberOfLines = 1
        footerLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
        footerLabel.font = UIFont(name:"HelveticaNeue;", size: 30.0)
        footerLabel.textAlignment = NSTextAlignment.center
        footerLabel.center.x = sender.view.center.x
        footerLabel.contentMode = UIViewContentMode.scaleAspectFit
        footerLabel.alpha = 0
    }
    
    open func activityIndicator(sender : AnyObject) {
        sender.view.addSubview(spinner)
        UIView.animate(withDuration: 0.6, animations: {
            self.spinner.alpha = 1
        })
    }
    
    open func stopActivityIndicator() {
        spinner.stopAnimating()
        UIView.animate(withDuration: 0.4, animations: {
            self.spinner.alpha = 0
        })
        spinner.removeFromSuperview()
    }
    
    open func showNotifyLabelCenter (sender : AnyObject, notificationLabel : String, notifyType : Int) {
        
        // 0 : Not Fount
        // 1 : Reach The End
        self.notifyLabel.alpha = 1
        notifyLabel.center.y = sender.view.center.y
        notifyLabel.text = notificationLabel
        
        if notifyType == 0 {
            
            notifyLabel.numberOfLines = 1
            
            sender.view.addSubview(notifyLabel)
        }
        else if notifyType == 1 {
            
            notifyLabel.numberOfLines = 2
            
            sender.view.addSubview(notifyLabel)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.notifyLabel.center.y = self.notifyLabel.center.y - 70
            })
        }
    }
    
    open func showNotifyLabelFooter (sender : AnyObject, notificationLabel : String, positionY : CGFloat) {
        
        footerLabel.center.y = positionY
        
        footerLabel.alpha = 1
        footerLabel.text = notificationLabel
        
        sender.view.addSubview(footerLabel)
    }
    
    open func removeNotifyLabelCenter () {
        notifyLabel.alpha = 0
        notifyLabel.removeFromSuperview()
    }
    
    open func removeNotifyLabelFooter () {
        UIView.animate(withDuration: 0.5, animations: {
            self.footerLabel.alpha = 0
        })
        footerLabel.removeFromSuperview()
    }
    
    // custom navigation bar
    open func navigationBarSetup(sender : UIViewController) {
        
        sender.navigationController!.navigationBar.topItem?.title = ""
        
        sender.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        sender.navigationController!.navigationBar.shadowImage = UIImage()
        // Sets the translucent background color
        sender.navigationController!.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        sender.navigationController!.navigationBar.isTranslucent = true
    }
    
    // setup collection view layout
    open func collectionViewLayoutSetup (collectionView : UICollectionView, view : UIViewController) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = view.view.frame.width / 2
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: itemWidth, height: (1.5 * itemWidth))
    }
    
    // footer setup
    open func footerSetup (scrollView : UIScrollView, collectionView : UICollectionView, view : UIViewController, label : String, searchActive : Bool) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height - 50) >= scrollView.contentSize.height) && !searchActive
        {
            let footerHeight = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height
            let footerPositionY = collectionView.frame.maxY - (footerHeight / 2)
            let footerText = label
            
            showNotifyLabelFooter(sender : view, notificationLabel: footerText, positionY: footerPositionY)
        } else {
            removeNotifyLabelFooter()
        }
    }
}
