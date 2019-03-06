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
import ARKit

class PortalViewController: UIViewController {

  @IBOutlet weak var crosshair: UIView!
  @IBOutlet var sceneView: ARSCNView?
  @IBOutlet weak var messageLabel: UILabel?
  @IBOutlet weak var sessionStateLabel: UILabel?
  
  var portalNode: SCNNode? = nil
  var isPortalPlaced = false
  var debugPlanes: [SCNNode] = []
  var viewCenter: CGPoint {
    let viewBounds = view.bounds
    return CGPoint(x: viewBounds.width / 2.0, y: viewBounds.height / 2.0)
  }
  
  let POSITION_Y: CGFloat = -0.25
  let POSITION_Z: CGFloat = -SURFACE_LENGTH*0.5
  
  let DOOR_WIDTH:CGFloat = 1.0
  let DOOR_HEIGHT:CGFloat = 2.4
  
  override func viewDidLoad() {
    super.viewDidLoad()
    resetLabels()
    runSession()
  }

  func runSession() {
    let configuration = ARWorldTrackingConfiguration.init()
    configuration.planeDetection = .horizontal
    configuration.isLightEstimationEnabled = true

    sceneView?.session.run(configuration,
                           options: [.resetTracking, .removeExistingAnchors])  

    #if DEBUG
      sceneView?.debugOptions = [SCNDebugOptions.showFeaturePoints]
    #endif

    sceneView?.delegate = self
  }
  
  func resetLabels() {
    messageLabel?.alpha = 1.0
    messageLabel?.text = "Move the phone around and allow the app to find a plane. You will see a yellow horizontal plane."
    sessionStateLabel?.alpha = 0.0
    sessionStateLabel?.text = ""
  }
  
  func showMessage(_ message: String, label: UILabel, seconds: Double) {
    label.text = message
    label.alpha = 1
    
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
      if label.text == message {
        label.text = ""
        label.alpha = 0
      }
    }
  }
  
  func removeAllNodes() {
    removeDebugPlanes()
    self.portalNode?.removeFromParentNode()
    self.isPortalPlaced = false
  }
  
  func removeDebugPlanes() {
    for debugPlaneNode in self.debugPlanes {
      debugPlaneNode.removeFromParentNode()
    }
    self.debugPlanes = []
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let hit = sceneView?.hitTest(viewCenter, types: [.existingPlaneUsingExtent]).first {
      sceneView?.session.add(anchor: ARAnchor.init(transform: hit.worldTransform))
    }
  }
  
  func makePortal() -> SCNNode {
    let portal = SCNNode()
    
    let floorNode = makeFloorNode()
    floorNode.position = SCNVector3(0, POSITION_Y, POSITION_Z)
    portal.addChildNode(floorNode)
    
    let ceilingNode = makeCeilingNode()
    ceilingNode.position = SCNVector3(0,
                                      POSITION_Y+WALL_HEIGHT,
                                      POSITION_Z)
    portal.addChildNode(ceilingNode)

    let farWallNode = makeWallNode()
    farWallNode.eulerAngles = SCNVector3(0, 90.0.degreesToRadians, 0)
    farWallNode.position = SCNVector3(0,
                                      POSITION_Y+WALL_HEIGHT*0.5,
                                      POSITION_Z-SURFACE_LENGTH*0.5)
    portal.addChildNode(farWallNode)
    
    let rightSideWallNode = makeWallNode(maskLowerSide: true)
    rightSideWallNode.eulerAngles = SCNVector3(0, 180.0.degreesToRadians, 0)
    rightSideWallNode.position = SCNVector3(WALL_LENGTH*0.5,
                                            POSITION_Y+WALL_HEIGHT*0.5,
                                            POSITION_Z)
    portal.addChildNode(rightSideWallNode)
    
    let leftSideWallNode = makeWallNode(maskLowerSide: true)
    leftSideWallNode.position = SCNVector3(-WALL_LENGTH*0.5,
                                           POSITION_Y+WALL_HEIGHT*0.5,
                                           POSITION_Z)
    portal.addChildNode(leftSideWallNode)
    
    addDoorway(node: portal)
    placeLightSource(rootNode: portal)
    return portal
  }
  
  func addDoorway(node: SCNNode) {
    let halfWallLength: CGFloat = WALL_LENGTH * 0.5
    let frontHalfWallLength: CGFloat = (WALL_LENGTH - DOOR_WIDTH) * 0.5
    
    
    let rightDoorSideNode = makeWallNode(length: frontHalfWallLength)
    rightDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
    rightDoorSideNode.position = SCNVector3(halfWallLength - 0.5 * DOOR_WIDTH,
                                            POSITION_Y+WALL_HEIGHT*0.5,
                                            POSITION_Z+SURFACE_LENGTH*0.5)
    node.addChildNode(rightDoorSideNode)
    
    let leftDoorSideNode = makeWallNode(length: frontHalfWallLength)
    leftDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
    leftDoorSideNode.position = SCNVector3(-halfWallLength + 0.5 * frontHalfWallLength,
                                           POSITION_Y+WALL_HEIGHT*0.5,
                                           POSITION_Z+SURFACE_LENGTH*0.5)
    node.addChildNode(leftDoorSideNode)
    
    let aboveDoorNode = makeWallNode(length: DOOR_WIDTH, height: WALL_HEIGHT - DOOR_HEIGHT)
    aboveDoorNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
    aboveDoorNode.position = SCNVector3(0,
                                        POSITION_Y+(WALL_HEIGHT-DOOR_HEIGHT)*0.5+DOOR_HEIGHT,
                                        POSITION_Z+SURFACE_LENGTH*0.5)
    node.addChildNode(aboveDoorNode)
  }
  
  func placeLightSource(rootNode: SCNNode) {
    let light = SCNLight()
    light.intensity = 10
    light.type = .omni
    let lightNode = SCNNode()
    lightNode.light = light
    lightNode.position = SCNVector3(0,
                                   POSITION_Y+WALL_HEIGHT,
                                   POSITION_Z)
    rootNode.addChildNode(lightNode)
  }
  
}

