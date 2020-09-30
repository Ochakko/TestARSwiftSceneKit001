//
//  ViewController.swift
//  TestARSwiftSceneKit001
//
//  Created by BakeNeco (Ochakko) on 2018/12/20.
//  Copyright © 2018-2020 BakeNeco (Ochakko). All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation


class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    var modelinittransform: SCNMatrix4!
    
    var danceAnimation: SCNAnimationPlayer!
    var currentAnimIndex:Int = 0
    var danceAnimationArray:[SCNAnimationPlayer?] = []
    let CharacterNode1:SCNNode = SCNNode()

    let sndpath1 = Bundle.main.bundleURL.appendingPathComponent("1.wav")
    var sndPlayer1 = AVAudioPlayer()
    let sndpath2 = Bundle.main.bundleURL.appendingPathComponent("2.wav")
    var sndPlayer2 = AVAudioPlayer()
    let sndpath3 = Bundle.main.bundleURL.appendingPathComponent("3.wav")
    var sndPlayer3 = AVAudioPlayer()
    let sndpath4 = Bundle.main.bundleURL.appendingPathComponent("4.wav")
    var sndPlayer4 = AVAudioPlayer()
    let sndpath = Bundle.main.bundleURL.appendingPathComponent("13439.mp3")
    var sndPlayer = AVAudioPlayer()
  
    var motionChangeFlag:Bool = false
    
    var timer : Timer?
    var starttime = Date()
    
    let dancename:[String] = ["idle", "dance1", "dance2", "dance3", "dance4"]
    let frameleng: [Double] = [48.0, 20.0, 20.0, 30.0, 60.0]
    let timerInterval = 0.016 //timeIntervalではないtime(r)Interval  60fps : 1 / 60 = 0.016...
    
    @objc func timerInterrupt(_ timer:Timer){
        changeToIdle()
    }
    
    func getAnimationPlayer(scenename: String) -> SCNAnimationPlayer {
        let scene = SCNScene( named: scenename )!
        // find top level animation
        var animationPlayer: SCNAnimationPlayer! = nil
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
            }
        }
        return animationPlayer
    }

    
    fileprivate func soundPlayer(player:inout AVAudioPlayer, path: URL, count: Int){
        do {
            player = try AVAudioPlayer(contentsOf: path, fileTypeHint: nil)
            player.numberOfLoops = count
            player.play()
        } catch {
            print("エラーが発生しました。")
        }
    }

    func PlayAnimation(animno: Int){
        for tmpno in 0..<5{
            let tmpname = self.dancename[tmpno]
            self.CharacterNode1.animationPlayer(forKey: tmpname)!.stop()
        }
        
        let animname = self.dancename[animno]
        if animno != 0 {
            self.CharacterNode1.animationPlayer(forKey: animname)!.animation.repeatCount = 1
        } else {
            self.CharacterNode1.animationPlayer(forKey: animname)!.animation.repeatCount = -1
        }
        
        self.CharacterNode1.animationPlayer(forKey: animname)!.animation.timeOffset = 0
        danceAnimation.animation.isRemovedOnCompletion = false
        //self.CharacterNode1.animationPlayer(forKey: animname)!.animation.usesSceneTimeBase = false;
        
        //self.CharacterNode1.animationPlayer(forKey: animname)!.animation.animationDidStop = { (animation: SCNAnimation, obj: SCNAnimatable, finished: Bool) in
        //    if finished == true {
        //        self.PlayAnimation(animno: 0)
         //   }
        //}
        
        self.CharacterNode1.animationPlayer(forKey: animname)!.play()
        currentAnimIndex = animno
        self.starttime = Date()
    }
    
    @IBAction func motionButton1(_ sender: Any) {
        
        PlayAnimation(animno: 1)
        soundPlayer(player: &sndPlayer1, path: sndpath1, count: 0)
    }
    
    @IBAction func motionButton2(_ sender: Any) {
        PlayAnimation(animno: 2)
        soundPlayer(player: &sndPlayer2, path: sndpath2, count: 0)
    }
    
    @IBAction func motionButton3(_ sender: Any) {
        PlayAnimation(animno: 3)
        soundPlayer(player: &sndPlayer3, path: sndpath3, count: 0)
    }
    
    @IBAction func motionButton4(_ sender: Any) {
        PlayAnimation(animno: 4)
        soundPlayer(player: &sndPlayer4, path: sndpath4, count: 0)
   
    }
    
    
    //func updatePositionAndOrientationOf(_ node: SCNNode, withPosition position: SCNVector3, relativeTo referenceNode: SCNNode) {
    func updatePositionAndOrientationOf(_ node: SCNNode, withPosition position: SCNVector3) {
        
        //let referenceNodeTransform = matrix_float4x4(referenceNode.transform)
        
        guard let pointOfView = sceneView.pointOfView else { return }
        let referenceNodeTransform = matrix_float4x4(pointOfView.transform)
    
        // Setup a translation matrix with the desired position
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = position.x
        translationMatrix.columns.3.y = position.y
        translationMatrix.columns.3.z = position.z
        
        // Combine the configured translation matrix with the referenceNode's transform to get the desired position AND orientation
        let updatedTransform = matrix_multiply(referenceNodeTransform, translationMatrix)
        node.transform = SCNMatrix4(updatedTransform)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        //let modelscene = SCNScene(named: "art.scnassets/openrdb.scn")!
        let modelscene = SCNScene(named: "art.scnassets/colladadae_bucho_idle_bunki_1.scn")!
        
        modelscene.rootNode.removeAllAnimations()
        modelscene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                child.removeAllAnimations()
                //stop.pointee = true
            }
        }
                
        //アニメーションを配列に読み込む
        
        danceAnimationArray.append(getAnimationPlayer(scenename: "art.scnassets/colladadae_bucho_idle_bunki.dae")) //idle
        danceAnimationArray.append(getAnimationPlayer(scenename: "art.scnassets/colladadae_bucho_pickdown_bunki.dae")) //dance1
        danceAnimationArray.append(getAnimationPlayer(scenename: "art.scnassets/colladadae_bucho_pickup_bunki.dae")) //dance2
        danceAnimationArray.append(getAnimationPlayer(scenename: "art.scnassets/colladadae_bucho_pickdance2_bunki.dae")) //dance3
        danceAnimationArray.append(getAnimationPlayer(scenename: "art.scnassets/colladadae_bucho_long_bunki.dae")) //dance4

        
        //カメラの設定
        //scene.rootNode.scale = SCNVector3(0.01, 0.01, 0.01)
        //let CharacterNode1 = SCNNode()
        let camera1 = SCNCamera()
        CharacterNode1.name = "CharacterNode1"
        camera1.name = "camera1"
        camera1.fieldOfView = 45.0
        camera1.usesOrthographicProjection = false
        camera1.zNear = 1.0
        camera1.zFar = 5.0
        camera1.categoryBitMask = 0
        CharacterNode1.camera = camera1
        //cameraNode1.scale = SCNVector3(0.1, 0.1, 0.1)
        //modelscene.rootNode.scale = SCNVector3(0.1, 0.1, 0.1)
        
        modelscene.rootNode.scale = SCNVector3(0.0005, 0.0005, 0.0005)
        //let modeljoint1 = modelscene.rootNode.childNode(withName: "JOINT-0", recursively: true)!
        //modeljoint1.scale = SCNVector3(0.1, 0.1, 0.1)
        let modelposition = SCNVector3(x: 0, y: -0.5, z: -0.5)
        updatePositionAndOrientationOf(CharacterNode1, withPosition: modelposition)
        modelinittransform = CharacterNode1.transform
        
        CharacterNode1.addChildNode(modelscene.rootNode)
        scene.rootNode.addChildNode(CharacterNode1)

        //アニメーションを配列から取りだしてキャラクターのノードに登録
        for animno in 0..<5 {
            danceAnimation = danceAnimationArray[animno]
            let animname = self.dancename[animno]
            danceAnimation.speed = 1
            if animno == 0 {
                danceAnimation.animation.repeatCount = -1
            } else {
                danceAnimation.animation.repeatCount = 1
            }
            danceAnimation.animation.timeOffset = 0
            danceAnimation.stop()
            danceAnimation.animation.isRemovedOnCompletion = false
            //danceAnimation.animation.animationDidStop = { (animation: SCNAnimation, obj: SCNAnimatable, finished: Bool) in
            //    if finished == true {
            //        self.PlayAnimation(animno: 0)
            //    }
            //}
            
            CharacterNode1.addAnimationPlayer(danceAnimation, forKey: animname)
        }
        
        //アイドリングモーション　０番モーションを再生
        PlayAnimation(animno: 0)
        
        //BGM
        soundPlayer(player: &sndPlayer, path: sndpath, count: -1)
        
        
        // Set the scene to the view
        sceneView.scene = scene

        //60fpsで処理するタイマーの登録
        timer = Timer.scheduledTimer(timeInterval: self.timerInterval, target: self, selector: #selector(self.timerInterrupt(_:)), userInfo: nil, repeats: true)
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
    
    
    func changeToIdle() {
        //60fpsでタイマーから呼ばれる
        
        //モーション開始から経った時間
        let motionElapsed = Date().timeIntervalSince(self.starttime)
        
        //モーションの再生時間（終了時間）
        let duration = self.frameleng[self.currentAnimIndex] / (1.0 / self.timerInterval)

        //let animname = self.dancename[self.currentAnimIndex]
        
        //モーションが終了していたらアイドリングモーションに戻す
        if self.currentAnimIndex != 0 {
            if duration <= motionElapsed {
                PlayAnimation(animno: 0)
            }
        }
    }
    
    //func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor)
        //guard let cameraNode1 = sceneView.scene.rootNode.childNode(withName: "cameraNode1", recursively: true) else { return sceneView.scene.rootNode}
        //cameraNode1.transform = modelinittransform!
    //}
    
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
 
        //return cameraNode1
        return sceneView.scene.rootNode
    }

    
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
