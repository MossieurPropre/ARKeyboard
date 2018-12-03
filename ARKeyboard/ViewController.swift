//
//  ViewController.swift
//  ARTest2
//
//  Created by Aurélien Christman on 30/11/2018.
//  Copyright © 2018 Aurélien Christman. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var mbpNode: SCNNode!
    var mbpAnchor: ARImageAnchor!
    
    var keyboardLeft: SCNNode!
    var keyboardRight: SCNNode!
    var shipNode: SCNNode!
    
    var isKeyboardOpen = false
    var hasTakenOff = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError()
        }
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.detectionImages = referenceImages
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("add node")
        if (mbpAnchor != nil) {
            return
        }
        
        mbpAnchor = anchor as? ARImageAnchor
        
        //let imageName = imageAnchor.referenceImage.name ?? ""
        print(mbpAnchor.referenceImage)

        let keyboard = SCNNode()
        
        keyboardLeft = SCNNode()
        let geometryLeft = SCNPlane(width: mbpAnchor.referenceImage.physicalSize.width / 2.0, height: mbpAnchor.referenceImage.physicalSize.height)
        let imageLeft = UIImage(named: "clavier01")
        geometryLeft.firstMaterial?.diffuse.contents = imageLeft
        keyboardLeft.geometry = geometryLeft
        
        keyboardRight = SCNNode()
        let geometryRight = SCNPlane(width: mbpAnchor.referenceImage.physicalSize.width / 2.0, height: mbpAnchor.referenceImage.physicalSize.height)
        let imageRight = UIImage(named: "clavier02")
        geometryRight.firstMaterial?.diffuse.contents = imageRight
        keyboardRight.geometry = geometryRight
        keyboardRight.transform = SCNMatrix4MakeTranslation(Float(mbpAnchor.referenceImage.physicalSize.width) / 2.0, 0.0, 0.0)
        
        keyboard.addChildNode(keyboardLeft)
        keyboard.addChildNode(keyboardRight)
        
        keyboard.transform = SCNMatrix4MakeTranslation(-Float(mbpAnchor.referenceImage.physicalSize.width) / 4.0, 0.0, 0.0)
        
        let holeNode = SCNNode()
        
        let face1Geometry = SCNPlane(width: mbpAnchor.referenceImage.physicalSize.width, height: mbpAnchor.referenceImage.physicalSize.height)
        let face1Node = SCNNode()
        face1Geometry.firstMaterial?.diffuse.contents = UIColor.gray
        face1Node.geometry = face1Geometry
        
        let face2Geometry = SCNPlane(width: mbpAnchor.referenceImage.physicalSize.width, height: 0.1)
        let face2Node = SCNNode()
        face2Geometry.firstMaterial?.diffuse.contents = UIColor.gray
        face2Node.geometry = face2Geometry
        face2Node.rotation = SCNVector4Make(1, 0, 0, Float.pi / 2.0)
        face2Node.position = SCNVector3Make(0, Float(mbpAnchor.referenceImage.physicalSize.height) / 2.0, 0.05)
        
        let face3Geometry = SCNPlane(width: mbpAnchor.referenceImage.physicalSize.width, height: 0.1)
        let face3Node = SCNNode()
        face3Geometry.firstMaterial?.diffuse.contents = UIColor.gray
        face3Node.geometry = face3Geometry
        face3Node.rotation = SCNVector4Make(1, 0, 0, -Float.pi / 2.0)
        face3Node.position = SCNVector3Make(0, -Float(mbpAnchor.referenceImage.physicalSize.height) / 2.0, 0.05)
        
        let face4Geometry = SCNPlane(width: 0.1, height: mbpAnchor.referenceImage.physicalSize.height)
        let face4Node = SCNNode()
        face4Geometry.firstMaterial?.diffuse.contents = UIColor.gray
        face4Node.geometry = face4Geometry
        face4Node.rotation = SCNVector4Make(0, 1, 0, Float.pi / 2.0)
        face4Node.position = SCNVector3Make(-Float(mbpAnchor.referenceImage.physicalSize.width) / 2.0, 0, 0.05)
        
        let face5Geometry = SCNPlane(width: 0.1, height: mbpAnchor.referenceImage.physicalSize.height)
        let face5Node = SCNNode()
        face5Geometry.firstMaterial?.diffuse.contents = UIColor.gray
        face5Node.geometry = face5Geometry
        face5Node.rotation = SCNVector4Make(0, 1, 0, -Float.pi / 2.0)
        face5Node.position = SCNVector3Make(Float(mbpAnchor.referenceImage.physicalSize.width) / 2.0, 0, 0.05)
        
        holeNode.addChildNode(face1Node)
        holeNode.addChildNode(face2Node)
        holeNode.addChildNode(face3Node)
        holeNode.addChildNode(face4Node)
        holeNode.addChildNode(face5Node)
        
        let maskMaterial = SCNMaterial()
        maskMaterial.colorBufferWriteMask = []
        maskMaterial.writesToDepthBuffer = true
        
        let maskNode = SCNNode()

        let maskFace1Geometry = SCNPlane(width: mbpAnchor.referenceImage.physicalSize.width, height: mbpAnchor.referenceImage.physicalSize.height)
        let maskFace1Node = SCNNode()
        maskFace1Geometry.materials = [maskMaterial]
        maskFace1Node.geometry = maskFace1Geometry
        maskFace1Node.rotation = SCNVector4Make(1, 0, 0, Float.pi)
        maskFace1Node.renderingOrder = -1
        
        let maskFace2Geometry = SCNPlane(width: mbpAnchor.referenceImage.physicalSize.width, height: 0.1)
        let maskFace2Node = SCNNode()
        maskFace2Geometry.materials = [maskMaterial]
        maskFace2Node.geometry = maskFace2Geometry
        maskFace2Node.rotation = SCNVector4Make(1, 0, 0, -Float.pi / 2.0)
        maskFace2Node.position = SCNVector3Make(0, Float(mbpAnchor.referenceImage.physicalSize.height) / 2.0, 0.05)
        maskFace2Node.renderingOrder = -1
        
        let maskFace3Geometry = SCNPlane(width: mbpAnchor.referenceImage.physicalSize.width, height: 0.1)
        let maskFace3Node = SCNNode()
        maskFace3Geometry.materials = [maskMaterial]
        maskFace3Node.geometry = maskFace3Geometry
        maskFace3Node.rotation = SCNVector4Make(1, 0, 0, Float.pi / 2.0)
        maskFace3Node.position = SCNVector3Make(0, -Float(mbpAnchor.referenceImage.physicalSize.height) / 2.0, 0.05)
        maskFace3Node.renderingOrder = -1
        
        let maskFace4Geometry = SCNPlane(width: 0.1, height: mbpAnchor.referenceImage.physicalSize.height)
        let maskFace4Node = SCNNode()
        maskFace4Geometry.materials = [maskMaterial]
        maskFace4Node.geometry = maskFace4Geometry
        maskFace4Node.rotation = SCNVector4Make(0, 1, 0, -Float.pi / 2.0)
        maskFace4Node.position = SCNVector3Make(-Float(mbpAnchor.referenceImage.physicalSize.width) / 2.0, 0, 0.05)
        maskFace4Node.renderingOrder = -1
        
        let maskFace5Geometry = SCNPlane(width: 0.1, height: mbpAnchor.referenceImage.physicalSize.height)
        let maskFace5Node = SCNNode()
        maskFace5Geometry.materials = [maskMaterial]
        maskFace5Node.geometry = maskFace5Geometry
        maskFace5Node.rotation = SCNVector4Make(0, 1, 0, Float.pi / 2.0)
        maskFace5Node.position = SCNVector3Make(Float(mbpAnchor.referenceImage.physicalSize.width) / 2.0, 0, 0.05)
        maskFace5Node.renderingOrder = -1
        
        maskNode.addChildNode(maskFace1Node)
        maskNode.addChildNode(maskFace2Node)
        maskNode.addChildNode(maskFace3Node)
        maskNode.addChildNode(maskFace4Node)
        maskNode.addChildNode(maskFace5Node)
        
        maskNode.renderingOrder = -1
        
        holeNode.transform = SCNMatrix4MakeTranslation(Float(mbpAnchor.referenceImage.physicalSize.width) / 4.0, 0.0, -0.1)
        maskNode.transform = SCNMatrix4MakeTranslation(Float(mbpAnchor.referenceImage.physicalSize.width) / 4.0, 0.0, -0.1)
        
        keyboard.addChildNode(holeNode)
        keyboard.addChildNode(maskNode)
        
        shipNode = SCNScene.init(named: "art.scnassets/ship.scn")!.rootNode.childNode(withName: "shipNode", recursively: true)
        shipNode!.rotation = SCNVector4Make(0, 0, 1, Float.pi)
        shipNode!.position = SCNVector3Make(0, 0, -0.1)
            
        mbpNode = SCNNode()
        mbpNode.addChildNode(keyboard)
        mbpNode.addChildNode(shipNode!)
        mbpNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)

        node.addChildNode(mbpNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let thisAnchor = anchor as? ARImageAnchor
        
        if (thisAnchor == mbpAnchor) {

        }
    }
    
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @objc func handleTap(rec: UITapGestureRecognizer) {
        if (isKeyboardOpen == false) {
            let actionLeft1 = SCNAction.moveBy(x: 0.0, y: 0, z: 0.01, duration: 1.0)
            let actionRight1 = SCNAction.moveBy(x: 0.0, y: 0, z: 0.01, duration: 1.0)
            
            let actionLeft2 = SCNAction.moveBy(x: -0.1, y: 0, z: 0, duration: 1.0)
            let actionRight2 = SCNAction.moveBy(x: 0.1, y: 0, z: 0, duration: 1.0)
            
            let actionLeft = SCNAction.sequence([actionLeft1, actionLeft2])
            let actionRight = SCNAction.sequence([actionRight1, actionRight2])
            
            keyboardLeft.runAction(actionLeft)
            keyboardRight.runAction(actionRight)
            
            isKeyboardOpen = true
        } else if (hasTakenOff == false) {
            let action = SCNAction.moveBy(x: 0.0, y: 0, z: 5, duration: 20)
            hasTakenOff = true
            shipNode.runAction(action) {
                self.shipNode.removeFromParentNode()
            }
        } else {
            let actionLeft1 = SCNAction.moveBy(x: 0.0, y: 0, z: -0.01, duration: 1.0)
            let actionRight1 = SCNAction.moveBy(x: 0.0, y: 0, z: -0.01, duration: 1.0)
            
            let actionLeft2 = SCNAction.moveBy(x: 0.1, y: 0, z: 0, duration: 1.0)
            let actionRight2 = SCNAction.moveBy(x: -0.1, y: 0, z: 0, duration: 1.0)
            
            let actionLeft = SCNAction.sequence([actionLeft2, actionLeft1])
            let actionRight = SCNAction.sequence([actionRight2, actionRight1])
            
            keyboardLeft.runAction(actionLeft)
            keyboardRight.runAction(actionRight)
            
            isKeyboardOpen = false
        }

    }
}
