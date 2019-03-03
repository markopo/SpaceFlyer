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
    
    public let objectCreator = ObjectCreator()
    
    private var player = Player(imageNamed: "player-rocket.png")
    private var touchingPlayer = false
    private var gameTimer: Timer?
    private let interval: Double = 1.25
    private var gameTime: Int = 1
    private var numOfenemys = 1
    
    private let lifeLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    private let gameOverLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    private let music = SKAudioNode(fileNamed: "cyborg-ninja.mp3")

    private let motionManager = CMMotionManager()
    
    private let offSetX: CGFloat = 42.0
    private let offSetY: CGFloat = 35.0
    
    var score = 0 {
        didSet {
              scoreLabel.text = "Score: \(score)"

                if(score >= 1000) {
                    gameWon()
                }
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
    
    private func gameWon() {
        gameTime = 1
        gameOverLabel.text = "YOU WIN!"
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
    
    
    
    private func createBullet() {
        let x = Int(player.position.x) + Int(player.size.width/2) + 25
        let y = Int(player.position.y)
        let bullet = objectCreator.createBullet(x: x, y: y)
        addChild(bullet)
    }
    
    @objc
    func gameInterval() {
        gameTime += 1
        let h = Int(self.scene!.size.height)
        
        let enemy = objectCreator.createEnemy(gameTime: gameTime, h: h)
        addChild(enemy)
        
        let diamond = objectCreator.createDiamond(gameTime: gameTime, h: h)
        addChild(diamond)
        
        
    }
    
    func startGame() {
        let xRange = SKRange(lowerLimit: -(self.size.width/2) + offSetX, upperLimit: (self.size.width/2) - offSetX)
        let yRange = SKRange(lowerLimit: -(self.size.height/2) + offSetY, upperLimit: (self.size.height/2) - offSetY)
        player = objectCreator.createPlayer(xRange: xRange, yRange: yRange)
        
        addBackground()
        addParticles()
        addPlayer()
        addScoreLabel()
        addLifeLabel()
        addMusic()
        
        motionManager.startAccelerometerUpdates()
        
        gameTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(gameInterval), userInfo: nil, repeats: true)
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
        
      //  if(tappedNodes.contains(player)) {
            createBullet()
      //  }
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
                let changeY = CGFloat(accelerometerData.acceleration.y) * 16
                let changeX = CGFloat(accelerometerData.acceleration.x) * 8

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
        
        // Enemy hit
        if (nodeA == player && nodeB.name == "enemy") {
            enemyHit(enemy: nodeB)
            playerHit()
        }
        else if(nodeA.name == "enemy" && nodeB == player){
            enemyHit(enemy: nodeA)
            playerHit()
        }
        
        // Bullet hit
        if(nodeA.name == "bullet" && nodeB.name == "enemy"){
            enemyHit(enemy: nodeB)
            bulletHit(bullet: nodeA)
        }
        else if(nodeA.name == "enemy" && nodeB.name == "bullet") {
            enemyHit(enemy: nodeA)
            bulletHit(bullet: nodeB)
        }
        
        if((nodeA.name == "bullet" && nodeB.name == "diamond") || (nodeA.name == "diamond" && nodeB.name == "bullet")){
            let x = Int(nodeA.position.x)
            let y = Int(nodeA.position.y)
            
            nodeA.removeFromParent()
            nodeB.removeFromParent()

            if(score > 0) {
                score -= 1
            }
            
            playExplosion(x: x, y: y)
        }
        
        
        // Diamond hit
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
                
                if(node.name == "enemy") {
                    if(score > 0){
                        score -= 1
                    }
                }
            }
            
            if(node.name == "bullet" && !self.intersects(node)){
               // print("remove bullet")
                node.removeFromParent()
            }
        }
    }
    
    func collectdiamond(node: SKNode) {
        
        score += 3
        node.removeFromParent()
        
        playCollectSound()
    }
    
    func bulletHit(bullet: SKNode) {
         playExplosion(x: Int(bullet.position.x), y: Int(bullet.position.y))
         bullet.removeFromParent()
    }
    
    func enemyHit(enemy: SKNode){
        score += 1
        
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
            
            print("hit")
            theEnemy.life -= 1
            
            if(theEnemy.life <= 0) {
                theEnemy.removeFromParent()
            }
        }
        
    }
    
    func playerHit() {
   
        if(life > 0) {
            life -= 1
        }
      
        playExplosion(x: Int(player.position.x), y: Int(player.position.y))
        
        if(life == 0) {
            player.removeFromParent()
            gameOverLabel.isHidden = false
            gameOver()
        }
    }
    
    func playExplosion(x: Int, y: Int) {
        let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        run(explosionSound)
        
        guard let explosion = SKEmitterNode(fileNamed: "Explosion.sks") else { return }
        explosion.position = CGPoint(x: x, y: y)
        explosion.name = "explosion"
        explosion.targetNode = self
        self.addChild(explosion)
        
        self.run(SKAction.wait(forDuration: 1.25)) {
            explosion.removeFromParent()
        }
    }
    
    func playCollectSound() {
        let bonusSound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
        run(bonusSound)
    }
}
