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

class RedRock : Entity {
    var gameScene: GameScene
    
    init(pointStart: CGPoint, pointEnd: CGPoint, gameScene: GameScene) {
        self.gameScene = gameScene
        
        let texture = SKTexture(imageNamed: "redrock")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.position = pointStart
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.size.width, height: self.size.height))
        self.physicsBody?.restitution = 0
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = rockCategory
        self.physicsBody?.contactTestBitMask = flyCategory | antCategory
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.affectedByGravity = false
        self.name = "redrock"
        self.zPosition = 101
        
        let move = SKAction.moveTo(pointEnd, duration: NSTimeInterval(1))
        let removeNode = SKAction.removeFromParent()
        
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([move, removeNode])))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(currentTime: CFTimeInterval) {
        self.position = CGPointMake(self.position.x - CGFloat(self.gameScene.foregroundSpeed), self.position.y)
        
        if self.position.x <= -200 {
            self.removeFromParent()
            self.gameScene.nodeQueue.removeObject(self)
        }
    }
}