extension PortalViewController: ARSCNViewDelegate {
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    DispatchQueue.main.async {
      if let planeAnchor = anchor as? ARPlaneAnchor, !self.isPortalPlaced {
        #if DEBUG
          let debugPlaneNode = createPlaneNode(
            center: planeAnchor.center,
            extent: planeAnchor.extent)
          node.addChildNode(debugPlaneNode)
          self.debugPlanes.append(debugPlaneNode)
        #endif
        self.messageLabel?.alpha = 1.0
        self.messageLabel?.text = "Tap on the detected horizontal plane to place the portal"
      }
      else if !self.isPortalPlaced {
        
        self.portalNode = self.makePortal()
        if let portal = self.portalNode {
          node.addChildNode(portal)
          self.isPortalPlaced = true
          
          self.removeDebugPlanes()
          self.sceneView?.debugOptions = []
          
          DispatchQueue.main.async {
            self.messageLabel?.text = ""
            self.messageLabel?.alpha = 0
          }
        }
        
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer,
                didUpdate node: SCNNode,
                for anchor: ARAnchor) {
    DispatchQueue.main.async {
      if let planeAnchor = anchor as? ARPlaneAnchor,
        node.childNodes.count > 0,
        !self.isPortalPlaced {
        updatePlaneNode(node.childNodes[0],
                        center: planeAnchor.center,
                        extent: planeAnchor.extent)
      }
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer,
                updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      if let _ = self.sceneView?.hitTest(self.viewCenter,
                                         types: [.existingPlaneUsingExtent]).first {
        self.crosshair.backgroundColor = UIColor.green
      } else {
        self.crosshair.backgroundColor = UIColor.lightGray
      }
    }
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    guard let label = self.sessionStateLabel else { return }
    showMessage(error.localizedDescription, label: label, seconds: 3)
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    guard let label = self.sessionStateLabel else { return }
    showMessage("Session interrupted", label: label, seconds: 3)
  }

  func sessionInterruptionEnded(_ session: ARSession) {
    guard let label = self.sessionStateLabel else { return }
    showMessage("Session resumed", label: label, seconds: 3)
    
    DispatchQueue.main.async {
      self.removeAllNodes()
      self.resetLabels()
    }
    runSession()
  }
  
}
