/**
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import SceneKit
import ARKit

// MARK: - Game State

enum GameState: Int16 {
  case detectSurface  // Scan playable surface (Plane Detection On)
  case pointToSurface // Point to surface to see focus point (Plane Detection Off)
  case swipeToPlay    // Focus point visible on surface, swipe up to play
}

class ViewController: UIViewController {
  
  // MARK: - Properties
  var trackingStatus: String = ""
  var statusMessage: String = ""
  var gameState: GameState = .detectSurface
  var focusPoint:CGPoint!
  var floorNode: SCNNode!
  var focusNode: SCNNode!
  var diceNodes: [SCNNode] = []
  var diceCount: Int = 5
  var diceStyle: Int = 0
  var diceOffset: [SCNVector3] = [SCNVector3(0.0,0.0,0.0),
                                  SCNVector3(-0.05, 0.00, 0.0),
                                  SCNVector3(0.05, 0.00, 0.0),
                                  SCNVector3(-0.05, 0.05, 0.02),
                                  SCNVector3(0.05, 0.05, 0.02)]
  
  // MARK: - Outlets
  
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var styleButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  
  // MARK: - Actions
  
  @IBAction func startButtonPressed(_ sender: Any) {
  }
  
  @IBAction func styleButtonPressed(_ sender: Any) {
    diceStyle = diceStyle >= 4 ? 0 : diceStyle + 1
  }
  
  @IBAction func resetButtonPressed(_ sender: Any) {
  }
  
  @IBAction func swipeUpGestureHandler(_ sender: Any) {
    // 1
    guard let frame = self.sceneView.session.currentFrame else { return }
    // 2
    for count in 0..<diceCount {
      throwDiceNode(transform: SCNMatrix4(frame.camera.transform),
                    offset: diceOffset[count])
    }
  }
  
  // MARK: - View Management
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initSceneView()
    self.initScene()
    self.initARSession()
    self.loadModels()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("*** ViewWillAppear()")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("*** ViewWillDisappear()")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    print("*** DidReceiveMemoryWarning()")
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  @objc
  func orientationChanged() {
    focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.25)
  }
  
  // MARK: - Initialization
  
  func initSceneView() {
    sceneView.delegate = self
    sceneView.showsStatistics = true
    sceneView.debugOptions = [
      //ARSCNDebugOptions.showFeaturePoints,
      //ARSCNDebugOptions.showWorldOrigin,
      //SCNDebugOptions.showBoundingBoxes,
      //SCNDebugOptions.showWireframe
    ]
    
    focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.25)
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
  }
  
  func initScene() {
    let scene = SCNScene()
    scene.isPaused = false
    sceneView.scene = scene
    scene.lightingEnvironment.contents = "PokerDice.scnassets/Textures/Environment_CUBE.jpg"
    scene.lightingEnvironment.intensity = 2
  }
  
  func initARSession() {
    guard ARWorldTrackingConfiguration.isSupported else {
      print("*** ARConfig: AR World Tracking Not Supported")
      return
    }
    
    let config = ARWorldTrackingConfiguration()
    config.worldAlignment = .gravity
    config.providesAudioData = false
    config.planeDetection = .horizontal
    sceneView.session.run(config)
  }
  
  // MARK: - Load Models
  
  func loadModels() {
    let diceScene = SCNScene(
      named: "PokerDice.scnassets/Models/DiceScene.scn")!
    for count in 0..<5 {
      diceNodes.append(diceScene.rootNode.childNode(
        withName: "dice\(count)",
        recursively: false)!)
    }
    
    let focusScene = SCNScene(
      named: "PokerDice.scnassets/Models/FocusScene.scn")!
    focusNode = focusScene.rootNode.childNode(
      withName: "focus", recursively: false)!
    
    sceneView.scene.rootNode.addChildNode(focusNode)
  }
  
  // MARK: - Helper Functions
  
  func throwDiceNode(transform: SCNMatrix4, offset: SCNVector3) {
    let position = SCNVector3(transform.m41 + offset.x,
                              transform.m42 + offset.y,
                              transform.m43 + offset.z)
    let diceNode = diceNodes[diceStyle].clone()
    diceNode.name = "dice"
    diceNode.position = position
    sceneView.scene.rootNode.addChildNode(diceNode)
    diceCount -= 1
  }
  
  func updateStatus() {
    // 1
    switch gameState {
    case .detectSurface:
      statusMessage = "Scan entire table surface...\nHit START when ready!"
    case .pointToSurface:
      statusMessage = "Point at designated surface first!"
    case .swipeToPlay:
      statusMessage = "Swipe UP to throw!\nTap on dice to collect it again."
    }
    // 2
    self.statusLabel.text = trackingStatus != "" ?
      "\(trackingStatus)" : "\(statusMessage)"
  }
  
  func updateFocusNode() {
    
    let results = self.sceneView.hitTest(self.focusPoint, types: [.existingPlaneUsingExtent])
    
    if results.count == 1 {
      if let match = results.first {
        let t = match.worldTransform
        self.focusNode.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
        self.gameState = .swipeToPlay
      }
    } else {
      self.gameState = .pointToSurface
    }
  }
  
  func createARPlaneNode(planeAnchor: ARPlaneAnchor, color: UIColor) -> SCNNode {
    
    // 1 - Create plane geometry using anchor extents
    let planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                 height: CGFloat(planeAnchor.extent.z))
    
    // 2 - Create meterial with just a diffuse color
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = "PokerDice.scnassets/Textures/Surface_DIFFUSE.png" //color
    planeGeometry.materials = [planeMaterial]
    
    // 3 - Create plane node
    let planeNode = SCNNode(geometry: planeGeometry)
    planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    
    return planeNode
  }
  
  func updateARPlaneNode(planeNode: SCNNode, planeAchor: ARPlaneAnchor) {
    
    // 1 - Update plane geometry with planeAnchor details
    let planeGeometry = planeNode.geometry as! SCNPlane
    planeGeometry.width = CGFloat(planeAchor.extent.x)
    planeGeometry.height = CGFloat(planeAchor.extent.z)
    
    // 2 - Update plane position
    planeNode.position = SCNVector3Make(planeAchor.center.x, 0, planeAchor.center.z)
  }
  
  func removeARPlaneNode(node: SCNNode) {
    for childNode in node.childNodes {
      childNode.removeFromParentNode()
    }
  }
}

extension ViewController : ARSCNViewDelegate {
  
  // MARK: - SceneKit Management
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      //self.statusLabel.text = self.trackingStatus
      self.updateStatus()
      self.updateFocusNode()
    }
  }
  
  // MARK: - Session State Management
  
  func session(_ session: ARSession,
               cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .notAvailable:
      self.trackingStatus = "Tacking:  Not available!"
      break
    case .normal:
      self.trackingStatus = "Tracking: All Good!"
      break
    case .limited(let reason):
      switch reason {
      case .excessiveMotion:
        self.trackingStatus = "Tracking: Limited due to excessive motion!"
        break
      case .insufficientFeatures:
        self.trackingStatus = "Tracking: Limited due to insufficient features!"
        break
      case .initializing:
        self.trackingStatus = "Tracking: Initializing..."
        break
      case .relocalizing:
        self.trackingStatus = "Tracking: Relocalizing..."
        break
      }
    }
  }
  
  // MARK: - Session Error Managent
  
  func session(_ session: ARSession,
               didFailWithError error: Error) {
    self.trackingStatus = "AR Session Failure: \(error)"
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    self.trackingStatus = "AR Session Was Interrupted!"
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    self.trackingStatus = "AR Session Interruption Ended"
  }
  
  // MARK: - Plane Management
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    DispatchQueue.main.async {
      
      let planeNode = self.createARPlaneNode(planeAnchor: planeAnchor,
                                             color: UIColor.yellow.withAlphaComponent(0.5))
      node.addChildNode(planeNode)
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    DispatchQueue.main.async {
      self.updateARPlaneNode(
        planeNode: node.childNodes[0],
        planeAchor: planeAnchor)
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    guard anchor is ARPlaneAnchor else { return }
    DispatchQueue.main.async {
      self.removeARPlaneNode(node: node)
    }
  }
}

