/*

Copyright (c) 2021 Andrew Schools

*/

import SpriteKit
import Foundation

class FireballItem : Entity, IEntity {
    var gameScene: GameScene
    var difficulty: String
    
    init(gameScene: GameScene, difficulty: String) {
        self.gameScene = gameScene
        self.difficulty = difficulty
        
        let texture = SKTexture(imageNamed: "fireball-package")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        let randomY = self.gameScene.randRange(
            lower: UInt32(self.gameScene.yOfGround()+100),
            upper: UInt32(self.gameScene.yMaxPlacementOfItem())
        )
        
        self.position = CGPoint(x: self.gameScene.xOfRight(), y: CGFloat(randomY))
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        self.physicsBody?.restitution = 0
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = itemCategory
        self.physicsBody?.contactTestBitMask = koalaCategory
        self.physicsBody?.collisionBitMask = 0
        self.xScale = 0.2
        self.yScale = 0.2
        self.name = "fireball-package"
        self.zPosition = 100
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(currentTime: CFTimeInterval) {
        self.position = CGPoint(x: self.position.x - CGFloat(self.gameScene.foregroundSpeed), y: self.position.y)
        if self.position.x <= -200 {
            self.removeFromParent()
            let index = self.gameScene.nodeQueue.firstIndex(of: self)
            self.gameScene.nodeQueue.remove(at: index!)
        }
    }
    
    func kill() {
        self.removeFromParent()
    }
    
    func contact(scene: GameScene, other: SKNode) {
        switch other.name {
            case "koala" :
                self.kill()
            default:
                print("here")
            }
    }
}
