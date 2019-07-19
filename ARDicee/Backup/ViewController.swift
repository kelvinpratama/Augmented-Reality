//
//  ViewController.swift
//  ARDicee
//
//  Created by Kelvin Hadi Pratama on 10/07/19.
//  Copyright © 2019 Kelvin Hadi Pratama. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
//        // Create a new scene
//        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.1)
//        // let sphere = SCNSphere(radius: 0.2)
//        let material = SCNMaterial()
//        //material.diffuse.contents = UIColor.red
//        material.diffuse.contents = UIImage(named: "art.scnassets/mercury.jpg")
//        cube.materials = [material]
//
//        let node = SCNNode()
//        node.position = SCNVector3(0, 0.1, -0.5)
//        node.geometry = cube
//
//        // Set the scene to the view
//        sceneView.scene.rootNode.addChildNode(node)
        
        
        
        //DICE
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
//
//        if let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true) {
//
//            diceNode.position = SCNVector3(0.0, 0.0, -0.2)
//
//            sceneView.scene.rootNode.addChildNode(diceNode)
//
//        }
        
        // Add pan gesture for dragging the textNode about
        sceneView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:))))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // Touch location on the screen
            let touchLocation = touch.location(in: sceneView)
            
            // Search for real world object that coressponding to the touch on the scene view
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
//            if !results.isEmpty {
//                print("Plane touched")
//            } else {
//                print("Touched somewhere else")
//            }
            
            if let hitResult = results.first {
                print(hitResult)
                
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
                
                // Check whether the diceScene already set up
                if let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true) {

                    diceNode.position = SCNVector3(
                        hitResult.worldTransform.columns.3.x,
                        hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        hitResult.worldTransform.columns.3.z
                    )
        
                    diceArray.append(diceNode)
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
        
                    roll(dice: diceNode)
                    
                }
            }
        }
    }
    
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        
        gesture.minimumNumberOfTouches = 1
        
        let results = self.sceneView.hitTest(gesture.location(in: gesture.view), types: ARHitTestResult.ResultType.featurePoint)
        
        guard let result: ARHitTestResult = results.first else {
            return
        }
        
        let hits = self.sceneView.hitTest(gesture.location(in: gesture.view), options: nil)
        if let tappedNode = hits.first?.node {
            let position = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
            tappedNode.position = position
            
        }
    
        
    }
    
    func rollAllDice() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2) //90deg
        let randomY = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: CGFloat(randomY * 5),
                z: 0,
                duration: 0.5)
        )
    }
    
    @IBAction func rollAgain(_ sender: Any) {
        rollAllDice()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAllDice()
    }
    
    @IBAction func removeAllDice(_ sender: Any) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
            
            diceArray.removeAll()
        }
    }
    
    //Detect real world surface
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor

            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))

            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/yellowgrid.png")
            plane.materials = [gridMaterial]

            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.y)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            planeNode.geometry = plane
            // 1phi radian = 180

            node.addChildNode(planeNode)
        } else {
            return
        }
    }
}


//extension UIViewController {
//    func hideKeyboard() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)
//    }
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//}
