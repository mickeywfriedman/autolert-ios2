//
//  RoundShadowView.swift
//  mickey
//
//  Created by Varun Iyer on 5/11/19.
//  Copyright © 2019 Michelle Friedman. All rights reserved.
//

import Foundation
import UIKit

class RoundShadowView: UIView {
    
    let containerView = UIView()
    var _cornerRadius: CGFloat!
    var _shadowRadius: CGFloat!
    var _shadowOffset: CGSize!
    var _shadowOpacity: Float!
    
    init(frame: CGRect, cornerRadius: CGFloat, shadowRadius: CGFloat, shadowOffset: CGSize, shadowOpacity: Float) {
        super.init(frame: frame)
        
        _cornerRadius = cornerRadius
        _shadowRadius = shadowRadius
        _shadowOffset = shadowOffset
        _shadowOpacity = shadowOpacity
        layoutView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutView() {
        
        // set the shadow of the view's layer
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = _shadowOffset
        layer.shadowOpacity = _shadowOpacity
        layer.shadowRadius = _shadowRadius
        
        // set the cornerRadius of the containerView's layer
        containerView.layer.cornerRadius = _cornerRadius
        containerView.layer.masksToBounds = true
        
        addSubview(containerView)
        
        //
        // add additional views to the containerView here
        //
        
        // add constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // pin the containerView to the edges to the view
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
