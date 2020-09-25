//
//  ViewController.swift
//  por favor
//
//  Created by Bruna Costa on 24/09/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
   // @IBOutlet weak var sessionInfoLabel: UILabel!
    var audioSource: SCNAudioSource!
    var objectNode: SCNNode!
    var planes = [ARPlaneAnchor: SCNNode]()
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        let zombieScene = SCNScene(named: "zombie.scn")
        guard let zombieNode = zombieScene?.rootNode.childNode(withName: "zombieModel", recursively: true) else {
            fatalError("Cannot find 3D Image")
        }
        zombieNode.position = SCNVector3(0,-900,1000)
        scene.rootNode.addChildNode(zombieNode)
        sceneView.scene = scene
        
        objectNode = SCNNode()
        //setUpAudio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        playSound()
        // Run the view's session
        sceneView.session.run(configuration)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Prevent the screen from dimming to avoid interrupting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        objectNode.removeAllAudioPlayers()
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func addPlane(for node: SCNNode, at anchor: ARPlaneAnchor) {
        let planeNode = SCNNode()
        
        let w = CGFloat(anchor.extent.x)
        let h = 0.01
        let l = CGFloat(anchor.extent.z)
        let geometry = SCNBox(width: w, height: CGFloat(h), length: l, chamferRadius: 0.0)
        
        // Translucent white plane
        geometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        planeNode.position = SCNVector3(
            anchor.center.x,
            anchor.center.y,
            anchor.center.z
        )
        planes[anchor] = planeNode
        node.addChildNode(planeNode)
        }
    
    func updatePlane(for anchor: ARPlaneAnchor) {
      // Pull the plane that needs to get updated
      let plane = self.planes[anchor]
      // Update its geometry
        if let geometry = plane?.geometry as? SCNBox {
        geometry.width  = CGFloat(anchor.extent.x)
        geometry.length = CGFloat(anchor.extent.y)
        geometry.height = 0.01
      }

        plane?.position = SCNVector3(anchor.center.x,anchor.center.y,anchor.center.z)
    }
        
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        addPlane(for: node, at: anchor)
            }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
          updatePlane(for: anchor)
        }
    
    func resetTracking(changeMode: Bool = false) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        objectNode.removeFromParentNode()
        objectNode = SCNNode()
    }

    
    func setUpAudio() {
    // Instantiate the audio source
    audioSource = SCNAudioSource(fileNamed: "fireplace.mp3")!
    // As an environmental sound layer, audio should play indefinitely
    audioSource.loops = true
    // Decode the audio from disk ahead of time to prevent a delay in playback
    audioSource.load()
}
    
    func playSound() {
        audioSource = SCNAudioSource(fileNamed: "fireplace.mp3")!
        audioSource.loops = true
        audioSource.load()
        // Ensure there is only one audio player
        objectNode.removeAllAudioPlayers()
        // Create a player from the source and add it to `objectNode`
        objectNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
    }
}

