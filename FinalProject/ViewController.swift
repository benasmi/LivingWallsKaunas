//
//  ViewController.swift
//  FinalProject
//
//  Created by Saule on 10/04/2019.
//  Copyright © 2019 Saule. All rights reserved.
//

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
    
    //sceneManager.startPlaneDetection()
    
    var timer: Timer?
    let sceneManager = ARSceneManager()
    
    var shouldDrawWalls: Bool = false;
    var isRestartButtonShown = false
    var currentColor: UIColor = UIColor.black
    var canvasNode = SCNNode()
    var canvasWallNode = SCNNode()
    var currentBrush: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        drawButtonOutlet.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        drawButtonOutlet.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
        
        brushesPickerView.delegate = self
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        setUp3Ddrawings()
        setUpColorSlider()
        
    }
    
    func setUp3Ddrawings(){
        let configuration = ARWorldTrackingConfiguration()
        // Create a new scene
        let scene = SCNScene()
        
        sceneView.scene = scene
        sceneView.scene.rootNode.addChildNode(canvasNode)
        sceneView.scene.rootNode.addChildNode(canvasWallNode)
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.session.run(configuration)
    }
    
    @objc func buttonDown(_ sender: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(rapidFire), userInfo: nil, repeats: true)
    }
    
    @objc func buttonUp(_ sender: UIButton) {
        timer?.invalidate()
    }
    
    @objc func rapidFire() {
        if(shouldDrawWalls){
            
            //Center of the screen
        let location = CGPoint(x: Int(184), y: Int(325))
        let hit = sceneView.hitTest(location,
                                    types: .existingPlaneUsingGeometry)
        if let hit = hit.first {
            placeBlockOnPlaneAt(hit)
        }
            
        }
    }
    
    func placeBlockOnPlaneAt(_ hit: ARHitTestResult) {
        let box = createBox()
        position(node: box, atHit: hit)
        sceneView?.scene.rootNode.addChildNode(box)
        canvasWallNode.addChildNode(box)
    }
    
    private func createBox() -> SCNNode {
        let box = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0.01)
        let boxNode = SCNNode(geometry: box)
        boxNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: box, options: nil))
        
        return boxNode
    }
    
    private func position(node: SCNNode, atHit hit: ARHitTestResult) {
        node.transform = SCNMatrix4(hit.anchor!.transform)
        node.eulerAngles = SCNVector3Make(node.eulerAngles.x + (Float.pi / 2), node.eulerAngles.y, node.eulerAngles.z)
        
        let position = SCNVector3Make(hit.worldTransform.columns.3.x + node.geometry!.boundingBox.min.z, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
        node.position = position
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
        
        if(shouldDrawWalls){
            print("walls")
            return
        }else{
            print("3D drawings")
        }
        
        
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
        return 4
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
        case 3:
            myImageView.image = UIImage(named:"drawButton")
        default:
            myImageView.image = nil
        }
        
        myView.addSubview(myImageView)
        
        return myView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentBrush = row
        print(row)
        if(row==3){
            print("Pieskit ant sienu")
            shouldDrawWalls = true
            sceneManager.attach(to: sceneView)
            sceneManager.displayDegubInfo()
            sceneManager.startPlaneDetection()
        }else{
            sceneManager.detachDebugInfo()
            sceneManager.showPlanes = false
            sceneManager.stopPlaneDetection()
            shouldDrawWalls = false
            viewDidLoad()
        }
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

