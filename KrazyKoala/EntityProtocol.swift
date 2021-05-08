/*

Copyright (c) 2021 Andrew Schools

*/

import Foundation
import SpriteKit

protocol IEntity {
    func update(currentTime: CFTimeInterval)
    func contact(scene: GameScene, other: SKNode)
    func kill()
}
