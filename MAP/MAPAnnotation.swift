//
//  MAPAnnotation.swift
//  mickey
//
//  Created by Varun Iyer on 5/12/19.
//  Copyright © 2019 Michelle Friedman. All rights reserved.
//

import UIKit
import Mapbox
import Pastel

class MapAnnotation: MGLPointAnnotation {
    var type: Int? // if type == 0, monument. if type == 1, friend
    var monument: Monument!
    var friend: User!
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MonumentAnnotationView: MGLAnnotationView {
    
    var monument: Monument!
    var shadowBackgroundView: RoundShadowView!
    var pastelView: PastelView!
    var monumentImageView: UIImageView!
    var questionMarkLabel: UILabel!
    
    convenience init (reuseIdentifier: String?, monument: Monument) {
        self.init(reuseIdentifier: reuseIdentifier)
        self.monument = monument
        self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        shadowBackgroundView = RoundShadowView(frame: CGRect(x: 2.5, y: 2.5, width: self.frame.width - 5, height: self.frame.height - 5), cornerRadius: 45/2, shadowRadius: 3, shadowOffset: CGSize(width: 0.0, height: 1.0), shadowOpacity: 0.9)
        shadowBackgroundView.backgroundColor = .white
        shadowBackgroundView.layer.cornerRadius = 20
        
        addSubview(shadowBackgroundView)
        
        pastelView = PastelView(frame: self.frame)
        pastelView.layer.cornerRadius = 45/2
        pastelView.clipsToBounds = true
        
        pastelView.startPastelPoint = .top
        pastelView.endPastelPoint = .bottom
        
        // Custom Duration
        pastelView.animationDuration = 2
        
        // Custom Color
        pastelView.setColors([UIColor(red: 225/255, green: 247/255, blue: 248/255, alpha: 1.0),
                              UIColor(red: 37/255, green: 235/255, blue: 239/255, alpha: 0.75)])
        addSubview(pastelView)
        pastelView.startAnimation()
        
        self.monumentImageView = UIImageView()
        monumentImageView.frame = CGRect(x: 2.5, y: 2.5, width: self.frame.width - 5, height: self.frame.height - 5)
        monumentImageView.image = monument.photos[0]
        monumentImageView.contentMode = .scaleAspectFill
        monumentImageView.layer.cornerRadius = 45/2
        monumentImageView.clipsToBounds = true
        self.addSubview(monumentImageView)
    }
    
    override init (reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


    


class MyAnnotationView: MGLUserLocationAnnotationView {
    private let size: CGFloat = 60
    var logo: CALayer!
    private var pastelView: PastelView!
    
    override func update() {
        if frame.isNull {
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            return setNeedsLayout()
        }
        setupLayers()
    }
    
    func setupLayers() {
        if logo == nil {
            
            logo = CALayer()
            logo.bounds = CGRect(x: 0, y: 0, width: size, height: size)
            pastelView = PastelView(frame: logo.frame)
            pastelView.layer.cornerRadius = 60/2
            pastelView.clipsToBounds = true
            pastelView.startPastelPoint = .bottom
            pastelView.endPastelPoint = .top
            // Custom Duration
            pastelView.animationDuration = 1.0
            pastelView.alpha = 0.5
            // Custom Color
            pastelView.setColors([UIColor(red: 225/255, green: 247/255, blue: 248/255, alpha: 1.0),
                                  UIColor(red: 37/255, green: 235/255, blue: 239/255, alpha: 0.75)])
            
            addSubview(pastelView)
            
            if CLLocationCoordinate2DIsValid(userLocation!.coordinate) {
                logo.opacity = 1
                pastelView.startAnimation()
                locationRadiusAnimation()
            } else {
                logo.opacity = 0
            }
            
            logo.contents = UIImage(named: "atlasLogo")?.cgImage
            logo.contentsGravity = CALayerContentsGravity.resizeAspectFill
            logo.isGeometryFlipped = true
            layer.addSublayer(logo)
        }
    }
    
    func locationRadiusAnimation() {
        let animator = UIViewPropertyAnimator(duration: 2, curve: .easeOut) {
            self.pastelView.frame = CGRect(x: self.pastelView.frame.minX - 40, y: self.pastelView.frame.minY - 40, width: self.pastelView.frame.width + 80, height: self.pastelView.frame.height + 80)
            self.pastelView.layer.cornerRadius += 40
            self.pastelView.alpha -= 0.5
        }
        
        animator.addCompletion { _ in
            if self.pastelView.frame.height >= 140 {
                self.pastelView.frame = self.logo.frame
                self.pastelView.layer.cornerRadius = 30
                self.pastelView.alpha = 0.5
            }
            self.locationRadiusAnimation()
        }
        
        animator.startAnimation()
    }
}




