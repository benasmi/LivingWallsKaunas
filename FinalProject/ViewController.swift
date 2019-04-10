//
//  ViewController.swift
//  FinalProject
//
//  Created by Saule on 10/04/2019.
//  Copyright © 2019 Saule. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var drawButtonOutlet: UIButton!
    
    
    
    @IBOutlet weak var restartBtnOutlet: CustomButton!
    
    var isRestartButtonShown = false
    var currentColor: UIColor = UIColor.black
    var canvasNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        
        sceneView.scene = scene
        sceneView.scene.rootNode.addChildNode(canvasNode)
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    @IBAction func restartButton(_ sender: Any) {
        self.canvasNode.enumerateChildNodes{ (node, _) in
            node.removeFromParentNode()
        }
        restartBtnOutlet.isHidden = true
        isRestartButtonShown = false
    }
    
    @IBAction func drawButton(_ sender: Any) {
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        guard let cameraPoint = sceneView.pointOfView else{
            
            return
        }
        
        
        
        let cameraTransform = cameraPoint.transform
        
        let cameraLocation = SCNVector3(x: cameraTransform.m41, y:cameraTransform.m42, z:cameraTransform.m43)
        let cameraOrientaton = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
        
        //x1+x2,y1+y2,z1+z2
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientaton.x, cameraLocation.y + cameraOrientaton.y, cameraLocation.z + cameraOrientaton.z)
       
        DispatchQueue.main.async {
            if self.drawButtonOutlet.isTouchInside{
                let sphere = SCNSphere(radius: 0.02)
                
                let spehereMaterial = SCNMaterial()
                spehereMaterial.diffuse.contents = self.currentColor
                
                sphere.materials = [spehereMaterial]
                
                if self.isRestartButtonShown == false {
                    self.showRestartButton()
                }
                
                let sphereNode = SCNNode(geometry: sphere)
                sphereNode.position = SCNVector3(x: cameraPosition.x , y: cameraPosition.y, z: cameraPosition.z)
                
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                self.canvasNode.addChildNode(sphereNode)
            }
        }
        
    }
    
    func showRestartButton(){
        isRestartButtonShown = true
        restartBtnOutlet.isHidden = false
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

    // MARK: - ARSCNViewDelegate

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @IBAction func changeToRed(_ sender: Any) {
        currentColor = UIColor.red
    }
    
    @IBAction func changeToBlue(_ sender: Any) {
        currentColor = UIColor.blue
    }
    
    @IBAction func changeToBlack(_ sender: Any) {
        currentColor = UIColor.black
    }
    
    @IBAction func changeToGreen(_ sender: Any) {
        currentColor = UIColor.green
    }
    
    @IBAction func changeToWhite(_ sender: Any) {
        currentColor = UIColor.white
    }
    
    
}
