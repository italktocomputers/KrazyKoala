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

class Fly : Entity {
    var gameScene: GameScene
    var difficulty: String
    
    init(gameScene: GameScene, difficulty: String) {
        self.gameScene = gameScene
        self.difficulty = difficulty
        
        let texture = SKTexture(imageNamed: "fly_1")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        let yStart = self.gameScene.randRange(UInt32(self.gameScene.yOfGround()+30), upper: UInt32(self.gameScene.yOfTop()))
        
        self.position = CGPoint(x: self.gameScene.xOfRight(), y: CGFloat(yStart))
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.size.width, height: self.size.height))
        self.physicsBody?.restitution = 0
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = flyCategory
        self.physicsBody?.contactTestBitMask = koalaCategory | rockCategory
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.affectedByGravity = false
        self.name = "fly"
        self.zPosition = 101
        
        // how fast each move is performed
        var duration = NSTimeInterval(self.gameScene.flyDurationKrazy)
        if self.difficulty == "Easy" {
            duration = NSTimeInterval(self.gameScene.flyDurationEasy)
        } else if self.difficulty == "Hard" {
            duration = NSTimeInterval(self.gameScene.flyDurationHard)
        }
        
        // as time progresses, so does the length a fly will stay on the scene
        var moves:[SKAction] = []
        for _ in 1...4+self.gameScene.level {
            let randX = self.gameScene.randRange(0, upper: UInt32(self.gameScene.xOfRight()))
            let randY = self.gameScene.randRange(UInt32(self.gameScene.yOfGround()+30), upper: UInt32(self.gameScene.yOfTop()))
            moves.append(SKAction.moveTo(CGPoint(x: Double(randX), y: Double(randY)), duration: duration))
        }
        
        let deQueue = SKAction.runBlock({()
            //println("deQueue fly")
            self.gameScene.nodeQueue.removeObject(self)
        })
        
        moves.append(SKAction.moveToX(-100, duration: duration)) // fly will exit scene
        moves.append(deQueue) // remove from node Queue
        moves.append(SKAction.removeFromParent()) // remove from scene
        
        self.runAction(SKAction.sequence(moves), withKey:"moves")
        
        // flying animation
        let image1 = SKTexture(imageNamed: "fly_1")
        let image2 = SKTexture(imageNamed: "fly_2")
        
        var animationSpeed = self.gameScene.flyAnimationSpeedEasy
        if self.difficulty == "Hard" {
            animationSpeed = self.gameScene.flyAnimationSpeedHard
        } else if self.difficulty == "Krazy" {
            animationSpeed = self.gameScene.flyAnimationSpeedKrazy
        }
        
        let images = SKAction.animateWithTextures([image1, image2], timePerFrame: animationSpeed)
        
        self.runAction(SKAction.repeatActionForever(images), withKey:"images")
    }
    
    override func kill() {
        self.gameScene.addPoof(self.position)
        self.removeFromParent()
        
        if self.gameScene.nodeQueue.removeObject(self) == true {
            // we need to wrap this because multiple rocks from a
            // spray can hit the same fly and we don't want to
            // give them more than one point per kill
            self.gameScene.fliesKilled++
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
