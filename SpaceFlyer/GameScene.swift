//
//  GameScene.swift
//  SpaceFlyer
//
//  Created by Marko Poikkimäki on 2019-02-19.
//  Copyright © 2019 Marko Poikkimäki. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private let player = SKSpriteNode(imageNamed: "player-rocket.png")
    private var touchingPlayer = false
    private var gameTimer: Timer?
    private let interval: Double = 2.5
    private var gameTime: Int = 1
    private var numOfAsteroids = 1
    
    private let lifeLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    private let gameOverLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    private let music = SKAudioNode(fileNamed: "cyborg-ninja.mp3")

    
    private let motionManager = CMMotionManager()
   
    
    var score = 0 {
        didSet {
              scoreLabel.text = "Score: \(score)"
        }
    }
    
    var life = 100 {
        didSet {
            lifeLabel.text = "Life: \(life)"
            let alpha = CGFloat(life)/100

            if(alpha > 0.3) {
                player.run(SKAction.fadeAlpha(to: alpha, duration: 1))
            }
        }
    }
    
    
    private func addBackground() {
        let background = SKSpriteNode(imageNamed: "background_all.png") // "space.jpg"
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
        player.physicsBody?.angularVelocity = 0
        player.physicsBody?.allowsRotation = false 
        player.physicsBody?.categoryBitMask = 3
        player.physicsBody?.collisionBitMask = 3
        player.physicsBody?.contactTestBitMask = 3
        player.physicsBody?.affectedByGravity = false
        
        let xRange = SKRange(lowerLimit: -self.size.width/2+10, upperLimit: self.size.width/2-10)
        let yRange = SKRange(lowerLimit: -self.size.height/2+10, upperLimit: self.size.height/2-10)
        
        player.constraints = [ SKConstraint.positionX(xRange), SKConstraint.positionY(yRange)  ]
        
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
        life = 100
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
        
        for node in self.children {
            if(node.name == "asteroid" || node.name == "energy") {
                node.removeFromParent()
            }
        }
        
        gameTimer?.invalidate()
        music.run(SKAction.pause())
    }
    
    
    
    @objc
    private func createAsteroid() {
        
        let enemyAtlas = SKTextureAtlas(named: "Sprites")
        var enemyFrames: [SKTexture] = []
        let numImages = enemyAtlas.textureNames.count
        
        for i in 1...numImages {
            let textureName = "enemy1fly_\(i)"
            enemyFrames.append(enemyAtlas.textureNamed(textureName))
        }
        
        let image = enemyFrames[0]
        gameTime += 1
        let h = self.scene!.size.height
        let lowValue: Int = -Int(h/2)
        let highValue: Int = Int(h/2)
        let randomDistribution = GKRandomDistribution(lowestValue: lowValue, highestValue: highValue)
        let asteroid = SKSpriteNode(texture: image) // "asteroid"
        
        asteroid.size = CGSize(width: 98, height: 98)
        asteroid.position = CGPoint(x: 350, y: randomDistribution.nextInt())
        asteroid.name = "asteroid"
        asteroid.zPosition = 1
        addChild(asteroid)

        var velX = -50 - gameTime
        var velY = gameTime % 2 == 0 ? gameTime : -gameTime
        
        if(gameTime % 5 == 0) {
            velX *= 2
            velY = 0
        }
        
        
        asteroid.physicsBody?.angularVelocity = 0
        asteroid.physicsBody?.allowsRotation = false
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.velocity = CGVector(dx: velX, dy: velY)
        asteroid.physicsBody?.linearDamping = 0
        asteroid.physicsBody?.affectedByGravity = false
        asteroid.physicsBody?.contactTestBitMask = 2
        asteroid.physicsBody?.collisionBitMask = 2
        asteroid.physicsBody?.categoryBitMask = 2
        
        asteroid.run(SKAction.repeatForever(
                     SKAction.animate(with: enemyFrames,
                                     timePerFrame: 0.1,
                                     resize: false,
                                     restore: true)),
                             withKey:"enemyFlying")
       //  print("asteroid: T:\(gameTime) V: \(velX) L: \(lowValue) H: \(highValue)")

        createEnergy()
    }
    
    @objc
    private func createEnergy() {
        
        let h = self.scene!.size.height
        let lowValue: Int = -Int(h/2)
        let highValue: Int = Int(h/2)
        let randomDistribution = GKRandomDistribution(lowestValue: lowValue, highestValue: highValue)
        let energy = SKSpriteNode(imageNamed: "Coin2")   //"energy"
        energy.size = CGSize(width: 55, height: 55)
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
        energy.physicsBody?.contactTestBitMask = 2
        energy.physicsBody?.collisionBitMask = 2
        energy.physicsBody?.categoryBitMask = 2
    }
    
    func startGame() {
        addBackground()
        addParticles()
        addPlayer()
        addScoreLabel()
        addLifeLabel()
        addMusic()
        
        motionManager.startAccelerometerUpdates()
        
        gameTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(createAsteroid), userInfo: nil, repeats: true)
        gameTimer?.fire()
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
        
        if(tappedNodes.contains(gameOverLabel)) {
            self.removeAllChildren()
            gameOverLabel.isHidden = true
            startGame()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingPlayer = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
            // remove asteroids out of screen
            removeNodesOutOfScreen()

            if let accelerometerData = motionManager.accelerometerData {
                let changeY = CGFloat(accelerometerData.acceleration.y) * 10
                let changeX = CGFloat(accelerometerData.acceleration.x) * 10

                player.position.x -= changeX
                player.position.y += changeY
            }
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
    
    private func removeNodesOutOfScreen() {
        for node in self.children {
            if((node.name == "asteroid" || node.name == "energy") && !self.intersects(node) && node.position.x <= (-self.position.x/2)){
               // print("removed: \(node.name!)")
                node.removeFromParent()
            }
            
        }
    }
    
    func collectEnergy(node: SKNode) {
        score += 1
        node.removeFromParent()
        
        if(life <= 100) {
            life += 1
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
