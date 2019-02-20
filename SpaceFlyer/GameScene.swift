//
//  GameScene.swift
//  SpaceFlyer
//
//  Created by Marko Poikkimäki on 2019-02-19.
//  Copyright © 2019 Marko Poikkimäki. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene {
    
    private let player = SKSpriteNode(imageNamed: "player-rocket.png")
    private var touchingPlayer = false
    private var gameTimer: Timer?
    
    
    private func addBackground() {
        let background = SKSpriteNode(imageNamed: "space.jpg")
        background.zPosition = -1
        addChild(background)
    }
    
    private func addParticles() {
        if let particles = SKEmitterNode(fileNamed: "SpaceDust"){
            particles.position.x = 512
            particles.advanceSimulationTime(10)
            addChild(particles)
        }
    }
    
    private func addPlayer() {
        player.position.x = -player.size.width
        player.zPosition = 1
        addChild(player)
    }
    
    @objc
    private func createAsteroid() {
        let randomDistribution = GKRandomDistribution(lowestValue: -200, highestValue: 200)
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.position = CGPoint(x: 350, y: randomDistribution.nextInt())
        asteroid.name = "asteroid"
        asteroid.zPosition = 1
        addChild(asteroid)
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
        asteroid.physicsBody?.linearDamping = 0
        asteroid.physicsBody?.affectedByGravity = false
    }
    
    override func didMove(to view: SKView) {
        addBackground()
        addParticles()
        addPlayer()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.35, target: self, selector: #selector(createAsteroid), userInfo: nil, repeats: true)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if tappedNodes.contains(player) {
            touchingPlayer = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchingPlayer else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingPlayer = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
       
        
    }
}
