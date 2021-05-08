/*

Copyright (c) 2021 Andrew Schools

*/

import SpriteKit
import Foundation

class BlueRock : Entity, IEntity {
    var gameScene: GameScene
    
    init(pointStart: CGPoint, pointEnd: CGPoint, speed: TimeInterval, gameScene: GameScene) {
        self.gameScene = gameScene
        
        let texture = SKTexture(imageNamed: "bluerock")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        self.position = pointStart
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        self.physicsBody?.restitution = 0
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = rockCategory
        self.physicsBody?.contactTestBitMask = flyCategory | antCategory
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.affectedByGravity = false
        self.name = "bluerock"
        self.zPosition = 101
        
        let move = SKAction.move(to: pointEnd, duration: speed)
        let removeNode = SKAction.removeFromParent()
        
        self.run(SKAction.repeatForever(SKAction.sequence([move, removeNode])))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(currentTime: CFTimeInterval) {
        self.position = CGPoint(x: self.position.x - CGFloat(self.gameScene.foregroundSpeed), y: self.position.y)
        
        if self.position.x <= -200 {
            self.removeFromParent()
            let index = self.gameScene.nodeQueue.index(of: self)
            self.gameScene.nodeQueue.remove(at: index!)
        }
    }
    
    func kill() {
        self.removeFromParent()
    }
    
    func contact(scene: GameScene, other: SKNode) {
        
    }
}
