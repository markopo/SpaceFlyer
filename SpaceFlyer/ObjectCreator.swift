//
//  ObjectCreator.swift
//  SteamPunkFlyer
//
//  Created by Marko Poikkimäki on 2019-03-01.
//  Copyright © 2019 Marko Poikkimäki. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class ObjectCreator {
    
    public func createEnemy(gameTime: Int, h:Int) -> Enemy {
        
        let enemyAtlas = SKTextureAtlas(named: "Sprites")
        var enemyFrames: [SKTexture] = []
        let numImages = enemyAtlas.textureNames.count
        
        for i in 1...numImages {
            let textureName = "enemy1fly_\(i)"
            enemyFrames.append(enemyAtlas.textureNamed(textureName))
        }
        
        let image = enemyFrames[0]
        let lowValue: Int = -Int(h/2)
        let highValue: Int = Int(h/2)
        let randomDistribution = GKRandomDistribution(lowestValue: lowValue, highestValue: highValue)
        let enemy = Enemy(texture: image) // "enemy"
        
        enemy.size = CGSize(width: 98, height: 98)
        enemy.position = CGPoint(x: 350, y: randomDistribution.nextInt())
        enemy.name = "enemy"
        enemy.zPosition = 1
        
        var velX = -(50 + gameTime)
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
        
        return enemy   
    }
    
    public func createDiamond(gameTime: Int, h: Int) -> SKNode {
        
        let lowValue: Int = -Int(h/2)
        let highValue: Int = Int(h/2)
        let randomDistribution = GKRandomDistribution(lowestValue: lowValue, highestValue: highValue)
        let diamond = SKSpriteNode(imageNamed: "Coin2")   //"diamond"
        diamond.size = CGSize(width: 55, height: 55)
        diamond.position = CGPoint(x: 350, y: randomDistribution.nextInt())
        diamond.name = "diamond"
        diamond.zPosition = 1
        
        var velY = 0
        var velX = -35
        
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
        
        return diamond
    }
    
    public func createBullet(x: Int, y: Int) -> SKNode {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.size = CGSize(width: 21, height: 12)
        bullet.position = CGPoint(x: x, y: y)
        bullet.name = "bullet"
        bullet.zPosition = 1
        
        bullet.physicsBody = SKPhysicsBody(texture: bullet.texture!, size: bullet.size)
        bullet.physicsBody?.angularVelocity = 0
        bullet.physicsBody?.velocity = CGVector(dx: +225, dy: 0)
        bullet.physicsBody?.linearDamping = 0
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.contactTestBitMask = 2
        bullet.physicsBody?.collisionBitMask = 2
        bullet.physicsBody?.categoryBitMask = 2
        
        return bullet 
    }
    
    public func createPlayer(xRange: SKRange, yRange: SKRange) -> SKSpriteNode {
        let player = SKSpriteNode(imageNamed: "player-rocket.png")
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
        player.constraints = [ SKConstraint.positionX(xRange), SKConstraint.positionY(yRange)  ]
        
        return player
    }
}
