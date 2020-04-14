//
//  ViewController.swift
//  face-mesh
//
//  Created by Ryan Poole on 24/12/2017.
//  Copyright © 2017 Ryan Poole. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import Vision
import SwiftyOnboard
import Pastel
import ExpandingMenu
import ParticlesLoadingView
import AudioToolbox
import AnimatedGradientView
import Gifu
import MultiSlider
import CoreLocation



protocol CameraDelegate: class {
    var isCameraEnabled: Bool { get set }
    func exportFaceMap()
    func dismissSettingPopOver()
}

class ViewController: UIViewController, ARSessionDelegate, ARSCNViewDelegate, UIPopoverPresentationControllerDelegate, CameraDelegate, CLLocationManagerDelegate {
    
    private var faceNode2 = SCNNode()
       
   private var virtualFaceNode = SCNNode()
   
   private let serialQueue = DispatchQueue(label: "com.example.apple-samplecode.ARKitFaceExample.serialSceneKitQueue")
    var status_color = UIColor.cyan.cgColor
    var searchController = UISearchController()
    var EYE_AR_CONSEC_FRAMES = 50
    var EYE_OPEN_CONSEC_FRAMES = 30
    var COUNTER = 0
    var DISTRACTION_COUNTER = 0
    var ALARM_ON = false
    var audioPlayer = AVAudioPlayer()
    weak var maskDelegate: MaskDelegate?
    weak var cameraDelegate: CameraDelegate?
    
    var isPhysicalLighting = false
    var isWireframe = false
    var isCameraSetting = false
    var isOn = false
    
    var locationManager: CLLocationManager!
    var spotlightView = AwesomeSpotlightView()
    
    /*lazy var bottomBlurView: UIVisualEffectView? = {

        let view = self.addBottomBlur()
        return view

    }()*/
    
    lazy var bottomBlurView: UIImageView? = {

        let view = self.bleandImageView()
        return view

    }()
    
  
    
