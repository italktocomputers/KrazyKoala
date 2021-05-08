/*

Copyright (c) 2021 Andrew Schools

*/

import SpriteKit
import Foundation

class Rock : Entity, IEntity {
    var gameScene: GameScene
    
    init(pointStart: CGPoint, pointEnd: CGPoint, gameScene: GameScene) {
        self.gameScene = gameScene
        
        let texture = SKTexture(imageNamed: "rock")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        self.position = pointStart
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        self.physicsBody?.restitution = 0
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = rockCategory
        self.physicsBody?.contactTestBitMask = flyCategory | antCategory
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.affectedByGravity = false
        self.name = "rock"
        self.zPosition = 101
        
        let move = SKAction.move(to: pointEnd, duration: TimeInterval(1))
        let removeNode = SKAction.removeFromParent()
        
        self.run(SKAction.repeatForever(SKAction.sequence([move, removeNode])))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(currentTime: CFTimeInterval) {
        if self.position.x >= self.gameScene.xOfRight()+100 {
            self.removeFromParent()
        }
    }
    
    func kill() {
        self.removeFromParent()
    }
    
    func contact(scene: GameScene, other: SKNode) {
        switch other.name {
            case "fly", "ant" :
                self.kill()
            default:
                print("here")
            }
    }
}
