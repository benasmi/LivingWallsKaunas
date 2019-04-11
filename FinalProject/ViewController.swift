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
import ColorSlider

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var drawButtonOutlet: UIButton!
    
    @IBOutlet weak var brushesPickerView: UIPickerView!
    
    
    @IBOutlet weak var restartBtnOutlet: CustomButton!
    
    var isRestartButtonShown = false
    var currentColor: UIColor = UIColor.black
    var canvasNode = SCNNode()
    var currentBrush: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        brushesPickerView.delegate = self
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        sceneView.autoenablesDefaultLighting = true
        // Create a new scene
        let scene = SCNScene()
        
        sceneView.scene = scene
        sceneView.scene.rootNode.addChildNode(canvasNode)
        
       
        // Set the scene to the view
        sceneView.scene = scene
        
        setUpColorSlider()
    }
    
    func setUpColorSlider(){
        let colorSlider = ColorSlider()
        colorSlider.frame = CGRect(0, 0, self.view.frame.width-30, 30)
        colorSlider.orientation = .horizontal
        colorSlider.previewEnabled = true
        colorSlider.borderWidth = 0
        colorSlider.center.x = view.center.x
        colorSlider.addTarget(self, action: #selector(ViewController.changedColor(_:)), for: .valueChanged)
        colorSlider.frame.origin.y = self.view.frame.height - (colorSlider.frame.height * 2)
        view.addSubview(colorSlider)
    }
    
    @objc func changedColor(_ slider: ColorSlider) {
        var color = slider.color
        currentColor = color
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
                
                var customBrush: Any?
                let spehereMaterial = SCNMaterial()
                spehereMaterial.diffuse.contents = self.currentColor
                
                
                switch self.currentBrush{

                case 0:
                    customBrush = SCNSphere(radius: 0.02)
                    (customBrush as! SCNSphere).materials = [spehereMaterial]
                case 1:
                    customBrush = SCNBox(width: 0.02, height: 0.02, length: 0.02, chamferRadius: 0)
                    (customBrush as! SCNBox).materials = [spehereMaterial]
                case 2:
                    customBrush = SCNTorus(ringRadius: 0.04, pipeRadius: 0.02)
                    (customBrush as! SCNTorus).materials = [spehereMaterial]
                default:
                    customBrush = SCNSphere(radius: 0.02)
                    (customBrush as! SCNSphere).materials = [spehereMaterial]
                }
                
                //let sphere = SCNSphere(radius: 0.02)
    
                
                if self.isRestartButtonShown == false {
                    self.showRestartButton()
                }
                
                let sphereNode = SCNNode(geometry: customBrush as? SCNGeometry)
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
    
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    // MARK: UIPickerViewDelegate
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        
        var myView = UIView(frame: CGRect(0, 0, pickerView.bounds.width - 30, 60))
        
        var myImageView = UIImageView(frame: CGRect(0, 0, 50, 50))

        switch row {
        case 0:
            myImageView.image = UIImage(named:"drawButton")
        case 1:
            myImageView.image = UIImage(named:"drawButton")
        case 2:
            myImageView.image = UIImage(named:"drawButton")
        default:
            myImageView.image = nil
        }
       
        myView.addSubview(myImageView)
        
        return myView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentBrush = row
        
    }
}
