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

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    var isSushiRotate = false
    var basePosition = SCNVector3(0.0, 0.0, 0.0)
    var contactOtherNode = false
    
    var currentStep = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //set the physics delegate
        sceneView.scene.physicsWorld.contactDelegate = self
        
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
            
            if let hitResult = results.first {
//                print(hitResult)
                
                if diceArray.count < 2 {
                    // Create a new scene
                    let diceScene = SCNScene(named: "art.scnassets/sushi.scn")
                    
                    // Check whether the diceScene already set up
                    if let diceNode = diceScene?.rootNode.childNode(withName: "sushi", recursively: false) {

                        diceNode.name = "sushi"
                        diceNode.scale = SCNVector3(0.5,0.5,0.5)
                        diceNode.position = SCNVector3(
                            hitResult.worldTransform.columns.3.x,
                            hitResult.worldTransform.columns.3.y + 0.01,
                            hitResult.worldTransform.columns.3.z
                        )
                        basePosition = diceNode.position
                        
//                        let body = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: diceNode))
//                        diceNode.physicsBody = body
//                        diceNode.physicsBody?.isAffectedByGravity = true
//                        diceNode.physicsBody?.restitution = 1
//                        diceNode.physicsBody?.categoryBitMask = BodyType.basic.rawValue
//                        diceNode.physicsBody?.collisionBitMask = BodyType.basic.rawValue
//                        diceNode.physicsBody?.contactTestBitMask = BodyType.basic.rawValue
                        
                        diceArray.append(diceNode)
                        sceneView.scene.rootNode.addChildNode(diceNode)
                        
                    }
                    
                    // Create a new scene
                    let shurikenScene = SCNScene(named: "art.scnassets/sumpit.scn")
                    
                    // Check whether the diceScene already set up
                    if let shurikenNode = shurikenScene?.rootNode.childNode(withName: "sumpit", recursively: false) {
                        
                        shurikenNode.name = "chopstick"
//                        shurikenNode.scale = SCNVector3(1.5,1.5,1.5)
                        shurikenNode.scale = SCNVector3(0.4, 0.3, 0.4)
                        shurikenNode.eulerAngles = SCNVector3Make(Float(-Double.pi/4), 0, 0);

                        shurikenNode.position = SCNVector3(
                            hitResult.worldTransform.columns.3.x + 0.2,
                            hitResult.worldTransform.columns.3.y + 0.01,
                            hitResult.worldTransform.columns.3.z
                     )
                        
                        
//                        let bosdy = SCNPhysicsBody(type: .kinematic
//                            , shape: SCNPhysicsShape(node: shurikenNode))
//                        shurikenNode.physicsBody?.isAffectedByGravity = true
//                        shurikenNode.physicsBody = body
//                        shurikenNode.physicsBody?.restitution = 1
                        
//                        shurikenNode.physicsBody?.categoryBitMask = BodyType.basic.rawValue
//                        shurikenNode.physicsBody?.collisionBitMask = BodyType.basic.rawValue
//                        shurikenNode.physicsBody?.contactTestBitMask = BodyType.basic.rawValue
                        
                        diceArray.append(shurikenNode)
                        sceneView.scene.rootNode.addChildNode(shurikenNode)
                        
                    } else {
                        print("failed")
                    }
                }
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        print("contact happened")
        
        
        // targeted node
        print("Node A: \(contact.nodeA.name ?? "empty") ")

//        print("Node B: \(contact.nodeB.name ?? "empty") ")
        
        if contact.nodeA.physicsBody?.categoryBitMask == BodyType.sushi.rawValue &&
            contact.nodeB.physicsBody?.categoryBitMask == BodyType.chopstick.rawValue {

//            contactOtherNode = true
            
            print("chopstick is contacted by sushi")
            

        } else if  contact.nodeA.physicsBody?.categoryBitMask == BodyType.sushi.rawValue &&
            contact.nodeB.physicsBody?.categoryBitMask == BodyType.basic.rawValue {

//            contactOtherNode = true
            
            if contact.nodeA.name == "sushi" &&
                (contact.nodeB.name == "chopstick" || contact.nodeB.name == "sumpit_boundary" ){
                
                print("sushi is contacted by chopstick")
                
                // func rotate the sushi
                let sushi = contact.nodeA
                let chopstick = contact.nodeB
                
                if sushi.name == "sushi" {
                    
                    print("rotate the sushi")

                    if currentStep == 0 {
                        rotateSushi(node: sushi)
                        updateStep()

                        // make sushi follow chopsticks
                        chopstick.addChildNode(sushi)
                        // reposition the sushi according to the chopstick
                        print("Sushi position: \(sushi.position)\n")
                        sushi.position = sushi.convertPosition(sushi.position, to: chopstick)
                        print("Sushi.position: \(sushi.position)\n")
                        
                        print("Chopstick posisi")
                        print(chopstick.position)
                        
                        print("sushi posisi")
                        print(sushi.position)
                    }
                }
            }
         }
        
        print("")
    }
    
    func updateStep() {
        currentStep += 1
    }
    
    func rotateSushi(node: SCNNode){
        let action = SCNAction.rotateTo(x: CGFloat(Double.pi / 2), y: 0, z: 0, duration: 0.5)
        node.runAction(action)
    }
    
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        
        gesture.minimumNumberOfTouches = 1
        
        let results = self.sceneView.hitTest(
            gesture.location(in: gesture.view),
            types: ARHitTestResult.ResultType.featurePoint)
        
        guard let result: ARHitTestResult = results.first else {
            return
        }
        
        let hits = self.sceneView.hitTest(gesture.location(in: gesture.view), options: nil)
        
        if let tappedNode = hits.first?.node {
       
//            if tappedNode.name != "sushi" {
            
                let position = SCNVector3Make(
                    result.worldTransform.columns.3.x,
                    result.worldTransform.columns.3.y,
                    result.worldTransform.columns.3.z)
                
                tappedNode.position = position
//            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        // back to prev page
    }
    
    //Detect real world surface
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor

            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))

            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/black_grid.png")
            plane.materials = [gridMaterial]

            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.y)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            planeNode.geometry = plane
            planeNode.name = "surface"
            
//            let body = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: planeNode))
//            planeNode.physicsBody = body
//            planeNode.physicsBody?.restitution = 1
//            planeNode.physicsBody?.categoryBitMask = BodyType.basic.rawValue
//            planeNode.physicsBody?.collisionBitMask = BodyType.sushi.rawValue | BodyType.chopstick.rawValue
//            planeNode.physicsBody?.contactTestBitMask = BodyType.sushi.rawValue | BodyType.chopstick.rawValue
            // 1phi radian = 180

            node.addChildNode(planeNode)
        } else {
            return
        }
    }
    
    enum BodyType: Int {
        // power of 2
        case basic = 1
        case sushi = 2
        case chopstick = 4
        case soysauce = 8
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
