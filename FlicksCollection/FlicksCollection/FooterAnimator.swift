//
//  FooterAnimator.swift
//  FlicksCollection
//
//  Created by Shayin Feng on 2/10/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import ESPullToRefresh

class FooterAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol {
    
    open var loadingMoreDescription: String = "Success"
    open var noMoreDataDescription: String  = "No more data"
    open var loadingDescription: String     = "Loading..."
    
    open var view: UIView { return self }
    open var duration: TimeInterval = 0.6
    open var insets: UIEdgeInsets = UIEdgeInsets.zero
    open var trigger: CGFloat = 80
    open var executeIncremental: CGFloat = 42
    open var state: ESRefreshViewState = .pullToRefresh
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.init(white: 160.0 / 255.0, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .white)
        indicatorView.isHidden = true
        return indicatorView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.text = loadingMoreDescription
        addSubview(titleLabel)
        addSubview(indicatorView)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func refreshAnimationBegin(view: ESRefreshComponent) {
        indicatorView.startAnimating()
        titleLabel.text = loadingDescription
        indicatorView.isHidden = false
    }
    
    open func refreshAnimationEnd(view: ESRefreshComponent) {
        indicatorView.stopAnimating()
        titleLabel.text = loadingMoreDescription
        indicatorView.isHidden = true
    }
    
    open func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {
        // do nothing
    }
    
    open func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
        
        switch state {
        case .refreshing, .autoRefreshing :
            titleLabel.text = loadingDescription
            break
        case .noMoreData:
            titleLabel.text = noMoreDataDescription
            break
        case .pullToRefresh:
            titleLabel.text = loadingMoreDescription
            break
        default:
            break
        }
        self.setNeedsLayout()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let s = self.bounds.size
        let w = s.width
        let h = s.height
        
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint.init(x: w / 2.0, y: h / 2.0)
        indicatorView.center = CGPoint.init(x: titleLabel.frame.origin.x - 18.0, y: titleLabel.center.y)
    }
}
