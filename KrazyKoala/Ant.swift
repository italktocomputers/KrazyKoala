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
        
        let antTypeInt = Double(self.gameScene.randRange(lower: 0, upper: 1))
        var antTypeStr = ""
        
        if (antTypeInt == 1) {
            antTypeStr = "_black"
        }
        
        let texture = SKTexture(imageNamed:"ant_walk_1"+antTypeStr)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        self.position = CGPoint(x: self.gameScene.xOfRight(), y: self.gameScene.yOfGround()+5)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        self.physicsBody?.restitution = 0
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false // node should always be upright
        self.physicsBody?.categoryBitMask = antCategory
        self.physicsBody?.contactTestBitMask = koalaCategory | rockCategory
        self.physicsBody?.collisionBitMask = groundCategory
        self.name = "ant"
        self.zPosition = 3
        
        let deQueue = SKAction.run({()
            let index = self.gameScene.nodeQueue.index(of: self)
            self.gameScene.nodeQueue.remove(at: index!)
        })
        
        var duration = TimeInterval(self.gameScene.antDurationKrazy)
        if self.difficulty == "Easy" {
            duration = TimeInterval(self.gameScene.antDurationEasy)
        }
        else if self.difficulty == "Hard" {
            duration = TimeInterval(self.gameScene.antDurationHard)
        }

        var actions: [SKAction] = []
        if (antTypeStr == "") {
            // red ants will move once, and the dart towards koala
            // making them more dangerous than black ants
            actions.append(SKAction.moveTo(x: 500, duration: 2))
            actions.append(SKAction.moveTo(x: -100, duration: 1.0))
        }
        else {
            // black ant
            actions.append(SKAction.moveTo(x: -200, duration: duration))
        }
        
        actions.append(deQueue)
        actions.append(SKAction.removeFromParent())
        
        self.run(SKAction.sequence(actions))
        
        // walking animation
        let move1 = SKTexture(imageNamed: "ant_walk_1"+antTypeStr)
        let move2 = SKTexture(imageNamed: "ant_walk_2"+antTypeStr)
        
        var animationSpeed = self.gameScene.antAnimationSpeedEasy
        if self.difficulty == "Hard" {
            animationSpeed = self.gameScene.antAnimationSpeedHard
        }
        else if self.difficulty == "Krazy" {
            animationSpeed = self.gameScene.antAnimationSpeedKrazy
        }
        
        let moves = SKAction.animate(with: [move1, move2], timePerFrame: animationSpeed)
        
        self.run(SKAction.repeatForever(moves), withKey:"move")
    }
    
    override func kill() {
        self.gameScene.addPoof(loc: self.position)
        self.removeFromParent()
        
        let index = self.gameScene.nodeQueue.index(of: self)
        
        if index != nil {
            let result = self.gameScene.nodeQueue.remove(at: index!)
            if result is SKSpriteNode {
                // We need to wrap this because multiple rocks from a spray can hit
                // the same ant and we don't want to give them more than one point
                // per kill
                self.gameScene.antsKilled+=1
                self.gameScene.lastKill = Date()
                self.gameScene.score+=1
                self.gameScene.clearStreak+=1
                self.gameScene.updateScoreBoard(score: self.gameScene.score)
                self.gameScene.showclearStreakLabel()
            }
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

