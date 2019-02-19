//
//  GameViewController.swift
//  HitTheTree
//
//  Created by Brian Advent on 26.04.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var sceneView:SCNView!
    var scene:SCNScene!
    
    var ballNode:SCNNode!
    var selfieStickNode:SCNNode!
    
    var motion = MotionHelper()
    var motionForce = SCNVector3(0,0,0)
    
    var sounds:[String:SCNAudioSource] = [:]
    
    override func viewDidLoad() {
        setupScene()
        setupNodes()
        setupSounds()
    }
    
    func setupScene(){
        sceneView = self.view as! SCNView
        sceneView.allowsCameraControl = true
        scene = SCNScene(named: "art.scnassets/MainScene.scn")
        sceneView.scene = scene
    }
    
    func setupNodes(){
        ballNode = scene.rootNode.childNode(withName: "ball", recursively: true)!
        selfieStickNode = scene.rootNode.childNode(withName: "selfieStick", recursively: true)!
    }
    
    func setupSounds(){
        let sawSound = SCNAudioSource(fileNamed:"chainsaw.wav")!
        let jumpSound = SCNAudioSource(fileNamed:"jump.wav")!
        sawSound.load()
        jumpSound.load()
        sawSound.volume = 0.3
        jumpSound.volume = 0.4
        
        sounds["saw"] = sawSound
        sounds["jump"] = jumpSound
        
        let backgroundMusic = SCNAudioSource(fileNamed: "background.mp3")!
        backgroundMusic.volume = 0.1
        backgroundMusic.loops = true
        backgroundMusic.load()
        
        let musicPlayer = SCNAudioPlayer(source: backgroundMusic)
        ballNode.addAudioPlayer(musicPlayer)
    }
    
    
    @objc func sceneViewTapped(recognizer:UITapGestureRecognizer){
        let location = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if hitResults.count > 0{
            let result = hitResults.first
            if let node = result?.node{
                if node.name == "ball"{
                    let jumpSound = sounds["jump"]!
                    ballNode.runAction(SCNAction.playAudio(jumpSound, waitForCompletion: false))
                    ballNode.physicsBody?.applyForce(SCNVector3(x: 0, y: 4, z:-2), asImpulse: true)
                    
                }
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
