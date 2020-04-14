//
//  PopupViewController.swift
//  MIBlurPopup
//
//  Created by Mario on 14/01/2017.
//  Copyright © 2017 Mario. All rights reserved.
//

import UIKit
import AVFoundation



class PopupViewController: UIViewController {
    
    var imageName = ""
    var audioPlayer: AVAudioPlayer?
    var isAwakeShow: Bool = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imgMain: UIImageView!
    @IBOutlet weak var dismissButton: UIButton! {
        didSet {
            dismissButton.layer.cornerRadius = dismissButton.frame.height/2
            
        }
    }
    
    @IBOutlet weak var awakeButton: UIButton! {
        didSet {
            awakeButton.layer.cornerRadius = awakeButton.frame.height/2
            
        }
    }
    
    @IBOutlet weak var popupContentContainerView: UIView!
    @IBOutlet weak var popupMainView: UIView! {
        didSet {
            popupMainView.layer.cornerRadius = 10
//            popupMainView.largeContentImage = UIImage(named: imageName)
        }
    }
    
    var customBlurEffectStyle: UIBlurEffect.Style! = .dark
    var customInitialScaleAmmount: CGFloat! = 1
    var customAnimationDuration: TimeInterval! = 1.3
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return customBlurEffectStyle == .dark ? .lightContent : .default
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.awakeButton.isHidden = !self.isAwakeShow
        
        if !imageName.isEmpty {
            imgMain.image = UIImage(named: imageName)
        }
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true)
        audioPlayer?.stop()
    }
    
    
    

}

// MARK: - MIBlurPopupDelegate

extension PopupViewController: MIBlurPopupDelegate {
    
    var popupView: UIView {
        return popupContentContainerView ?? UIView()
    }
    
    var blurEffectStyle: UIBlurEffect.Style {
        return customBlurEffectStyle
    }
    
    var initialScaleAmmount: CGFloat {
        return customInitialScaleAmmount
    }
    
    var animationDuration: TimeInterval {
        return customAnimationDuration
    }
    
}
