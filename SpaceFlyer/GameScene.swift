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
    private let interval: Double = 1.0
    private var gameTime: Int = 1
    private var numOfAsteroids = 1
    
    private let lifeLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    private let gameOverLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    private let music = SKAudioNode(fileNamed: "cyborg-ninja.mp3")
   
    
    var score = 0 {
        didSet {
              scoreLabel.text = "Score: \(score)"
        }
    }
    
    var life = 10 {
        didSet {
            lifeLabel.text = "Life: \(life)"
            let alpha = CGFloat(life)/10

            if(alpha > 0.3) {
                player.run(SKAction.fadeAlpha(to: alpha, duration: 1))
            }
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
        player.alpha = 1.0
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
        scoreLabel.fontSize = 16
        scoreLabel.position.y = (self.size.height / 2) - 15
        scoreLabel.position.x = (-(self.size.width / 2))+80
        scoreLabel.horizontalAlignmentMode = .right
        score = 0
        addChild(scoreLabel)
    }
    
    private func addLifeLabel() {
        lifeLabel.zPosition = 2
        lifeLabel.fontSize = 16
        lifeLabel.position.y = (self.size.height / 2) - 15
        lifeLabel.position.x = (-(self.size.width / 2))+160
        lifeLabel.horizontalAlignmentMode = .right
        life = 10
        addChild(lifeLabel)
    }
    
    private func addMusic() {
        addChild(music)
        music.run(SKAction.play())
        
    }
    
    private func gameOver() {
        gameTime = 1
        gameOverLabel.text = "GAME OVER!"
        gameOverLabel.name = "game_over"
        gameOverLabel.position.x = 0
        gameOverLabel.position.y = 0
        gameOverLabel.zPosition = 3
        
        if(self.childNode(withName: "game_over") == nil) {
            addChild(gameOverLabel)
        }
        
        music.run(SKAction.pause())
    }
    
    
    
    @objc
    private func createAsteroid() {
        
        gameTime += 1
        let lowValue = -100 - gameTime
        let highValue = 100 + gameTime
        let randomDistribution = GKRandomDistribution(lowestValue: lowValue, highestValue: highValue)
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.position = CGPoint(x: 350, y: randomDistribution.nextInt())
        asteroid.name = "asteroid"
        asteroid.zPosition = 1
        addChild(asteroid)
        
        var velX = -100 - gameTime
        var velY = gameTime % 2 == 0 ? gameTime : -gameTime
        
        if(gameTime % 5 == 0) {
            velX *= 2
            velY = 0
        }
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.velocity = CGVector(dx: velX, dy: velY)
        asteroid.physicsBody?.linearDamping = 0
        asteroid.physicsBody?.affectedByGravity = false
        asteroid.physicsBody?.contactTestBitMask = 1
        asteroid.physicsBody?.categoryBitMask = 0
        
       //  print("asteroid: T:\(gameTime) V: \(velX) L: \(lowValue) H: \(highValue)")

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
        
        var velY = 0
        var velX = -50
        
        if(gameTime % 8 == 0) {
            let randNum = Int(arc4random_uniform(100))
            velY = gameTime % 2 == 0 ? -randNum : randNum
            velX = -20
        }
        
        var angDamp: CGFloat = 0.0
        if(gameTime % 12 == 0){
            angDamp = 0.5
        }
        
        energy.physicsBody = SKPhysicsBody(texture: energy.texture!, size: energy.size)
        energy.physicsBody?.velocity = CGVector(dx: velX, dy: velY)
        energy.physicsBody?.linearDamping = 0
        energy.physicsBody?.linearDamping = angDamp
        energy.physicsBody?.affectedByGravity = false
        energy.physicsBody?.contactTestBitMask = 1
        energy.physicsBody?.categoryBitMask = 0
    }
    
    func startGame() {
        addBackground()
        addParticles()
        addPlayer()
        addScoreLabel()
        addLifeLabel()
        addMusic()
        
        gameTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(createAsteroid), userInfo: nil, repeats: true)
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
            playerHit()
        }
        else if(nodeA.name == "asteroid" && nodeB == player){
            playerHit()
        }
      
        
        if(nodeA == player && nodeB.name == "energy"){
            collectEnergy(node: nodeB)
        }
        else if(nodeA.name == "energy" && nodeB == player) {
            collectEnergy(node: nodeA)
        }
        
    }
    
    func collectEnergy(node: SKNode) {
        score += 1
        node.removeFromParent()
        
        if(score % 5 == 0) {
            if(life < 10) {
                life += 1
            }
        }
        
        let bonusSound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
        run(bonusSound)
    }
    
    func playerHit() {
   
        if(life > 0) {
            life -= 1
        }
      
        let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        run(explosionSound)
        
        if(life == 0) {
            player.removeFromParent()
            gameOverLabel.isHidden = false
            gameOver()
        }
    }
}