    var swiftyOnboard: SwiftyOnboard!
    let colors:[UIColor] = [#colorLiteral(red: 0, green: 0.4996390939, blue: 0.5690259933, alpha: 1),#colorLiteral(red: 0.06221483648, green: 0.2291241884, blue: 0.2870381773, alpha: 1),#colorLiteral(red: 0.03766160458, green: 0.1243921295, blue: 0.1558111012, alpha: 1),#colorLiteral(red: 0.02665456384, green: 0.07839464396, blue: 0.09818357974, alpha: 1),#colorLiteral(red: 0.03766160458, green: 0.1243921295, blue: 0.1558111012, alpha: 1),#colorLiteral(red: 0.06221483648, green: 0.2291241884, blue: 0.2870381773, alpha: 1),#colorLiteral(red: 0, green: 0.4996390939, blue: 0.5690259933, alpha: 1)]
      var titleArray: [String] = ["Welcome to AutoLert.", "Drive Alert, Stay Unhurt.", "A Computer Vision Solution", "Automated Alarm", "Navigation Mode", "Illuminate Mode", "Keep App Open"]
      var subTitleArray: [String] = ["Our mission is to reduce car accidents caused by drowsy-driving with an automated alert system.", "Last year, the National Sleep Foundation reported that 60% of Americans have driven while feeling sleepy, 37% have fallen asleep at the wheel, and 6,000 died. ", "We use Facial Detection to recognize signs of drowsiness, so make sure that your face is within the scope of your camera.", "An alarm will ring loudly when our system detects a sleepy driver behind the wheel, so don't forget to turn up your volume.", "AutoLert offers the option of turn-by-turn navigation with voice direction to safely get you where you're going.", "AutoLert also offers an 'Illuminate' option in settings to monitor drowsiness when it is very dark.", "Playing music in the background is fine, just as long as the app is open. Stay charged!"]
    
    
    
    var gradiant: CAGradientLayer = {
        //Gradiant for the background view
        let blue = UIColor(red: 69/255, green: 127/255, blue: 202/255, alpha: 1.0).cgColor
        let purple = UIColor(red: 166/255, green: 172/255, blue: 236/255, alpha: 1.0).cgColor
        let gradiant = CAGradientLayer()
        gradiant.colors = [purple, blue]
        gradiant.startPoint = CGPoint(x: 0.5, y: 0.18)
        return gradiant
    }()
    var utilities = Utilities()
    var isCameraEnabled: Bool = true {
        didSet {
            if isCameraEnabled {
                sceneView.scene.background.contents = cameraSource
            } else {
                
                let animatedGradient = AnimatedGradientView(frame: self.view.bounds)
                                             animatedGradient.direction = .up
                                             animatedGradient.animationValues = [(colors: ["#0dffea", "#0a045c"], .up, .axial),
                                                            (colors: ["#e8fffc", "#004f61"], .right, .axial),
                                                            (colors: ["#05615a", "#be88eb"], .down, .axial),
                                                            (colors: ["#e8fffc", "#004f61"], .left, .axial)]
                
                cameraSource = sceneView.scene.background.contents
                sceneView.scene.background.contents =  animatedGradient

            }
        }
    }
    
    
    lazy var loadingView: ParticlesLoadingView = {
           let x = (UIScreen.main.bounds.size.width-UIScreen.main.bounds.size.width)  / 2 + (50 / 2) // 🙈
           let y = (UIScreen.main.bounds.size.height-UIScreen.main.bounds.size.height) / 2 + (100 / 2) // 🙉
        
        /// --------------------------------------------------------
        //Ayaz - Change
        /// --------------------------------------------------------
        let view = ParticlesLoadingView(frame: CGRect(x: x - 15, y: y - 6 , width: Constants.w - 20, height: 56))
           view.particleEffect = .laser
           view.duration = 1.5
           view.particlesSize = 8.0
           view.clockwiseRotation = true
           view.layer.borderColor = status_color
           view.layer.borderWidth = 3.0
           view.layer.cornerRadius = 10.0
            
            /// --------------------------------------------------------
            //Ayaz - Change
            //view.center = self.searchController.searchBar.center
            /// --------------------------------------------------------
           return view
       }()
    
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var circleLoadingView: UIView!
    
    @IBOutlet weak var messageView: UIView!
    var session: ARSession {
        return sceneView.session
        
    }
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    
    var faceNode: Mask?
    
    
    var cameraSource: Any? // When setting the camera to black, we have to store the original source.
    
    private func setupFaceNodeContent() {
           for child in faceNode2.childNodes {
               child.removeFromParentNode()
           }
           faceNode2.addChildNode(virtualFaceNode)
       }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
         DispatchQueue.main.async {
            let mask = ARSCNFaceGeometry(device: self.sceneView.device!)
        let maskNode = Mask(geometry: mask!)
            self.faceNode = maskNode
       
            for child in node.childNodes {
                child.removeFromParentNode()
            }
            node.addChildNode(maskNode)
        
        
            self.faceNode2 = node
            self.serialQueue.async {
            self.setupFaceNodeContent()
        }
        }
        
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        faceNode?.update(withFaceAnchor: faceAnchor)
        
       // self.updateMessage(text: "Face is actively being tracked.")
        
        
        //virtualFaceNode.update(withFaceAnchor: faceAnchor)
        
        // eye looking down
        
      let eyeLookDownLeft = faceAnchor.blendShapes[.eyeLookDownLeft]
      let eyeLookDownRight = faceAnchor.blendShapes[.eyeLookDownRight]
      let eyeLookInLeft = faceAnchor.blendShapes[.eyeLookInLeft]
      let eyeLookInRight = faceAnchor.blendShapes[.eyeLookInRight]
      let eyeLookOutLeft = faceAnchor.blendShapes[.eyeLookOutLeft]
      let eyeLookOutRight = faceAnchor.blendShapes[.eyeLookOutRight]
      let eyeLookUpLeft = faceAnchor.blendShapes[.eyeLookUpLeft]
      let eyeLookUpRight = faceAnchor.blendShapes[.eyeLookUpRight]
      let eyeSquintLeft = faceAnchor.blendShapes[.eyeSquintLeft]
      let eyeSquintRight = faceAnchor.blendShapes[.eyeSquintRight]
      let jawOpen = faceAnchor.blendShapes[.jawOpen]
      let geometry = virtualFaceNode.geometry as! ARSCNFaceGeometry
       geometry.update(from: faceAnchor.geometry)
        
        
        
        
        
        
        if self.didBlinkLeftEye(faceAnchor) {
            DispatchQueue.main.async {
                self.COUNTER += 1
                if self.COUNTER >= self.EYE_AR_CONSEC_FRAMES{
                    if !self.ALARM_ON{
                        self.ALARM_ON = true
                    let popup = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                       popup.imageName = "alert1"
                       popup.isAwakeShow = true
                       MIBlurPopup.show(popup, on: self)
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "alarm1", ofType: "mp3")!))
                        self.audioPlayer.play()
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                                    } catch {
                                                       // couldn't load file :(
                                                    }
                    self.COUNTER = 0
                    self.ALARM_ON = false
                    }
                }
            }
        }
        else{
            
            if self.COUNTER >= self.EYE_OPEN_CONSEC_FRAMES{
                 self.COUNTER = 0
                self.audioPlayer.stop()
            }
            
            if ((eyeLookDownLeft?.decimalValue ?? 0.0) > 0.75 && (eyeLookDownRight?.decimalValue ?? 0.0) > 0.75) {
                updateMessage(text: "Please bring your eyes back to the road")
                DispatchQueue.main.async {
                               self.DISTRACTION_COUNTER += 1
                               if self.DISTRACTION_COUNTER >= self.EYE_AR_CONSEC_FRAMES{
                                   if !self.ALARM_ON{
                                       self.ALARM_ON = true
                                   let popup = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                                      popup.imageName = "alert1"
                                      popup.isAwakeShow = true
                                      MIBlurPopup.show(popup, on: self)
                                   do {
                                       self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "alarm1", ofType: "mp3")!))
                                       self.audioPlayer.play()
                                       AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                                                   } catch {
                                                                      // couldn't load file :(
                                                                   }
                                   self.DISTRACTION_COUNTER = 0
                                   self.ALARM_ON = false
                                   }
                               }
                           }
            } else if ((eyeLookUpLeft?.decimalValue ?? 0.0) > 0.75 && (eyeLookUpRight?.decimalValue ?? 0.0) > 0.75) {
                updateMessage(text: "Gaze Detected: Focused on the Road")
            } else if((eyeLookInLeft?.decimalValue ?? 0.0) > 0.75 && (eyeLookOutRight?.decimalValue ?? 0.0) > 0.75){
                updateMessage(text: "Please bring your eyes back to the road")
                DispatchQueue.main.async {
                    self.DISTRACTION_COUNTER += 1
                    if self.DISTRACTION_COUNTER >= self.EYE_AR_CONSEC_FRAMES{
                        if !self.ALARM_ON{
                            self.ALARM_ON = true
                        let popup = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                           popup.imageName = "alert1"
                           popup.isAwakeShow = true
                           MIBlurPopup.show(popup, on: self)
                        do {
                            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "alarm1", ofType: "mp3")!))
                            self.audioPlayer.play()
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                                        } catch {
                                                           // couldn't load file :(
                                                        }
                        self.DISTRACTION_COUNTER = 0
                        self.ALARM_ON = false
                        }
                    }
                }
            } else if((eyeLookInRight?.decimalValue ?? 0.0) > 0.75 && (eyeLookOutLeft?.decimalValue ?? 0.0) > 0.75){
                updateMessage(text: "Please bring your eyes back to the road")
                DispatchQueue.main.async {
                    self.DISTRACTION_COUNTER += 1
                    if self.DISTRACTION_COUNTER >= self.EYE_AR_CONSEC_FRAMES{
                        if !self.ALARM_ON{
                            self.ALARM_ON = true
                        let popup = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                           popup.imageName = "alert1"
                           popup.isAwakeShow = true
                           MIBlurPopup.show(popup, on: self)
                        do {
                            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "alarm1", ofType: "mp3")!))
                            self.audioPlayer.play()
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                                        } catch {
                                                           // couldn't load file :(
                                                        }
                        self.DISTRACTION_COUNTER = 0
                        self.ALARM_ON = false
                        }
                    }
                }
            } else if((eyeSquintRight?.decimalValue ?? 0.0) > 0.25 && (eyeSquintLeft?.decimalValue ?? 0.0) > 0.25 && (jawOpen?.decimalValue ?? 0.0) > 0.25){
                updateMessage(text: "Yawn Detected - Please take a nap")
                DispatchQueue.main.async {
                    self.DISTRACTION_COUNTER += 1
                    if self.DISTRACTION_COUNTER >= self.EYE_AR_CONSEC_FRAMES{
                        if !self.ALARM_ON{
                            self.ALARM_ON = true
                        let popup = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
                           popup.imageName = "alert1"
                           popup.isAwakeShow = true
                           MIBlurPopup.show(popup, on: self)
                        do {
                            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "alarm1", ofType: "mp3")!))
                            self.audioPlayer.play()
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                                        } catch {
                                                           // couldn't load file :(
                                                        }
                        self.DISTRACTION_COUNTER = 0
                        self.ALARM_ON = false
                        }
                    }
                }
            }else {
                updateMessage(text: "Gaze Detected: Focused on the Road")
                self.DISTRACTION_COUNTER = 0
                self.audioPlayer.stop()
            }
            
            
        }
        
       
        
        
        
        
        
        
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        self.bottomBlurView?.isHidden = false
        gradient()
        
        swiftyOnboard = SwiftyOnboard(frame: view.frame, style: .light)
        view.addSubview(swiftyOnboard)
        swiftyOnboard.dataSource = self as SwiftyOnboardDataSource
        swiftyOnboard.delegate = self as SwiftyOnboardDelegate
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        sceneView.delegate = self
       sceneView.session.delegate = self
       sceneView.automaticallyUpdatesLighting = true
       
       let device = sceneView.device!
       
       let glassesGeometry = ARSCNFaceGeometry(device: device)!
      glassesGeometry.firstMaterial!.colorBufferWriteMask = []
      virtualFaceNode.geometry = glassesGeometry
       
       
       let url = Bundle.main.url(forResource: "rakutenCard", withExtension: "scn", subdirectory: "Models.scnassets")!
       let node = SCNReferenceNode(url:url)!
       node.load()
       
       let faceOverlayContent = node
       
       
       virtualFaceNode.addChildNode(faceOverlayContent)

       resetTracking()

       // Show statistics such as fps and timing information
       sceneView.showsStatistics = false

       cameraSource = sceneView.scene.background.contents
        
       
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTracking()
    }
    
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
         updateMessage(text: "Looking for a face")
        
        

        let configuration = ARFaceTrackingConfiguration()
        
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.blurView.isHidden = true
        
        session.pause()
        
        let configuration = ARWorldTrackingConfiguration()

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        updateMessage(text: "Session failed.")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
        updateMessage(text: "Session failed.")
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        DispatchQueue.main.async {
            self.resetTracking()
            
            self.updateMessage(text: "Session failed.")
        }
    }
    
    func updateMessage(text: String) {
           DispatchQueue.main.async {
               self.messageLabel.text = text
                self.messageLabel.layer.shadowColor = UIColor.black.cgColor
            self.messageLabel.layer.shadowRadius = 3.0
            self.messageLabel.layer.shadowOpacity = 1.0
            self.messageLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
            self.messageLabel.layer.masksToBounds = false

            
           }
       }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "settingsPop" {
            let popoverController = segue.destination as! SettingsPopoverController
            popoverController.maskDelegate = faceNode
            popoverController.cameraDelegate = self
            
            guard let popController = segue.destination.popoverPresentationController, let button = sender as? UIButton else { return }
            
            popController.delegate = self
            popController.sourceRect = button.bounds
            
            popoverController.modalPresentationStyle = .popover
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
    
    func exportFaceMap() {
        guard let a = session.currentFrame?.anchors[0] as? ARFaceAnchor else { return }
        
        let toprint = utilities.exportToSTL(geometry: a.geometry)
        
        let file = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("face.dae")
        do {
            try toprint.write(to: file!, atomically: true, encoding: String.Encoding.utf8)
        } catch  {
            
        }
        let vc = UIActivityViewController(activityItems: [file as Any], applicationActivities: [])
        present(vc, animated: true, completion: nil)
        
    }
    
    func gradient() {
        //Add the gradiant to the view:
        self.gradiant.frame = view.bounds
        view.layer.addSublayer(gradiant)
    }
    
    func showAlert(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func handleSkip() {
        swiftyOnboard.removeFromSuperview()
        gradiant.removeFromSuperlayer()
        
        
        
        let mapViewController = MAPViewController()
        let mapInteractor = MAPInteractor()
        let mapPresenter = MAPPresenter(view: mapViewController, interactor: mapInteractor)
        mapViewController.presenter = mapPresenter
        
        self.setSearchbar(mapViewController)
        self.view.addSubview(mapViewController.view)
        self.addChild(mapViewController)
        configureExpandingMenuInfo()
        initButton()

        if CLLocationManager.locationServicesEnabled() {
                 locationManager = CLLocationManager()
                 locationManager.delegate = self
                 locationManager.startUpdatingLocation()
                 locationManager.distanceFilter = 1
             }
        
        // Add and start a view animation
         view.addSubview(loadingView)
         loadingView.startAnimating()
         
         // Customize view, choose the Fire effect and start the animation.
        
         // Use a custom emitter particles file and customize the view.
         if let emitter = NSKeyedUnarchiver.unarchiveObject(withFile: Bundle.main.path(forResource: "Spark", ofType: "sks")!) as? SKEmitterNode {
             circleLoadingView.layer.borderWidth = 5.0
             circleLoadingView.layer.borderColor = UIColor.blue.cgColor
             circleLoadingView.layer.cornerRadius = circleLoadingView.frame.size.width / 2
             circleLoadingView.addParticlesAnimation(with: emitter)
             circleLoadingView.startAnimating()
         }
        
     
        let spotlight0 = AwesomeSpotlight(withRect: CGRect(x: (UIScreen.main.bounds.size.width-UIScreen.main.bounds.size.width)  / 2 + (50 / 2)-16, y: (UIScreen.main.bounds.size.height-UIScreen.main.bounds.size.height) / 2 + (100 / 2)-8, width: Constants.w - 20, height: 58), shape: .rectangle, text: "The laser is bright green when your features are being tracked.", isAllowPassTouchesThroughSpotlight: false)
        
        let spotlight1 = AwesomeSpotlight(withRect: CGRect(x: Constants.w/2 - 70/2, y: Constants.h - 82.0 - 70/2, width: 70, height: 70), shape: .circle, text: "Turn-by-Turn Navigation", isAllowPassTouchesThroughSpotlight: false)
        let spotlight2 = AwesomeSpotlight(withRect: CGRect(x: 30, y: self.view.bounds.height - 102.0, width: 40, height: 40), shape: .circle, text: "Illuminate Mode")
        let spotlight3 = AwesomeSpotlight(withRect: CGRect(x: Constants.w - 70.0, y: self.view.bounds.height - 102.0, width: 40, height: 40), shape: .circle, text: "Information")
        
        let spotlightView = AwesomeSpotlightView(frame: view.frame, spotlight: [spotlight0, spotlight1, spotlight2, spotlight3])
        spotlightView.cutoutRadius = 8
        spotlightView.delegate = self as? AwesomeSpotlightViewDelegate
        view.addSubview(spotlightView)
        spotlightView.start()
        
        
      
    }
    
   
     
        
    
   
    
    @objc func handleContinue(sender: UIButton) {
        let index = sender.tag
        swiftyOnboard?.goToPage(index: index + 1, animated: true)
    }
    
    @IBAction func actionSettingButton(_ sender: Any) {
        self.blurView.isHidden = false
        _ = self.blurView.subviews.map({ $0.removeFromSuperview() })
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.blurView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.9

        self.blurView.addSubview(blurEffectView)
    }
    
    fileprivate func configureExpandingMenuInfo() {
        let menuButtonSize: CGSize = CGSize(width: 40.0, height: 40.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), image: UIImage(named: "info")!, rotatedImage: UIImage(named: "info")!)
        menuButton.center = CGPoint(x: self.view.bounds.width - 50.0, y: self.view.bounds.height - 82.0)
        self.view.addSubview(menuButton)
           
        func showAlert(_ title: String, _ message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
           
        let item1 = ExpandingMenuItem(size: menuButtonSize, title: "Statistics", image: UIImage(named: "stats")!, highlightedImage: UIImage(named: "stats")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            
            let popup = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
            popup.imageName = "AutoLert_Statistics"
            MIBlurPopup.show(popup, on: self)
        }
                  
           
           
        let item0 = ExpandingMenuItem(size: menuButtonSize, title: "Settings", image: UIImage(named: "settings_options")!, highlightedImage: UIImage(named: "settings_options")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            
            let popup = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
            popup.imageName = "AutoLert_Settings"
            MIBlurPopup.show(popup, on: self)
        }
           
        let item2 = ExpandingMenuItem(size: menuButtonSize, title: "Instructions", image: UIImage(named: "chooser-moment-icon-thought")!, highlightedImage: UIImage(named: "chooser-moment-icon-thought")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            
            let popup = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
            popup.imageName = "AutoLert_Instructions"
            MIBlurPopup.show(popup, on: self)
        }
           
        let item3 = ExpandingMenuItem(size: menuButtonSize, title: "Mission", image: UIImage(named: "chooser-moment-icon-sleep")!, highlightedImage: UIImage(named: "chooser-moment-icon-sleep")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            
            let popup = self.storyboard?.instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
            popup.imageName = "AutoLert_Mission"
            MIBlurPopup.show(popup, on: self)
        }
           
        menuButton.addMenuItems([ item0, item1, item2, item3])

        menuButton.willPresentMenuItems = { (menu) -> Void in
            print("InfoMenuItems will present.")
        }

        menuButton.didDismissMenuItems = { (menu) -> Void in
            print("InfoMenuItems dismissed.")
        }
    }
    
    
    func initButton() {
        let image = UIImage(named: "settings") as UIImage?
        let button   = UIButton(type: UIButton.ButtonType.custom) as UIButton
        let menuButtonSize: CGSize = CGSize(width: 40.0, height: 40.0)
        button.frame = CGRect(origin: CGPoint.zero, size: menuButtonSize)
        button.center = CGPoint(x: 50.0, y: self.view.bounds.height - 40/2 - 62.0)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for:.touchUpInside)
        self.view.addSubview(button)
       
         }
         
         @objc func buttonPressed() {
             activateButton(bool: !isOn)
         }
         
         func activateButton(bool: Bool) {
             
             isOn = bool
            
            self.maskDelegate = faceNode
            self.cameraDelegate = self
            
            self.cameraDelegate?.isCameraEnabled = self.isCameraSetting
            self.isCameraSetting = !self.isCameraSetting
             
            
         }
    
  
    
    
    
    
    func dismissSettingPopOver() {
        self.blurView.isHidden = true
    }
    
    func setSearchbar(_ delegate: SearchResultVCDelegate){
        self.edgesForExtendedLayout = .all
        self.extendedLayoutIncludesOpaqueBars = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchResultController = storyboard.instantiateViewController(withIdentifier: "SearchResultVC") as! SearchResultVC
        searchResultController.delegate = delegate
        
        self.searchController = UISearchController(searchResultsController:searchResultController)
        self.searchController.searchResultsUpdater = delegate as? UISearchResultsUpdating
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search for a place"
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        //UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).leftViewMode = .never
        
        self.definesPresentationContext = true
        
        self.searchController.view.backgroundColor = UIColor.clear
        self.searchController.searchBar.backgroundColor = UIColor.clear
        self.searchController.searchBar.barTintColor = UIColor.clear
        
        // TextField Color Customization
        (UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]) ).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.textAlignment = NSTextAlignment.left
            let ivIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            ivIcon.image = UIImage(named: "searchIcon")
            searchController.searchBar.searchTextField.leftViewMode = .always
            searchController.searchBar.searchTextField.leftView = ivIcon
        } else {
            if let searchTextField:UITextField = searchController.searchBar.subviews[0].subviews.last as? UITextField {
                searchTextField.textAlignment = NSTextAlignment.left
                let ivIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                ivIcon.image = UIImage(named: "searchIcon")
                searchTextField.leftViewMode = .always
                searchTextField.leftView = ivIcon
            }
        }

        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.searchController.searchBar.isTranslucent = true
        self.searchController.searchBar.isOpaque = true
        self.searchController.searchBar.tintColor = .black
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Cancel"
        self.searchController.searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
        //searchController.searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchBar"), for: .normal)
        self.searchController.searchBar.layer.borderColor = UIColor.white.cgColor
        self.searchController.searchBar.layer.borderWidth = 0
        //searchController.searchBar.backgroundImage = UIImage(named: "transparent")
        
