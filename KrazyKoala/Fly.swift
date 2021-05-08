/*

Copyright (c) 2021 Andrew Schools

*/

import SpriteKit
import Foundation

class Fly : Entity, IEntity {
    var gameScene: GameScene
    var difficulty: String
    
    init(gameScene: GameScene, difficulty: String) {
        self.gameScene = gameScene
        self.difficulty = difficulty
        
        let texture = SKTexture(imageNamed: "fly_1")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        let yStart = self.gameScene.randRange(
            lower: UInt32(self.gameScene.yOfGround()+30),
            upper: UInt32(self.gameScene.yOfTop())
        )
        
        self.position = CGPoint(x: self.gameScene.xOfRight(), y: CGFloat(yStart))
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        self.physicsBody?.restitution = 0
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = flyCategory
        self.physicsBody?.contactTestBitMask = koalaCategory | rockCategory
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.affectedByGravity = false
        self.name = "fly"
        self.zPosition = 101
        
        // how fast each move is performed
        var duration = TimeInterval(self.gameScene.flyDurationKrazy)
        if self.difficulty == "Easy" {
            duration = TimeInterval(self.gameScene.flyDurationEasy)
        }
        else if self.difficulty == "Hard" {
            duration = TimeInterval(self.gameScene.flyDurationHard)
        }
        
        // as time progresses, so does the length a fly will stay on the scene
        var moves:[SKAction] = []
        for _ in 1...4+self.gameScene.level {
            let randX = self.gameScene.randRange(
                lower: 0,
                upper: UInt32(self.gameScene.xOfRight())
            )
            let randY = self.gameScene.randRange(
                lower: UInt32(self.gameScene.yOfGround()+30),
                upper: UInt32(self.gameScene.yOfTop())
            )
            moves.append(
                SKAction.move(
                    to: CGPoint(x: Double(randX), y: Double(randY)),
                    duration: duration
                )
            )
        }
        
        let deQueue = SKAction.run({()
            //println("deQueue fly")
            let index = self.gameScene.nodeQueue.index(of: self)
            self.gameScene.nodeQueue.remove(at: index!)
        })
        
        moves.append(SKAction.moveTo(x: -100, duration: duration)) // fly will exit scene
        moves.append(deQueue) // remove from node Queue
        moves.append(SKAction.removeFromParent()) // remove from scene
        
        self.run(SKAction.sequence(moves), withKey:"moves")
        
        // flying animation
        let image1 = SKTexture(imageNamed: "fly_1")
        let image2 = SKTexture(imageNamed: "fly_2")
        
        var animationSpeed = self.gameScene.flyAnimationSpeedEasy
        if self.difficulty == "Hard" {
            animationSpeed = self.gameScene.flyAnimationSpeedHard
        }
        else if self.difficulty == "Krazy" {
            animationSpeed = self.gameScene.flyAnimationSpeedKrazy
        }
        
        let images = SKAction.animate(with: [image1, image2], timePerFrame: animationSpeed)
        
        self.run(SKAction.repeatForever(images), withKey:"images")
    }
    
    func kill() {
        self.gameScene.addPoof(loc: self.position)
        self.removeFromParent()
        
        let index = self.gameScene.nodeQueue.index(of: self)
        
        if index != nil {
            let result = self.gameScene.nodeQueue.remove(at: index!)
            if result is SKSpriteNode {
                // We need to wrap this because multiple rocks from a spray can hit
                // the same fly and we don't want to give them more than one point
                // per kill
                self.gameScene.fliesKilled+=1
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
    
    func update(currentTime: CFTimeInterval) {
        if self.position.x <= -200 {
            self.removeFromParent()
        }
    }
    
    func contact(scene: GameScene, other: SKNode) {
        switch other.name {
            case "rock", "bluerock", "redrock", "koala", "fireball" :
                self.kill()
            default:
                print("here")
            }
    }
}
