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

class Ant: Entity {
    var gameScene: GameScene
    var difficulty: String
    var gameCenter: GameCenterController
    var helpers: Helpers
    
    init(gameScene: GameScene, difficulty: String) {
        self.gameScene = gameScene
        self.difficulty = difficulty
        self.gameCenter = GameCenterController()
        self.helpers = Helpers()
        
        let antTypeInt = Double(self.gameScene.randRange(0, upper: 1))
        var antTypeStr = ""
        
        if (antTypeInt == 1) {
            antTypeStr = "_black"
        }
        
        let texture = SKTexture(imageNamed:"ant_walk_1"+antTypeStr)
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.position = CGPoint(x: self.gameScene.xOfRight(), y: self.gameScene.yOfGround()+5)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.size.width, height: self.size.height))
        self.physicsBody?.restitution = 0
        self.physicsBody?.dynamic = true
        self.physicsBody?.allowsRotation = false // node should always be upright
        self.physicsBody?.categoryBitMask = antCategory
        self.physicsBody?.contactTestBitMask = koalaCategory | rockCategory
        self.physicsBody?.collisionBitMask = groundCategory
        self.name = "ant"
        self.zPosition = 3
        
        let deQueue = SKAction.runBlock({()
            self.gameScene.nodeQueue.removeObject(self)
        })
        
        var duration = NSTimeInterval(self.gameScene.antDurationKrazy)
        if self.difficulty == "Easy" {
            duration = NSTimeInterval(self.gameScene.antDurationEasy)
        } else if self.difficulty == "Hard" {
            duration = NSTimeInterval(self.gameScene.antDurationHard)
        }

        var actions: [SKAction] = []
        if (antTypeStr == "") {
            // red ants will move once, and the dart towards koala
            // making them more dangerous than black ants
            actions.append(SKAction.moveToX(500, duration: 2))
            actions.append(SKAction.moveToX(-100, duration: 1.0))
        } else {
            // black ant
            actions.append(SKAction.moveToX(-200, duration: duration))
        }
        
        actions.append(deQueue)
        actions.append(SKAction.removeFromParent())
        
        self.runAction(SKAction.sequence(actions))
        
        // walking animation
        let move1 = SKTexture(imageNamed: "ant_walk_1"+antTypeStr)
        let move2 = SKTexture(imageNamed: "ant_walk_2"+antTypeStr)
        
        var animationSpeed = self.gameScene.antAnimationSpeedEasy
        if self.difficulty == "Hard" {
            animationSpeed = self.gameScene.antAnimationSpeedHard
        } else if self.difficulty == "Krazy" {
            animationSpeed = self.gameScene.antAnimationSpeedKrazy
        }
        
        let moves = SKAction.animateWithTextures([move1, move2], timePerFrame: animationSpeed)
        
        self.runAction(SKAction.repeatActionForever(moves), withKey:"move")
    }
    
    override func kill() {
        self.gameScene.addPoof(self.position)
        self.removeFromParent()
        
        if self.gameScene.nodeQueue.removeObject(self) == true {
            // we need to wrap this because multiple rocks from a
            // spray can hit the same ant and we don't want to
            // give them more than one point per kill
            self.gameScene.antsKilled++
            self.gameScene.lastKill = NSDate()
            self.gameScene.score++
            self.gameScene.clearStreak++
            self.gameScene.updateScoreBoard(self.gameScene.score)
            self.gameScene.showclearStreakLabel()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(currentTime: CFTimeInterval) {
        if self.position.x <= -200 {
            self.removeFromParent()
        }
    }
}

