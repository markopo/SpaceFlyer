//
//  GameViewController.swift
//  SpaceFlyer
//
//  Created by Marko Poikkimäki on 2019-02-19.
//  Copyright © 2019 Marko Poikkimäki. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
         
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.size = view.bounds.size
                
                // Present the scene
                view.presentScene(scene)
            }
            
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
