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
import AVFoundation
import AudioToolbox
import iAd
import Foundation

let edgeCategory: UInt32 = 0x1 << 0   // 1
let groundCategory: UInt32 = 0x1 << 1 // 2
let koalaCategory: UInt32 = 0x1 << 2  // 4
let flyCategory: UInt32 = 0x1 << 3    // 8
let antCategory: UInt32 = 0x1 << 4    // 16
let rockCategory: UInt32 = 0x1 << 5   // 32
let itemCategory: UInt32 = 0x1 << 6   // 64

// Swift 2 Array Extension
extension Array where Element: Equatable {
    mutating func removeObject(object: Element) -> Bool {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
            return true
        }
        
        return false
    }
    
    mutating func removeObjectsInArray(array: [Element]) -> Bool {
        for object in array {
            self.removeObject(object)
            return true
        }
        
        return false
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameStartTime = NSDate()
    var gameOverTime = NSDate()
    var koala: Koala?
    var nodeQueue: [SKSpriteNode] = []
    var poofQueue: [SKSpriteNode] = []
    var killQueue: [SKSpriteNode] = []
    var textBurstQueue: [String] = []
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    var score = 0
    var antsKilled = 0
    var fliesKilled = 0
    var pauseStartTime: NSDate?
    var jumpWav = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
    var hitWav = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
    var gameOverWav = SKAction.playSoundFileNamed("game-over.wav", waitForCompletion: true)
    var energizeWav = SKAction.playSoundFileNamed("energize.wav", waitForCompletion: false)
    var poofWav = SKAction.playSoundFileNamed("poof.wav", waitForCompletion: false)
    
    var minIntervalToAddFlyEasy: Double = 4.0
    var minIntervalToAddAntEasy: Double = 4.0
    var minIntervalToAddFlyHard: Double = 3.0
    var minIntervalToAddAntHard: Double = 3.0
    var minIntervalToAddFlyKrazy: Double = 2.0
    var minIntervalToAddAntKrazy: Double = 2.0
    
    var minIntervalToAddRedRock: Double = 30.0
    var minIntervalToAddBlueRock: Double = 45.0
    var minIntervalToAddBomb: Double = 15.0
    
    var maxIntervalToAddFlyEasy: Double = 6.0
    var maxIntervalToAddAntEasy: Double = 6.0
    var maxIntervalToAddFlyHard: Double = 5.0
    var maxIntervalToAddAntHard: Double = 5.0
    var maxIntervalToAddFlyKrazy: Double = 4.0
    var maxIntervalToAddAntKrazy: Double = 4.0
    
    var maxIntervalToAddRedRock: Double = 35.0
    var maxIntervalToAddBlueRock: Double = 50.0
    var maxIntervalToAddBomb: Double = 20.0
    
    var randIntervalToAddFly: Double = 2.0
    var randIntervalToAddAnt: Double = 2.0
    var randIntervalToAddRedRock: Double = 30.0
    var randIntervalToAddBlueRock: Double = 45.0
    var randIntervalToAddBomb: Double = 15.0
    
    var lastTimeFlyAdded = NSDate()
    var lastTimeAntAdded = NSDate()
    var lastTimeRedRockAdded = NSDate()
    var lastTimeBlueRockAdded = NSDate()
    var lastTimeBombAdded = NSDate()
    var lastTimeLevelAdjusted = NSDate()
    var lastTimeKillQueue = NSDate()
    
    var antDurationEasy = 5
    var antDurationHard = 5
    var antDurationKrazy = 5
    
    var flyDurationEasy = 3
    var flyDurationHard = 2
    var flyDurationKrazy = 2
    
    var antAnimationSpeedEasy = 0.2
    var antAnimationSpeedHard = 0.2
    var antAnimationSpeedKrazy = 0.2
    
    var flyAnimationSpeedEasy = 0.2
    var flyAnimationSpeedHard = 0.2
    var flyAnimationSpeedKrazy = 0.2
    
    var lastTimeNodeJumped = NSDate()
    var secsToWaitForJump: Double = 1.0
    
    var difficulty = ""
    
    var lastKill: NSDate? = nil
    var clearStreak = 0
    var gameHighclearStreak = 0
    
    var isGameOver = false
    var isGamePaused = false
    var isMusicEnabled = false
    
    var controller: GameViewController
    
    var highScore = 0
    var highclearStreak = 0
    
    var lastTextBurst = NSDate()
    var shownHighScoreBurst = false
    var shownHighclearStreakBurst = false
    
    var helpers = Helpers()
    var gameCenter: GameCenterController
    
    var backgroundSpeed = 1.0
    var foregroundSpeed = 2.5
    var level: Int = 1
    var changeLevelEvery = 60.0 // seconds
    
    init(size: CGSize, gameViewController: GameViewController, difficulty: String) {
        self.controller = gameViewController
        self.gameCenter = GameCenterController()
        self.difficulty = difficulty;
        
        if self.difficulty == "Hard" {
            self.changeLevelEvery = 45.0
        } else if self.difficulty == "Krazy" {
            self.changeLevelEvery = 30.0
        }
        
        do {
            try self.audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beet", ofType: "wav")!), fileTypeHint: nil)
        } catch {
            print("Cannot play music!")
        }
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func yOfGround() -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 130
        } else if self.view?.bounds.width == 480 {
            return 135
        } else {
            return 155
        }
    }
    
    func yOfTop() -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 768
        } else if self.view?.bounds.width == 480 {
            return 730
        }
        
        return 675
    }
    
    func yMaxPlacementOfItem() -> CGFloat {
        // We want to make sure the koala can
        // reach each item
        return self.yOfTop()-200
    }
    
    func xOfRight() -> CGFloat {
        return 1024
    }
    
    func yPosOfMenuBar() -> CGFloat {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return 728
        } else if self.view?.bounds.width == 480 {
            return 690
        } else {
            return 625
        }
    }
    
    func fromApplicationDidBecomeActive() {
        // Not sure why, but if someone hits pause, leaves the game and comes
        // back later, these sound files are no longer in memory so we need to
        // reload them here.
        jumpWav = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
        hitWav = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
        gameOverWav = SKAction.playSoundFileNamed("game-over.wav", waitForCompletion: true)
        energizeWav = SKAction.playSoundFileNamed("energize.wav", waitForCompletion: false)
        poofWav = SKAction.playSoundFileNamed("poof.wav", waitForCompletion: false)
        
        // If the user is returning to this scene we need
        // to call the pause method again since iOS
        // will unpause the game when returning even if
        // the game was paused to begin with.
        
        // Note: using the self.pause var seems to be unreliable
        // so a new var was created to keep track of game state.
        if (self.isGamePaused == true) {
            self.paused = true
        }
    }
    
    func fromApplicationWillResignActive() {
        if self.isGamePaused == false {
            // If they are the leaving game because of a text message,
            // phone call or they just decided to hit the home button
            // mid-game, pause game if not already paused.
            self.pause()
        }
    }
    
    override func didMoveToView(view: SKView) {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "fromApplicationDidBecomeActive",
            name: "fromApplicationDidBecomeActive",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "fromApplicationWillResignActive",
            name: "fromApplicationWillResignActive",
            object: nil)
        
        self.koala = Koala(gameScene: self, difficulty: self.difficulty)
        
        self.highScore = self.helpers.getHighScore(self.difficulty)
        self.highclearStreak = self.helpers.getHighClearStreak(self.difficulty)
        
        self.gameStartTime = NSDate()
        
        // We need this so the iAd delegates knows when to show
        // iAd and when to not.
        self.controller.currentSceneName = "GameScene"
        
        // If no error, we will try to display an ad, however, ...
        if self.controller.iAdError == false {
            // No iAd during game play unless on a pause.
            self.controller.adBannerView!.hidden = true
        }
        
        // Game music
        if self.helpers.getMusicSetting() == true {
            self.isMusicEnabled = true
            self.audioPlayer.play()
            self.audioPlayer.numberOfLoops = -1
        }
        
        // Add gravity to our game
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
        // Notify this class when a contact occurs
        self.physicsWorld.contactDelegate = self
        
        self.loadBackground()
        self.addDifficultyLabel()
        self.addScoreBoard(0)
        self.addLifeBar(self.koala!.lives)
        self.addRedRockIndicator()
        self.updateRedRockIndicator(0)
        self.addBlueRockIndicator()
        self.updateBlueRockIndicator(0)
        self.addPauseButton()
    }
    
    func showclearStreakLabel() {
        self.helpers.removeNodeByName(self, name: "clearStreakLabel")
        
        // Only show kill streak if 5 kills in a row or greater
        if self.clearStreak >= 5 {
            self.addChild(self.helpers.createLabel(String(format: "Clear streak: %i", self.clearStreak), fontSize: 20, position: CGPointMake(self.xOfRight()-610, self.yPosOfMenuBar()-9), name: "clearStreakLabel", color: SKColor.whiteColor()))
            
            if self.clearStreak % 20 == 0 {
                // For every 20 kills, show text letting them know
                // of their clear streak.
                self.textBurstQueue.append("Warrior!")
            }
        }
    }
    
    func addBlueRockIndicator() {
        let node = SKSpriteNode(imageNamed:"bluerock")
        node.zPosition = 1
        node.position = CGPointMake(155, self.yPosOfMenuBar())
        self.addChild(node)
    }
    
    func updateBlueRockIndicator(total: Int) {
        self.helpers.removeNodeByName(self, name: "blueRockIndicator")
        self.addChild(self.helpers.createLabel(String(format: "%i", total), fontSize: 20, position: CGPointMake(180, self.yPosOfMenuBar()-9), name: "blueRockIndicator", color: SKColor.whiteColor()))
    }
    
    func addRedRockIndicator() {
        let node = SKSpriteNode(imageNamed:"redrock")
        node.zPosition = 1
        node.position = CGPointMake(100, self.yPosOfMenuBar())
        self.addChild(node)
    }
    
    func updateRedRockIndicator(total: Int) {
        self.helpers.removeNodeByName(self, name: "redRockIndicator")
        self.addChild(self.helpers.createLabel(String(format: "%i", total), fontSize: 20, position: CGPointMake(125, self.yPosOfMenuBar()-9), name: "redRockIndicator", color: SKColor.whiteColor()))
    }
    
    func addScoreBoard(score: Int) {
        let node = SKSpriteNode(imageNamed:"PointsBar")
        node.zPosition = 1
        node.position = CGPointMake(self.xOfRight()-100, self.yPosOfMenuBar())
        self.addChild(node)
        
        self.updateScoreBoard(score)
    }
    
    func updateScoreBoard(score: Int) {
        self.helpers.removeNodeByName(self, name: "scoreBoardLabel")
        
        self.addChild(self.helpers.createLabel(String(format: "%06d", score), fontSize: 24, position: CGPointMake(self.xOfRight()-67, self.yPosOfMenuBar()-16), name: "scoreBoardLabel", color: SKColor.whiteColor()))
    }
    
    func addDifficultyLabel() {
        self.helpers.removeNodeByName(self, name: "difficultyLabel")
        
        self.addChild(self.helpers.createLabel(String(format: "Difficulty: %@", self.difficulty), fontSize: 20, position: CGPointMake(self.xOfRight()-405, self.yPosOfMenuBar()-9), name: "difficultyLabel", color: SKColor.whiteColor()))
    }
    
    func addLifeBar(numLives: Int) {
        self.helpers.removeNodeByName(self, name: "lifeBar")
        self.addChild(self.helpers.createLabel(String(format: "Lives: %i", numLives), fontSize: 20, position: CGPointMake(self.xOfRight()-250, self.yPosOfMenuBar()-9), name: "lifeBar", color: SKColor.whiteColor()))
    }
    
    func addPauseButton() {
        let btn = SKSpriteNode(imageNamed:"Pausebtn")
        btn.position = CGPointMake(40, self.yPosOfMenuBar())
        btn.zPosition = 4
        btn.name = name
        btn.xScale = 1
        btn.yScale = 1
        btn.name = "Pause"
        
        self.addChild(btn)
    }
    
    func gameOver() {
        // Remove any observers since we don't want to pause the game
        // while its ending and we also want to prevent an EXC_BAD_ACCESS
        // which is caused by this objects subscribers being deallocated
        // and then called from the app delegate.
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        self.isGameOver = true
        self.gameOverTime = NSDate()
        self.removeAllItems()
        self.audioPlayer.stop() // stop game music
        
        self.koala!.die()
        
        // Dim background
        self.enumerateChildNodesWithName("background", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let bg = node as! SKSpriteNode
            let colorBlack = SKAction.colorizeWithColor(SKColor.blackColor(), colorBlendFactor: 0.7, duration: 2)
            bg.runAction(SKAction.sequence([colorBlack]))
        })
        
        // Dim foreground
        self.enumerateChildNodesWithName("background2", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let bg = node as! SKSpriteNode
            let colorBlack = SKAction.colorizeWithColor(SKColor.blackColor(), colorBlendFactor: 0.7, duration: 2)
            bg.runAction(SKAction.sequence([colorBlack]))
        })
        
        // Play game over sound
        self.runAction(self.gameOverWav, completion: {()
            // Show game over scene
            let gameOverScene = GameOverScene(size: self.size,
                                              gameViewController: self.controller,
                                              score: self.score,
                                              antsKilled: self.antsKilled,
                                              fliesKilled: self.fliesKilled,
                                              clearStreak: self.gameHighclearStreak,
                                              difficulty: self.difficulty,
                                              level: self.level)
            
            gameOverScene.scaleMode = .AspectFill
            self.view?.presentScene(gameOverScene, transition: SKTransition.moveInWithDirection(SKTransitionDirection.Down, duration: 2))
        })
    }
    
    // Collision between nodes detected
    func didBeginContact(contact: SKPhysicsContact) {
         // I decided to keep the contact method in the scene and
         // not have one for each Entity for two reasons.  The
         // first reason has to do with code being executed in
         // parallel which results in race conditions.  The second
         // reason being Entity's will behave differently, depending
         // on what scene they are in.
        
        let body1 = contact.bodyA.node
        let body2 = contact.bodyB.node
        
        // Something made contact with the Koala
        if body1 is Koala || body2 is Koala {
            var _koala: Koala?
            var other: SKNode
            
            if body1 is Koala {
                _koala = body1 as? Koala
                other = body2!
            } else {
                _koala = body2 as? Koala
                other = body1!
            }
            
            // Koala has contacted a red rock, blue rock or a bomb
            if other.name == "bluerock" || other.name == "redrock" || other.name == "bomb" {
                // Play item pickup sound
                self.runAction(self.energizeWav)
                
                if other.name == "bluerock" {
                    _koala!.numBlueRocks = _koala!.numBlueRocks + 3
                    self.updateBlueRockIndicator(_koala!.numBlueRocks)
                } else if other.name == "redrock" {
                    _koala!.numRedRocks = _koala!.numRedRocks + 3
                    self.updateRedRockIndicator(_koala!.numRedRocks)
                } else if other.name == "bomb" {
                    self.killAllBadGuys()
                }
                
                other.removeFromParent()
            } else if other.name == "ground" {
                _koala!.walk()
            } else if other.name == "fly" {
                _koala!.takeHit()
                self.addLifeBar(_koala!.lives)
            } else if other.name == "ant" {
                if _koala!.physicsBody?.velocity.dy < 0 {
                    _koala!.applyBounce() // jumped on top of ant so koala will bounce
                    //self.applyBlackAntStompAchievement()
                } else {
                    _koala!.takeHit()
                    _koala!.gameScene.addLifeBar(_koala!.lives)
                }
            }
        }
        
        // Something made contact with a Fly
        if body1 is Fly || body2 is Fly {
            var _fly: Fly?
            var other: SKNode
            
            if body1 is Fly {
                _fly = body1 as? Fly
                other = body2!
            } else {
                _fly = body2 as? Fly
                other = body1!
            }
            
            if other.name == "rock" || other.name == "bluerock" || other.name == "redrock" || other.name == "koala" {
                _fly!.kill()
            }
        }
        
        // Something made contact with an Ant
        if body1 is Ant || body2 is Ant {
            var _ant: Ant?
            var other: SKNode
            
            if body1 is Ant {
                _ant = body1 as? Ant
                other = body2!
            } else {
                _ant = body2 as? Ant
                other = body1!
            }
            
            if other.name == "rock" || other.name == "bluerock" || other.name == "redrock" || other.name == "koala" {
                _ant!.kill()
            }
        }
        
        // Something made contact with a Rock
        if body1 is Rock || body2 is Rock {
            var _rock: Rock?
            var other: SKNode
            
            if body1 is Rock {
                _rock = body1 as? Rock
                other = body2!
            } else {
                _rock = body2 as? Rock
                other = body1!
            }

            if other.name == "fly" || other.name == "ant" {
                _rock!.removeFromParent()
            }
        }
        
        /*
        if self.isGameOver == false {
            if body1 is Entity {
                let cls = body1 as! Entity
                if body2 != nil {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        cls.physicsBodyDuringCollision = body1?.physicsBody!
                        cls.contact(body2!)
                    }
                }
            }
            
            if body2 is Entity {
                let cls = body2 as! Entity
                if body1 != nil {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        cls.physicsBodyDuringCollision = body2?.physicsBody!
                        cls.contact(body1!)
                    }
                }
            }
        }
        */
    }
    
    // Loop through nodeQueue array and then call the killAnt or killFly
    // to kill all ants and flies on the scene.
    func killAllBadGuys() {
        var x = 0
        
        for node in self.nodeQueue {
            if node.name == "ant" || node.name == "fly" {
                node.physicsBody?.contactTestBitMask = 0 // They can't hurt you anymore!
                self.killQueue.append(node)
                x++
            }
        }
        
        // Check for achievements!
        /*
        if x >= 5 {
            self.applyBombClearAchievement("5")
        }
        
        if x >= 10 {
            self.applyBombClearAchievement("10")
        }
        
        if x >= 15 {
            self.applyBombClearAchievement("15")
        }
        
        if x >= 20 {
            self.applyBombClearAchievement("20")
        }
        */
    }
    
    func removeAllItems() {
        for node in self.nodeQueue {
            let sknode = node as SKSpriteNode
            if sknode.name == "ant" ||
                sknode.name == "fly" ||
                sknode.name == "bomb" ||
                sknode.name == "bluerock" ||
                sknode.name == "redrock" {
                sknode.removeFromParent()
            }
        }
    }
    
    func addPoof(loc: CGPoint, playSound: Bool=true) {
        var ok = true
        
        self.enumerateChildNodesWithName("poof", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if node.position == loc {
                ok = false // No need to add a poof to the same location
            }
        })
        
        if ok {
            if playSound == true {
                self.runAction(self.poofWav)
            }
            
            let node = SKSpriteNode(imageNamed:"poof1_white")
            node.position = CGPoint(x: loc.x, y: loc.y)
            node.name = "poof"
            node.zPosition = 101
            
            let image1 = SKTexture(imageNamed: "poof1_white")
            let image2 = SKTexture(imageNamed: "poof2_white")
            let image3 = SKTexture(imageNamed: "poof3_white")
            let image4 = SKTexture(imageNamed: "poof4_white")
            let image5 = SKTexture(imageNamed: "poof5_white")
            let removeNode = SKAction.removeFromParent()
            let images = SKAction.animateWithTextures([image1, image2, image3, image4, image5], timePerFrame: 0.2)
            
            let deQueue = SKAction.runBlock({()
                self.poofQueue.removeObject(node)
            })
            
            node.runAction(SKAction.repeatActionForever(SKAction.sequence([images, deQueue, removeNode])))
            
            self.addChild(node)
            self.poofQueue.append(node)
        }
    }
    
    // User tapped the screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var nodeName: String = ""
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if node.name != nil {
                nodeName = node.name!
            }
        }
        
        if nodeName == "Pause" || nodeName == "PlayBtnFromDialog" {
            if self.isGameOver == false {
                if self.paused == true {
                    self.cancelPause()
                } else {
                    self.pause()
                }
            }
        } else if nodeName == "ReloadBtnFromDialog" && self.isGameOver == false {
            // Go to main menu
            self.audioPlayer.stop()
            let startScene = StartScene(size: self.size, gameViewController: self.controller)
            startScene.scaleMode = .AspectFill
            self.view?.presentScene(startScene)
        } else {
            if self.paused != true && self.isGameOver != true {
                if self.koala?.position.y >= 206 && self.koala?.position.y <= 209 {
                    self.koala!.jump() // jump
                } else {
                    // If koala is in the air and a touch is received, throw a rock
                    // instead of jumping (if they are allowed to throw a rock)
                    self.koala!.throwRock()
                }
            }
        }
    }
    
    func pause(keepTime:Bool=false) {
        self.paused = true
        self.isGamePaused = true
        
        if keepTime == false {
            self.pauseStartTime = NSDate()
        }
        
        if self.isMusicEnabled == true {
            self.audioPlayer.pause()
        }
        
        let panel = SKSpriteNode(imageNamed:"Panel3")
        panel.xScale = 1.1
        panel.yScale = 1.1
        panel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        panel.zPosition = 102
        panel.name = "pauseDialog"
        self.addChild(panel)
        
        let ribbon = SKSpriteNode(imageNamed:"PausedRibbon")
        ribbon.xScale = 1.1
        ribbon.yScale = 1.1
        ribbon.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+80)
        ribbon.zPosition = 103
        ribbon.name = "pauseDialog"
        self.addChild(ribbon)
        
        let accept = SKSpriteNode(imageNamed:"Reloadbtn")
        accept.position = CGPointMake(CGRectGetMidX(self.frame)-100, CGRectGetMidY(self.frame))
        accept.zPosition = 103
        accept.name = "ReloadBtnFromDialog"
        self.addChild(accept)
        
        let warning = SKSpriteNode(imageNamed:"Playbtn")
        warning.position = CGPointMake(CGRectGetMidX(self.frame)+100, CGRectGetMidY(self.frame))
        warning.zPosition = 103
        warning.name = "PlayBtnFromDialog"
        warning.xScale = 0.7
        warning.yScale = 0.7
        self.addChild(warning)
        
        // show ad
        self.controller.adBannerView!.hidden = false
    }
    
    func cancelPause() {
        self.paused = false
        self.isGamePaused = false
        
        let now = NSDate()
        
        if self.isMusicEnabled == true {
            self.audioPlayer.play()
        }
        
        // Since there was a pause we need to make sure that the time elapsed
        // doesn't count towards the add item intervals because if so, items will
        // be immediately added to the scene which would be a cool hack but
        // we cannot allow that...
        
        if self.pauseStartTime != nil {
            let pauseIntervalForAnt = Double(self.lastTimeAntAdded.timeIntervalSinceDate(pauseStartTime!))
            let pauseIntervalForBomb = Double(self.lastTimeBombAdded.timeIntervalSinceDate(pauseStartTime!))
            let pauseIntervalForRedRock = Double(self.lastTimeRedRockAdded.timeIntervalSinceDate(pauseStartTime!))
            let pauseIntervalForBlueRock = Double(self.lastTimeBlueRockAdded.timeIntervalSinceDate(pauseStartTime!))
            let pauseIntervalForFly = Double(self.lastTimeFlyAdded.timeIntervalSinceDate(pauseStartTime!))
            let pauseIntervalForNodeJump = Double(self.lastTimeNodeJumped.timeIntervalSinceDate(pauseStartTime!))
            let pauseIntervalForLastTextBurst = Double(self.lastTextBurst.timeIntervalSinceDate(pauseStartTime!))
            let pauseIntervalForlevel = Double(self.lastTimeLevelAdjusted.timeIntervalSinceDate(pauseStartTime!))
            
            self.lastTimeAntAdded = NSDate(timeInterval: NSTimeInterval(pauseIntervalForAnt), sinceDate: now)
            self.lastTimeBombAdded = NSDate(timeInterval: NSTimeInterval(pauseIntervalForBomb), sinceDate: now)
            self.lastTimeRedRockAdded = NSDate(timeInterval: NSTimeInterval(pauseIntervalForRedRock), sinceDate: now)
            self.lastTimeBlueRockAdded = NSDate(timeInterval: NSTimeInterval(pauseIntervalForBlueRock), sinceDate: now)
            self.lastTimeFlyAdded = NSDate(timeInterval: NSTimeInterval(pauseIntervalForFly), sinceDate: now)
            self.lastTimeNodeJumped = NSDate(timeInterval: NSTimeInterval(pauseIntervalForNodeJump), sinceDate: now)
            self.lastTextBurst = NSDate(timeInterval: NSTimeInterval(pauseIntervalForLastTextBurst), sinceDate: now)
            self.lastTimeLevelAdjusted = NSDate(timeInterval: NSTimeInterval(pauseIntervalForlevel), sinceDate: now)
        }
        
        self.pauseStartTime = nil
        
        // Remove dialog items
        self.enumerateChildNodesWithName("pauseDialog", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        self.enumerateChildNodesWithName("PlayBtnFromDialog", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        self.enumerateChildNodesWithName("ReloadBtnFromDialog", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        // Hide ad
        self.controller.adBannerView!.hidden = true
    }
    
    func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
    }
    
    func addItemsToScene() {
        let now = NSDate()
        
        let intervalForAnt = Double(now.timeIntervalSinceDate(self.lastTimeAntAdded))
        let intervalForFly = Double(now.timeIntervalSinceDate(self.lastTimeFlyAdded))
        let intervalForRedRock = Double(now.timeIntervalSinceDate(self.lastTimeRedRockAdded))
        let intervalForBlueRock = Double(now.timeIntervalSinceDate(self.lastTimeBlueRockAdded))
        let intervalForBomb = Double(now.timeIntervalSinceDate(self.lastTimeBombAdded))
        
        if intervalForAnt >= self.randIntervalToAddAnt && self.killQueue.count == 0 {
            let ant = Ant(gameScene: self, difficulty: self.difficulty)
            self.addChild(ant)
            self.nodeQueue.append(ant)
            
            var newInterval: Double = 0.0
            
            if self.difficulty == "Hard" {
                newInterval = Double(self.randRange(UInt32(self.minIntervalToAddAntHard), upper: UInt32(self.maxIntervalToAddAntHard)))
            } else if self.difficulty == "Krazy" {
                newInterval = Double(self.randRange(UInt32(self.minIntervalToAddAntKrazy), upper: UInt32(self.maxIntervalToAddAntKrazy)))
            } else {
                newInterval = Double(self.randRange(UInt32(self.minIntervalToAddAntEasy), upper: UInt32(self.maxIntervalToAddAntEasy)))
            }
            
            self.randIntervalToAddAnt = Double(newInterval)
            self.lastTimeAntAdded = NSDate()
        }
        
        if intervalForFly >= self.randIntervalToAddFly && self.killQueue.count == 0 {
            let fly = Fly(gameScene: self, difficulty: self.difficulty)
            self.addChild(fly)
            self.nodeQueue.append(fly)
            
            var newInterval: Double = 0.0
            
            if self.difficulty == "Hard" {
                if self.minIntervalToAddFlyHard == self.maxIntervalToAddFlyHard {
                    newInterval = self.minIntervalToAddFlyHard
                } else {
                    newInterval = Double(self.randRange(UInt32(self.minIntervalToAddFlyHard), upper: UInt32(self.maxIntervalToAddFlyHard)))
                }
            } else if self.difficulty == "Krazy" {
                if self.minIntervalToAddFlyKrazy == self.maxIntervalToAddFlyKrazy {
                    newInterval = self.minIntervalToAddFlyKrazy
                } else {
                    newInterval = Double(self.randRange(UInt32(self.minIntervalToAddFlyKrazy), upper: UInt32(self.maxIntervalToAddFlyKrazy)))
                }
            } else {
                if self.minIntervalToAddFlyEasy == self.maxIntervalToAddFlyEasy {
                    newInterval = self.minIntervalToAddFlyEasy
                } else {
                    newInterval = Double(self.randRange(UInt32(self.minIntervalToAddFlyEasy), upper: UInt32(self.maxIntervalToAddFlyEasy)))
                }
            }
            
            self.randIntervalToAddFly = newInterval
            self.lastTimeFlyAdded = NSDate()
        }
        
        if intervalForRedRock >= self.randIntervalToAddRedRock {
            let rock = RedRockItem(gameScene: self, difficulty: self.difficulty)
            self.addChild(rock)
            self.nodeQueue.append(rock)
            
            // Remember last time we did this so we only do it so often
            let newInterval = self.randRange(UInt32(self.minIntervalToAddRedRock), upper: UInt32(self.maxIntervalToAddRedRock))
            self.randIntervalToAddRedRock = Double(newInterval)
            self.lastTimeRedRockAdded = NSDate()

        }
        
        if intervalForBlueRock >= self.randIntervalToAddBlueRock {
            let rock = BlueRockItem(gameScene: self, difficulty: self.difficulty)
            self.addChild(rock)
            self.nodeQueue.append(rock)
            
            // Remember last time we did this so we only do it so often
            let newInterval = self.randRange(UInt32(self.minIntervalToAddBlueRock), upper: UInt32(self.maxIntervalToAddBlueRock))
            self.randIntervalToAddBlueRock = Double(newInterval)
            self.lastTimeBlueRockAdded = NSDate()
        }
        
        if intervalForBomb >= self.randIntervalToAddBomb {
            let bomb = BombItem(gameScene: self, difficulty: self.difficulty)
            self.addChild(bomb)
            self.nodeQueue.append(bomb)
            
            // Remember last time we did this so we only do it so often
            let newInterval = self.randRange(UInt32(self.minIntervalToAddBomb), upper: UInt32(self.maxIntervalToAddBomb))
            self.randIntervalToAddBomb = Double(newInterval)
            self.lastTimeBombAdded = NSDate()
        }
    }
    
    func loadBackground() {
        // To support a moving background we will add 3 background images,
        // one after another and when one reaches the end of the scene, we will
        // move it to the back so to create an endless moving background.
        for i in 0...3 {
            var bg = SKSpriteNode()
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                bg = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1280x800")
            } else {
                bg = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1920x640")
            }
            
            if self.view?.bounds.width == 480 {
                bg.yScale = 1.1
                bg.xScale = 1.1
            }
            
            bg.position = CGPointMake(CGFloat(i * Int(bg.size.width)), self.size.height/2)
            bg.name = "background";
            self.addChild(bg)
        }
        
        // Foreground
        for i in 0...3 {
            var bg = SKSpriteNode()
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad || self.view?.bounds.width == 480 {
                bg = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_ground_1280x800")
                bg.position = CGPointMake(CGFloat(i * Int(bg.size.width)), 75)
            } else {
                bg = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_ground_1920x640")
                bg.position = CGPointMake(CGFloat(i * Int(bg.size.width)), 120)
            }
            
            bg.name = "background2";
            bg.zPosition = 2
            self.addChild(bg)
        }
        
        // Add invisible barrier so our nodes don't go too high
        let topBody = SKNode()
        topBody.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: 0,y: CGFloat(self.yOfTop())+150), toPoint: CGPoint(x: self.xOfRight(), y: CGFloat(self.yOfTop())+150))
        
        topBody.physicsBody?.restitution = 0
        topBody.physicsBody?.categoryBitMask = groundCategory
        topBody.physicsBody?.dynamic = false
        self.addChild(topBody)
        
        // Add invisible barrier so our nodes don't fall through
        let groundBody = SKNode()
        groundBody.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: 0,y: self.yOfGround()), toPoint: CGPoint(x: self.xOfRight(), y: self.yOfGround()))
        
        groundBody.physicsBody?.restitution = 0
        groundBody.physicsBody?.categoryBitMask = groundCategory
        groundBody.physicsBody?.dynamic = false
        groundBody.name = "ground"
        self.addChild(groundBody)
    }
    
    func showTextBurst(text: String) {
        let panel = SKSpriteNode(imageNamed:"jumbotron")
        
        panel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+180)
        panel.zPosition = 9
        panel.name = "jumbotron"
        panel.alpha = 0.5
        self.addChild(panel)
        
        var size = CGFloat(20.0)
        if text.characters.count >= 20 {
            size = CGFloat(16.0)
        }
        
        self.addChild(self.helpers.createLabel(text, fontSize: size, position: CGPointMake(CGRectGetMidX(panel.frame), CGRectGetMidY(panel.frame)-7), name: "jumbotron", color: SKColor.whiteColor()))
        
        self.lastTextBurst = NSDate()
    }
    
    /*
    func applyBlackAntStompAchievement() {
        if self.helpers.getAchievementProgress("StompOnBlackAnt") < 100.0 {
            // New achievement completed!
            self.gameCenter.reportAchievement("StompOnBlackAnt", percent: 100.0)
            self.helpers.saveAchievementProgress(100.0, name: "StompOnBlackAnt")
            self.textBurstQueue.append("Stomp on black ant achievement!")
        }
    }
    
    func applyRedAntStompAchievement() {
        if self.helpers.getAchievementProgress("StompOnRedAnt") < 100.0 {
            // New achievement completed!
            self.gameCenter.reportAchievement("StompOnRedAnt", percent: 100.0)
            self.helpers.saveAchievementProgress(100.0, name: "StompOnRedAnt")
            self.textBurstQueue.append("Stomp on red ant achievement!")
        }
    }
    
    func applyBombClearAchievement(num: String) {
        if self.helpers.getAchievementProgress("BombClear" + num) < 100.0 {
            // New achievement completed!
            self.gameCenter.reportAchievement("BombClear" + num, percent: 100.0)
            self.helpers.saveAchievementProgress(100.0, name: "BombClear" + num)
            self.textBurstQueue.append("Clear " + num + " bugs with a bomb achievement!")
        }
    }
    */
    
    func checkForNewClearStreak() {
        let now = NSDate()
        let intervalForTextBurst = now.timeIntervalSinceDate(self.lastTextBurst)
        
        if self.shownHighclearStreakBurst == false && self.highclearStreak >= 1 && intervalForTextBurst >= 2 {
            if self.clearStreak > self.highclearStreak {
                self.textBurstQueue.append("Top Clear Streak!")
                self.shownHighclearStreakBurst = true // Only show once
            }
        }
    }
    
    func checkForNewHighScore() {
        let now = NSDate()
        let intervalForTextBurst = now.timeIntervalSinceDate(self.lastTextBurst)
        
        if self.shownHighScoreBurst == false && self.highScore >= 1 && intervalForTextBurst >= 2 {
            if self.score > self.highScore {
                self.textBurstQueue.append("Top Score!")
                self.shownHighScoreBurst = true // Only show once
            }
        }

    }
    
    func checkForlevel() {
        let now = NSDate()
        let intervalForlevel = now.timeIntervalSinceDate(self.lastTimeLevelAdjusted)
        
        if intervalForlevel >= self.changeLevelEvery {
            self.lastTimeLevelAdjusted = NSDate()
            self.level = self.level + 1
            self.addDifficultyLabel() // Update difficulty label
            self.addLifeBar(++self.koala!.lives) // Add life for every difficulty adjustment
            
            if self.difficulty == "Easy" {
                self.minIntervalToAddFlyEasy--
                self.maxIntervalToAddFlyEasy--
                
                if self.minIntervalToAddFlyEasy < 1 {
                    self.minIntervalToAddFlyEasy = 0.5
                }
                
                if self.maxIntervalToAddFlyEasy < 1 {
                    self.maxIntervalToAddFlyEasy = 0.5
                }
            } else if self.difficulty == "Hard" {
                self.minIntervalToAddFlyHard--
                self.maxIntervalToAddFlyHard--
                
                if self.minIntervalToAddFlyHard < 1 {
                    self.minIntervalToAddFlyHard = 0.5
                }
                
                if self.maxIntervalToAddFlyHard < 1 {
                    self.maxIntervalToAddFlyHard = 0.5
                }
            } else {
                self.minIntervalToAddFlyKrazy--
                self.maxIntervalToAddFlyKrazy--
                
                if self.minIntervalToAddFlyKrazy < 1 {
                    self.minIntervalToAddFlyKrazy = 0.5
                }
                
                if self.maxIntervalToAddFlyKrazy < 1 {
                    self.maxIntervalToAddFlyKrazy = 0.5
                }
            }
        }
    }
    
    func checkKillQueue() {
        if self.killQueue.count > 0 {
            let sknode = self.killQueue[0] as! Entity
            sknode.kill()
            
            self.killQueue.removeAtIndex(0)
            self.lastTimeKillQueue = NSDate()
        }
    }
    
    func checkTextBurstQueue() {
        let now = NSDate()
        let intervalForTextBurst = now.timeIntervalSinceDate(self.lastTextBurst)
        
        if intervalForTextBurst >= 2 {
            // remove old
            self.enumerateChildNodesWithName("jumbotron", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    node.removeFromParent()
                })
            
            if self.textBurstQueue.count > 0 {
                self.showTextBurst(self.textBurstQueue[0])
                self.textBurstQueue.removeAtIndex(0)
            }
        }
    }
    
    func moveBackground() {
        // Loop through our background images, moving each one 5 points to the left.
        // If one image reaches the end of the scene, we will place it in the back.
        self.enumerateChildNodesWithName("background", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let bg = node as! SKSpriteNode
            // Move background to the left x points
            bg.position = CGPointMake(bg.position.x - CGFloat(self.backgroundSpeed), bg.position.y)
            
            // If background has moved out of scene, move it to the end
            if bg.position.x <= -bg.size.width {
                bg.position = CGPointMake(bg.position.x + bg.size.width * 3, bg.position.y)
            }
        })
    }
    
    func moveForeground() {
        self.enumerateChildNodesWithName("background2", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let bg = node as! SKSpriteNode
            // Move background to the left x points
            bg.position = CGPointMake(bg.position.x - CGFloat(self.foregroundSpeed), bg.position.y)
            
            // If background has moved out of scene, move it to the end
            if bg.position.x <= -bg.size.width {
                bg.position = CGPointMake(bg.position.x + bg.size.width * 3, bg.position.y)
            }
        })
    }
    
    func moveItemsAlongForeground() {
        self.enumerateChildNodesWithName("poof", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let poof = node as! SKSpriteNode
            // Move poof to the left x points
            poof.position = CGPointMake(poof.position.x - CGFloat(self.foregroundSpeed), poof.position.y)
        })
    }
    
    override func update(currentTime: CFTimeInterval) {
        if self.isGamePaused == true {
            // Not sure why I need to do this but if the user hits the home
            // button and it's longer than a couple of minutes before they
            // return, iOS will play the game even though it should be paused.
            self.paused = true
        }
        
        if self.isGamePaused == false && self.isGameOver == false {
            self.koala!.update(currentTime)
            
            // For each entity in the scene, execute their
            // update method so they can do what they need
            // to do during this frame cycle.
            for node in self.nodeQueue {
                let entity = node as! Entity
                entity.update(currentTime)
            }
            
            self.moveBackground()
            self.moveForeground()
            self.moveItemsAlongForeground()
            self.addItemsToScene()
            self.checkForNewClearStreak()
            self.checkForNewHighScore()
            self.checkForlevel()
            self.checkKillQueue()
            self.checkTextBurstQueue()
        }
        
    }
}
