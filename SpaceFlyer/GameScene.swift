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
    private var numOfenemys = 1
    
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
        
        addRocketFire()

        physicsWorld.contactDelegate = self

    }
    
    private func addRocketFire() {
        if (player.childNode(withName: "rocket_fire") == nil) {
            guard let emitter = SKEmitterNode(fileNamed: "RocketFire.sks") else { return }
            emitter.position = CGPoint(x: -(player.size.width/2+15), y: 0)
            emitter.name = "rocket_fire"
            emitter.targetNode = player
            player.addChild(emitter)
        }
    }
    
    private func removeRocketFire() {
         if (player.childNode(withName: "rocket_fire") != nil) {
            player.removeAllChildren()
        }
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
            if(node.name == "enemy" || node.name == "diamond") {
                node.removeFromParent()
            }
        }
        
        gameTimer?.invalidate()
        music.run(SKAction.pause())
    }
    
    
    
    @objc
    private func createEnemy() {
        
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
        let enemy = Enemy(texture: image) // "enemy"
        
        enemy.size = CGSize(width: 98, height: 98)
        enemy.position = CGPoint(x: 350, y: randomDistribution.nextInt())
        enemy.name = "enemy"
        enemy.zPosition = 1
        addChild(enemy)

        var velX = -50 - gameTime
        var velY = 0 // gameTime % 2 == 0 ? gameTime : -gameTime
        
        if(gameTime % 5 == 0) {
            velX *= 2
            velY = 0
        }
        
        enemy.physicsBody?.angularVelocity = 0
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
        enemy.physicsBody?.velocity = CGVector(dx: velX, dy: velY)
      //  enemy.physicsBody?.linearDamping = 0
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.contactTestBitMask = 2
        enemy.physicsBody?.collisionBitMask = 2
        enemy.physicsBody?.categoryBitMask = 2
        
        enemy.run(SKAction.repeatForever(
                     SKAction.animate(with: enemyFrames,
                                     timePerFrame: 0.1,
                                     resize: false,
                                     restore: true)),
                             withKey:"enemyFlying")
       //  print("enemy: T:\(gameTime) V: \(velX) L: \(lowValue) H: \(highValue)")

        createDiamond()
    }
    
    @objc
    private func createDiamond() {
        
        let h = self.scene!.size.height
        let lowValue: Int = -Int(h/2)
        let highValue: Int = Int(h/2)
        let randomDistribution = GKRandomDistribution(lowestValue: lowValue, highestValue: highValue)
        let diamond = SKSpriteNode(imageNamed: "Coin2")   //"diamond"
        diamond.size = CGSize(width: 55, height: 55)
        diamond.position = CGPoint(x: 350, y: randomDistribution.nextInt())
        diamond.name = "diamond"
        diamond.zPosition = 1
        addChild(diamond)
        
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
        
        diamond.physicsBody = SKPhysicsBody(texture: diamond.texture!, size: diamond.size)
        diamond.physicsBody?.velocity = CGVector(dx: velX, dy: velY)
        diamond.physicsBody?.linearDamping = 0
        diamond.physicsBody?.linearDamping = angDamp
        diamond.physicsBody?.affectedByGravity = false
        diamond.physicsBody?.contactTestBitMask = 2
        diamond.physicsBody?.collisionBitMask = 2
        diamond.physicsBody?.categoryBitMask = 2
    }
    
    private func createBullet() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.size = CGSize(width: 21, height: 12)
        let x = Int(player.position.x) + Int(player.size.width/2) + 25
        let y = Int(player.position.y)
        bullet.position = CGPoint(x: x, y: y)
        bullet.name = "bullet"
        bullet.zPosition = 1
        
        bullet.physicsBody = SKPhysicsBody(texture: bullet.texture!, size: bullet.size)
        bullet.physicsBody?.angularVelocity = 0
        bullet.physicsBody?.velocity = CGVector(dx: +200, dy: 0)
        bullet.physicsBody?.linearDamping = 0
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.contactTestBitMask = 2
        bullet.physicsBody?.collisionBitMask = 2
        bullet.physicsBody?.categoryBitMask = 2
        
        addChild(bullet)
        
    }
    
    func startGame() {
        addBackground()
        addParticles()
        addPlayer()
        addScoreLabel()
        addLifeLabel()
        addMusic()
        
        motionManager.startAccelerometerUpdates()
        
        gameTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
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
        
        if(tappedNodes.contains(player)) {
            createBullet()
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
        
            // remove enemys out of screen
            removeNodesOutOfScreen()

            if let accelerometerData = motionManager.accelerometerData {
                let changeY = CGFloat(accelerometerData.acceleration.y) * 10
                let changeX = CGFloat(accelerometerData.acceleration.x) * 10

                if(changeX < 0){
                    addRocketFire()
                }
                else {
                    removeRocketFire()
                }
                
                player.position.x -= changeX
                player.position.y += changeY
            }
    }
        
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        
        if (nodeA == player && nodeB.name == "enemy") {
            enemyHit(enemy: nodeB)
            playerHit()
        }
        else if(nodeA.name == "enemy" && nodeB == player){
            enemyHit(enemy: nodeA)
            playerHit()
        }
        
        if(nodeA.name == "bullet" && nodeB.name == "enemy"){
            enemyHit(enemy: nodeB)
            bulletHit(bullet: nodeA)
        }
        else if(nodeA.name == "enemy" && nodeB.name == "bullet") {
            enemyHit(enemy: nodeA)
            bulletHit(bullet: nodeB)
        }
        
        if(nodeA == player && nodeB.name == "diamond"){
            collectdiamond(node: nodeB)
        }
        else if(nodeA.name == "diamond" && nodeB == player) {
            collectdiamond(node: nodeA)
        }
        
    }
    
    private func removeNodesOutOfScreen() {
        for node in self.children {
            if((node.name == "enemy" || node.name == "diamond") && !self.intersects(node) && node.position.x <= (-self.position.x/2)){
               // print("removed: \(node.name!)")
                node.removeFromParent()
            }
            
        }
    }
    
    func collectdiamond(node: SKNode) {
        score += 1
        node.removeFromParent()
        
        if(life <= 100) {
            life += 1
        }
        
        let bonusSound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
        run(bonusSound)
    }
    
    func bulletHit(bullet: SKNode) {
         playExplosion()
        
        guard let explosion = SKEmitterNode(fileNamed: "Explosion.sks") else { return }
        explosion.position = CGPoint(x: Int(bullet.position.x), y: Int(bullet.position.y))
        explosion.name = "explosion"
        explosion.targetNode = self
        self.addChild(explosion)
        
        bullet.removeFromParent()

        self.run(SKAction.wait(forDuration: 1.25)) {
           explosion.removeFromParent()
        }

    }
    
    func enemyHit(enemy: SKNode){
        let enemyAtlas = SKTextureAtlas(named: "Sprites-1")
        var enemyFrames: [SKTexture] = []
        let numImages = enemyAtlas.textureNames.count
        
        for i in 1...numImages {
            let textureName = "enemy1die_\(i)"
            enemyFrames.append(enemyAtlas.textureNamed(textureName))
        }
        
        let image = enemyFrames[0]
        enemy.run(SKAction.setTexture(image), withKey: "enemy_die")
      
        enemy.run(SKAction.repeatForever(
            SKAction.animate(with: enemyFrames,
                             timePerFrame: 0.1,
                             resize: false,
                             restore: true)),
            withKey:"enemyDying")
        
        if let velX = enemy.physicsBody?.velocity.dx {
            enemy.physicsBody?.velocity = CGVector(dx: velX, dy: -50)
        }
        
        if (enemy.childNode(withName: "smoke") == nil) {
            guard let emitter = SKEmitterNode(fileNamed: "Smoke.sks") else { return }
            emitter.position = CGPoint(x: 5.5, y: 20)
            emitter.name = "smoke"
            emitter.targetNode = enemy
            enemy.addChild(emitter)
        }
        
        if let theEnemy = enemy as? Enemy {
            
            if(theEnemy.isDying == false) {
                theEnemy.isDying = true
            }
            else {
                theEnemy.removeFromParent()
            }
        }
        
    }
    
    func playerHit() {
   
        if(life > 0) {
            life -= 1
        }
      
        playExplosion()
        
        if(life == 0) {
            player.removeFromParent()
            gameOverLabel.isHidden = false
            gameOver()
        }
    }
    
    func playExplosion() {
        let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        run(explosionSound)
    }
}
