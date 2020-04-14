import ARKit
import SceneKit


protocol MaskDelegate: class {
    var isWireframe: Bool { get set }
    var isPhysicalLighting: Bool { get set }
}

class Mask: SCNNode, MaskDelegate {
    var isWireframe: Bool = true {
        didSet {
            material.fillMode = isWireframe ? .lines : .fill
            material.diffuse.contents = UIImage(named: "mask")
            
        }
    }
    
    var isPhysicalLighting: Bool = true {
        didSet {
            material.lightingModel = isPhysicalLighting ? .physicallyBased : .blinn
        }
    }

    var material: SCNMaterial
    
    init(geometry: ARSCNFaceGeometry) {
        material = geometry.firstMaterial!

        let image = UIImage(named: "mask")
        let imageView = UIImageView(image: image)
        imageView.alpha = 0.70
        material.diffuse.contents = imageView
        material.lightingModel = .physicallyBased
        

        
        super.init()
        self.geometry = geometry
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        let faceGeometry = geometry as! ARSCNFaceGeometry
        faceGeometry.update(from: anchor.geometry)
    }
}
