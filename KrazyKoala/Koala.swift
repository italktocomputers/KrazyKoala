/*

Copyright (c) 2021 Andrew Schools

*/

import SpriteKit
import Foundation
import AVFoundation
import AudioToolbox

class Koala : Entity, IEntity {    
    var lives = 5
    var canThrow = true
    var numRedRocks = 0
    var numBlueRocks = 0
    var numFireballs = 0
    var lastTimeThrown = Date()
    var koalaAnimationWalkingSpeed = 0.2
    var shield: SKSpriteNode?
    var hasShield = false
    var shieldLife = 0.0
    var shieldAdded = Date()
    
    var gameScene: GameScene
    var difficulty: String
    
    var jumpWav = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
    var hitWav = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
    
    var helpers = Helpers()
    
    init(gameScene: GameScene, difficulty: String) {
        self.gameScene = gameScene
        self.difficulty = difficulty
        
        let texture = SKTexture(imageNamed: "koala_walk01")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        if difficulty == "Hard" || difficulty == "Krazy" {
            self.lives = 3
        }
        
        self.position = CGPoint(x: 150, y: 400)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        self.physicsBody?.restitution = 0
        self.physicsBody?.allowsRotation = false // node should always be upright
        self.physicsBody?.categoryBitMask = koalaCategory
        self.physicsBody?.contactTestBitMask = antCategory | flyCategory | groundCategory
        self.physicsBody?.collisionBitMask = groundCategory
        self.zPosition = 3
        self.name = "koala"
        
        self.gameScene.addChild(self)
        self.walk()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(currentTime: CFTimeInterval) {
        let now = NSDate()
        
        // they can only throw every half seconds
        let interval = now.timeIntervalSince(self.lastTimeThrown)
        
        if interval > 0.5 {
            self.canThrow = true
        }
        
        let intervalShield = Double(now.timeIntervalSince(self.shieldAdded))
        
        if intervalShield >= self.shieldLife {
            self.removeShield()
        }
    }
    
    func contact(scene: GameScene, other: SKNode) {
        switch other.name {
            case "bluerock-package" :
                scene.run(scene.energizeWav)
                self.numBlueRocks = self.numBlueRocks + 3
                scene.updateBlueRockIndicator(total: self.numBlueRocks)
            case "redrock-package" :
                scene.run(scene.energizeWav)
                self.numRedRocks = self.numRedRocks + 3
                scene.updateRedRockIndicator(total: self.numRedRocks)
            case "fireball-package" :
                scene.run(scene.energizeWav)
                self.numFireballs = self.numFireballs + 3
                scene.updateFireballIndicator(total: self.numFireballs)
            case "bomb-package":
                scene.run(scene.energizeWav)
                scene.killAllBadGuys()
            case "ground":
                self.walk()
            case "fly":
                if (!hasShield) {
                    self.takeHit()
                }
                scene.addLifeBar(numLives: self.lives)
            case "ant":
                if (self.physicsBody?.velocity.dy)! < CGFloat(0.0) {
                    self.applyBounce() // jumped on top of ant so koala will bounce
                    let ant = other as! Ant
                    if ant.antType == 0 {
                        self.addShield()
                    }
                    //self.applyBlackAntStompAchievement()
                }
                else {
                    if (!hasShield) {
                        self.takeHit()
                    }
                    self.gameScene.addLifeBar(numLives: self.lives)
                }
            default:
                print("here")
            }
    }
    
    func addShield() {
        if !self.hasShield {
            let shield = SKSpriteNode(imageNamed:"shield")
            shield.xScale = 0.1
            shield.yScale = 0.1
            shield.zPosition = 102
            shield.name = "shield"
            self.addChild(shield)
            self.shield = shield
            self.shieldAdded = Date()
            self.hasShield = true
        }
        
        self.shieldLife = self.shieldLife + 5.0
    }
    
    func removeShield() {
        self.hasShield = false
        if let shield = self.shield {
            self.removeChildren(in: [shield])
        }
        self.shieldLife = 0.0
    }
    
    func walk() {
        // show walk animation
        let walk1 = SKTexture(imageNamed: "koala_walk01")
        let walk2 = SKTexture(imageNamed: "koala_walk02")
        let walkAni = SKAction.animate(with: [walk1, walk2], timePerFrame: self.koalaAnimationWalkingSpeed)
        
        self.run(SKAction.repeatForever(walkAni), withKey:"walk")
    }
    
    func kill() {
        self.removeAction(forKey: "walk")
        self.removeAction(forKey: "jump")
        
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
        
        let fade = SKAction.fadeOut(withDuration: 2)
        self.run(fade)
        
        let rotate = SKAction.rotate(byAngle: 10, duration: 2)
        self.run(rotate)
        
        let implode = SKAction.scale(to: 50, duration: 2)
        self.run(implode)
    }
    
    func jump() {
        // remove walking animation
        self.removeAction(forKey: "walk")
        
        // show jump animation
        let jump = SKAction.setTexture(SKTexture(imageNamed: "koala_jump"))
        self.run(jump)
        
        // play jump sound
        self.run(self.jumpWav, withKey:"jump")
        
        // apply jump
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
    }
    
    func takeHit() {
        // good guy and bad guy collide so play sound
        self.gameScene.run(self.hitWav)
        
        if self.helpers.getVibrationSetting() == true {
            // vibrate to notify user of contact
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        let node = SKSpriteNode(imageNamed:"bang")
        node.position = CGPoint(x: self.position.x+20, y: self.position.y)
        node.name = "bang"
        node.zPosition = 103
        
        let image1 = SKTexture(imageNamed: "bang")
        let removeNode = SKAction.removeFromParent()
        let images = SKAction.animate(with: [image1], timePerFrame: 0.2)
        
        let deQueue = SKAction.run({()
            let index = self.gameScene.poofQueue.firstIndex(of: node)
            if index != nil {
                self.gameScene.poofQueue.remove(at: index!)
            }
        })
        
        node.run(SKAction.repeatForever(SKAction.sequence([images, deQueue, removeNode])))
        
        self.gameScene.addChild(node)
        
        self.lives-=1 // take away a life
        
        // save highest kill streak before resetting
        if self.gameScene.clearStreak > self.gameScene.gameHighclearStreak {
            self.gameScene.gameHighclearStreak = self.gameScene.clearStreak
        }
        
        // reset kill streak
        self.gameScene.clearStreak = 0
        self.gameScene.showclearStreakLabel()
        
        // update life bar
        self.gameScene.addLifeBar(numLives: self.lives)
        
        if self.lives == 0 {
            // game over!
            self.gameScene.gameOver()
        }
    }
    
    func applyBounce() {
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
    }
    
    func throwRock() {
        if self.numRedRocks > 0 {
            self.throwRedRocks()
            self.numRedRocks-=1
            self.gameScene.updateRedRockIndicator(total: self.numRedRocks)
            self.lastTimeThrown = Date()
        }
        else if self.numBlueRocks > 0 {
            self.throwBlueRock()
            self.numBlueRocks-=1
            self.gameScene.updateBlueRockIndicator(total: self.numBlueRocks)
            self.lastTimeThrown = Date()
        }
        else if self.numFireballs > 0 {
            self.throwFireball()
            self.numFireballs-=1
            self.gameScene.updateFireballIndicator(total: self.numFireballs)
            self.lastTimeThrown = Date()
        }
        else {
            if self.canThrow == true {
                self.throwPlainRock()
                self.canThrow = false
                self.lastTimeThrown = Date()
            }
        }
    }
    
    private func throwPlainRock() {
        self.gameScene.addChild(
            Rock(
                pointStart: self.position,
                pointEnd: CGPoint(x: self.gameScene.xOfRight()+200, y: self.position.y),
                gameScene: self.gameScene
            )
        )
    }
    
    private func throwFireball() {
        self.gameScene.addChild(
            Fireball(
                pointStart: self.position,
                pointEnd: CGPoint(x: self.gameScene.xOfRight()+200, y: self.position.y),
                gameScene: self.gameScene
            )
        )
    }
    
    private func throwRedRocks() {
        // a spray of rocks
        for i in 1...10 {
            self.gameScene.addChild(
                RedRock(
                    pointStart: self.position,
                    pointEnd: CGPoint(x: self.position.x+CGFloat(1000), y: self.position.y-500+CGFloat(i*100)),
                    gameScene: self.gameScene
                )
            )
        }
    }
    
    private func throwBlueRock() {
        // throw 5 rocks, one after another
        // blue rocks travel much faster than normal and red rocks
        let group = Int.random(in: 1..<100)
        self.gameScene.addChild(
            BlueRock(
                pointStart: self.position,
                pointEnd: CGPoint(x: self.gameScene.xOfRight()+200, y: self.position.y),
                speed: TimeInterval(0.1),
                gameScene: self.gameScene,
                group: group
            )
        )
        
        self.gameScene.addChild(
            BlueRock(
                pointStart: self.position,
                pointEnd: CGPoint(x: self.gameScene.xOfRight()+200, y: self.position.y),
                speed: TimeInterval(0.2),
                gameScene: self.gameScene,
                group: group
            )
        )
        
        self.gameScene.addChild(
            BlueRock(
                pointStart: self.position,
                pointEnd: CGPoint(x: self.gameScene.xOfRight()+200, y: self.position.y),
                speed: TimeInterval(0.3),
                gameScene: self.gameScene,
                group: group
            )
        )
        
        self.gameScene.addChild(
            BlueRock(
                pointStart: self.position,
                pointEnd: CGPoint(x: self.gameScene.xOfRight()+200, y: self.position.y),
                speed: TimeInterval(0.4),
                gameScene: self.gameScene,
                group: group
            )
        )
        
        self.gameScene.addChild(
            BlueRock(
                pointStart: self.position,
                pointEnd: CGPoint(x: self.gameScene.xOfRight()+200, y: self.position.y),
                speed: TimeInterval(0.5),
                gameScene: self.gameScene,
                group: group
            )
        )
    }

}
