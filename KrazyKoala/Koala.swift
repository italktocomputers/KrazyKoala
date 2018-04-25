/*
The MIT License (MIT)

Copyright (c) 2016 Andrew Schools

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import SpriteKit
import Foundation
import AVFoundation
import AudioToolbox

class Koala : Entity {
    var lives = 5
    var canThrow = true
    var numRedRocks = 0
    var numBlueRocks = 0
    var lastTimeThrown = Date()
    var koalaAnimationWalkingSpeed = 0.2
    
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
    
    override func update(currentTime: CFTimeInterval) {
        let now = NSDate()
        
        // they can only throw every half seconds
        let interval = now.timeIntervalSince(self.lastTimeThrown)
        
        if interval > 0.5 {
            self.canThrow = true
        }
    }
    
    func walk() {
        // show walk animation
        let walk1 = SKTexture(imageNamed: "koala_walk01")
        let walk2 = SKTexture(imageNamed: "koala_walk02")
        let walkAni = SKAction.animate(with: [walk1, walk2], timePerFrame: self.koalaAnimationWalkingSpeed)
        
        self.run(SKAction.repeatForever(walkAni), withKey:"walk")
    }
    
    func die() {
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
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 250))
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
            let index = self.gameScene.poofQueue.index(of: node)
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
        self.gameScene.addChild(
            BlueRock(
                pointStart: self.position,
                pointEnd: CGPoint(x: self.gameScene.xOfRight()+200, y: self.position.y),
                speed: TimeInterval(0.1),
                gameScene: self.gameScene
            )
        )
        
        self.gameScene.addChild(
            BlueRock(
                pointStart: self.position,
                pointEnd: CGPoint(x: self.gameScene.xOfRight()+200, y: self.position.y),
                speed: TimeInterval(0.2), gameScene: self.gameScene
            )
        )
        
        self.gameScene.addChild(
            BlueRock(
                pointStart: self.position,
                pointEnd: CGPoint(x: self.gameScene.xOfRight()+200, y: self.position.y),
                speed: TimeInterval(0.3),
                gameScene: self.gameScene
            )
        )
        
        self.gameScene.addChild(
            BlueRock(
                pointStart: self.position,
                pointEnd: CGPoint(x: self.gameScene.xOfRight()+200, y: self.position.y),
                speed: TimeInterval(0.4),
                gameScene: self.gameScene
            )
        )
        
        self.gameScene.addChild(
            BlueRock(
                pointStart: self.position,
                pointEnd: CGPoint(x: self.gameScene.xOfRight()+200, y: self.position.y),
                speed: TimeInterval(0.5),
                gameScene: self.gameScene
            )
        )
    }

}