//        self.view.addSubview(searchController.searchBar)
//        self.searchController.searchBar.sizeToFit()
//        searchController.searchBar.frame.size.width = self.view.frame.size.width
        
        //self.navigationItem.searchController = searchController
        self.navigationItem.titleView = self.searchController.searchBar
    }
}

extension ViewController: SwiftyOnboardDelegate, SwiftyOnboardDataSource {
    
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        //Number of pages in the onboarding:
        return 7
    }
    
    func swiftyOnboardViewForBackground(_ swiftyOnboard: SwiftyOnboard) -> UIView? {
        var gradientLayer: CAGradientLayer!
        
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = swiftyOnboard.frame
        
        let bottomColor = UIColor(displayP3Red:41/255, green: 146/255, blue: 141/255, alpha: 1).cgColor
        let topColor = UIColor(red:0.00, green:0.03, blue:0.09, alpha:1.0).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        
        let view = UIView(frame: swiftyOnboard.frame)
        view.layer.insertSublayer(gradientLayer, at: 0)
        return view
    }
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        
      let view = SwiftyOnboardPage()
       
        let imageView = GIFImageView(frame: CGRect(x: Constants.w/2 - 400/2, y: Constants.h/2-400, width: 400, height: 400))
                                      imageView.animate(withGIFNamed: "onboard\(index)") {
                                        print("It's animating!")}
            
             view.addSubview(imageView)
                                      
        //Set the font and color for the labels:
           

        
        //Set the font and color for the labels:
        view.title.font = UIFont(name: "DIN Condensed", size: 30)
        view.subTitle.font = UIFont(name: "DIN Alternate", size: 19)
        
        //Set the text in the page:
        view.title.text = titleArray[index]
        view.subTitle.text = subTitleArray[index]
        
        //Return the page for the given index:
        return view
    }
    
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        let overlay = SwiftyOnboardOverlay()
        
        //Setup targets for the buttons on the overlay view:
        overlay.skipButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        overlay.continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        
        //Setup for the overlay buttons:
        overlay.continueButton.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 16)
        overlay.continueButton.setTitleColor(UIColor.white, for: .normal)
        overlay.skipButton.setTitleColor(UIColor.white, for: .normal)
        overlay.skipButton.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 16)
        
        //Return the overlay view:
        return overlay
    }
    
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
        let currentPage = round(position)
        overlay.pageControl.currentPage = Int(currentPage)
        overlay.continueButton.tag = Int(position)
        
        if currentPage == 0.0 || currentPage == 1.0 || currentPage == 2.0 || currentPage == 3.0 || currentPage == 4.0 || currentPage == 5.0  {
            overlay.continueButton.setTitle("Swipe to Continue", for: .normal)
            overlay.skipButton.setTitle("Exit", for: .normal)
            overlay.skipButton.isHidden = false
            overlay.skipButton.backgroundColor =  UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0)
            overlay.skipButton.layer.cornerRadius = UIScreen.main.bounds.size.height/2
        } else {
            overlay.continueButton.setTitle("", for: .normal)
            overlay.skipButton.setTitle("Exit", for: .normal)
            overlay.skipButton.backgroundColor =  UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0)
            overlay.skipButton.layer.cornerRadius = UIScreen.main.bounds.size.height/2
            overlay.skipButton.isHidden = false
          
        }
    }
    

}
extension ViewController {
    private func didBlinkLeftEye(_ faceAnchor: ARFaceAnchor) -> Bool {
        let value = lround(Double(truncating: faceAnchor.blendShapes[.eyeBlinkLeft]!))
        if value == 1 {
            return true
        }
        return false
    }
    
    
}

