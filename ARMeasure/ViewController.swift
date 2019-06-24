//
//  ViewController.swift
//  ARMeasure
//  An app to measure objects from 2 touch points in AR
//  Created by Justin Rose on 6/22/19.
//  Copyright © 2019 Justin Rose. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var previousTextNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint) //we use .featurePoint because we want to detect a point on a detected surface closest to the touch point
            if let hitTestResult = hitTestResults.first {
                addDot(at: hitTestResult)
            }
        }
    }
    
    func addDot(at location: ARHitTestResult) {
        
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(location.worldTransform.columns.3.x,
                                      location.worldTransform.columns.3.y,
                                      location.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        let xDistance = end.position.x - start.position.x
        let yDistance = end.position.y - start.position.y
        let zDistance = end.position.z - start.position.z
        
        //use Pythagorean theorem to find the distance between points in 3d
        let distance = sqrtf(powf(xDistance, 2) + powf(yDistance, 2) + powf(zDistance, 2))
        
        displayText(distance, at: end.position)
    }
    
    func displayText(_ distance: Float, at position: SCNVector3) {
        
        previousTextNode?.removeFromParentNode()
        
        let text = SCNText(string: String(distance * 3.281) + "ft", extrusionDepth: 1.0)
        
        text.firstMaterial?.diffuse.contents = UIColor.red //we can use the firstMaterial property instead of creating an SCNMaterial object first
        
        let node = SCNNode(geometry: text) //set the geometry when initializing the object rather than setting the geometry property later
        
        node.position = SCNVector3(position.x, position.y + 0.1, position.z - 5.0)
        node.scale = SCNVector3(0.05, 0.05, 0.05) //the default text size is too big so we'll reduce the scale
        previousTextNode = node
        sceneView.scene.rootNode.addChildNode(node)
    }
}
