//
//  GameScene.swift
//  SpaceFlyer
//
//  Created by Marko Poikkimäki on 2019-02-19.
//  Copyright © 2019 Marko Poikkimäki. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private let player = SKSpriteNode(imageNamed: "player-rocket.png")
    private var touchingPlayer = false
    private var gameTimer: Timer?
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    private let gameOverLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    
    var score = 0 {
        didSet {
              scoreLabel.text = "Score: \(score)"
        }
    }
    
    
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
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.affectedByGravity = false
        addChild(player)
        
        physicsWorld.contactDelegate = self
    }
    
    private func addScoreLabel() {
        scoreLabel.zPosition = 2
        scoreLabel.position.y = 300
        score = 0
        addChild(scoreLabel)
    }
    
    private func gameOver() {
        gameOverLabel.text = "GAME OVER!"
        gameOverLabel.name = "game_over"
        gameOverLabel.position.x = 0
        gameOverLabel.position.y = 0
        gameOverLabel.zPosition = 3
        
        if(self.childNode(withName: "game_over") == nil) {
            addChild(gameOverLabel)
        }
        
        
    }
    
    @objc
    private func createAsteroid() {
        let randomDistribution = GKRandomDistribution(lowestValue: -100, highestValue: 100)
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.position = CGPoint(x: 350, y: randomDistribution.nextInt())
        asteroid.name = "asteroid"
        asteroid.zPosition = 1
        addChild(asteroid)
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
        asteroid.physicsBody?.linearDamping = 0
        asteroid.physicsBody?.affectedByGravity = false
        asteroid.physicsBody?.contactTestBitMask = 1
        asteroid.physicsBody?.categoryBitMask = 0
        
        createEnergy()
    }
    
    @objc
    private func createEnergy() {
        let randomDistribution = GKRandomDistribution(lowestValue: -300, highestValue: 300)
        let energy = SKSpriteNode(imageNamed: "energy")
        energy.position = CGPoint(x: 350, y: randomDistribution.nextInt())
        energy.name = "energy"
        energy.zPosition = 1
        addChild(energy)
        
        energy.physicsBody = SKPhysicsBody(texture: energy.texture!, size: energy.size)
        energy.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
        energy.physicsBody?.linearDamping = 0
        energy.physicsBody?.affectedByGravity = false
        energy.physicsBody?.contactTestBitMask = 1
        energy.physicsBody?.categoryBitMask = 0
    }
    
    func startGame() {
        addBackground()
        addParticles()
        addPlayer()
        addScoreLabel()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.35, target: self, selector: #selector(createAsteroid), userInfo: nil, repeats: true)
    }
    
    override func didMove(to view: SKView) {
        startGame()
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
        
        if(tappedNodes.contains(gameOverLabel)) {
            removeAllChildren();
            gameOverLabel.isHidden = true
            startGame()
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        
        if nodeA == player && nodeB.name == "asteroid" {
            // print("player -> asteroid")
            playerHit(node: nodeB)
        }
        else if(nodeA.name == "asteroid" && nodeB == player){
            // print("asteroid -> player")
            playerHit(node: nodeA)
        }
      
        
        if(nodeA == player && nodeB.name == "energy"){
          //  print("player -> energy")
            score += 1
            nodeB.removeFromParent()
        }
        else if(nodeA.name == "energy" && nodeB == player) {
           // print("energy -> player")
            score += 1
            nodeA.removeFromParent()
        }
        
    }
    
    func playerHit(node: SKNode) {
        player.removeFromParent()
        gameOverLabel.isHidden = false
        gameOver()
    }
}
