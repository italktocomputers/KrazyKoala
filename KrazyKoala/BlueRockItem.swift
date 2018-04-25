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

class BlueRockItem : Entity {
    var gameScene: GameScene
    var difficulty: String
    
    init(gameScene: GameScene, difficulty: String) {
        self.gameScene = gameScene
        self.difficulty = difficulty
        
        let texture = SKTexture(imageNamed: "bluerocks")
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
        self.name = "bluerock"
        self.zPosition = 100
        
        // blink so user notices it
        let blink1 = SKTexture(imageNamed: "bluerocks")
        let blink2 = SKTexture(imageNamed: "rocks")
        let blinks = SKAction.animate(with: [blink1, blink2], timePerFrame: 0.4)
        
        self.run(SKAction.repeatForever(blinks), withKey:"move")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(currentTime: CFTimeInterval) {
        self.position = CGPoint(x: self.position.x - CGFloat(self.gameScene.foregroundSpeed), y: self.position.y)
        if self.position.x <= -200 {
            self.removeFromParent()
            let index = self.gameScene.nodeQueue.index(of: self)
            self.gameScene.nodeQueue.remove(at: index!)
        }
    }
}
