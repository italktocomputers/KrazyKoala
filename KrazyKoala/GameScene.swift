//
//  GameScene.swift
//  KrazyKoala
//
//  Created by Andrew Schools on 12/31/14.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

import SpriteKit
import AVFoundation
import AudioToolbox
import iAd
import Foundation

let edgeCategory: UInt32 = 0x1 << 0         // 1
let groundCategory: UInt32 = 0x1 << 1       // 2
let goodGuyCategory: UInt32 = 0x1 << 2      // 4
let badGuyCategory: UInt32 = 0x1 << 3       // 8
let canBeShotCategory: UInt32 = 0x1 << 4    // 16
let bulletCategory: UInt32 = 0x1 << 5       // 32
let pointCategory: UInt32 = 0x1 << 6        // 64
let antCategory: UInt32 = 0x1 << 7          // 128

extension Array {
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if((index) != nil) {
            self.removeAtIndex(index!)
            return true
        }
        
        return false
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameStartTime = NSDate()
    var gameOverTime = NSDate()
    var koala = SKSpriteNode()
    var nodeQueue: [SKSpriteNode] = []
    var poofQueue: [SKSpriteNode] = []
    var killQueue: [SKSpriteNode] = []
    var textBurstQueue: [String] = []
    var lives = 5
    var canJump = false
    var audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beet", ofType: "wav")!), error: nil)
    var canThrow = true
    var numRedRocks = 0
    var numBlueRocks = 0
    var lastTimeThrown = NSDate()
    var score = 0
    var antsKilled = 0
    var fliesKilled = 0
    var pauseStartTime: NSDate?
    var jumpWav = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
    var hitWav = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
    var gameOverWav = SKAction.playSoundFileNamed("game-over.wav", waitForCompletion: true)
    var energizeWav = SKAction.playSoundFileNamed("energize.wav", waitForCompletion: false)
    var poofWav = SKAction.playSoundFileNamed("poof.wav", waitForCompletion: false)
    var bombBeepsWav = SKAction.playSoundFileNamed("bomb_beeps.aiff", waitForCompletion: true)
    
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
    
    var koalaAnimationWalkingSpeed = 0.2
    
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
    
    var backgroundSpeed = 1.0
    var foregroundSpeed = 2.5
    var level: Int = 1
    var changeLevelEvery = 60.0 // seconds
    
    init(size: CGSize, gameViewController: GameViewController, difficulty: String) {
        self.controller = gameViewController
        self.difficulty = difficulty
        
        if (difficulty == "Hard" || difficulty == "Krazy") {
            self.lives = 3
        }
        
        if (self.difficulty == "Hard") {
            self.changeLevelEvery = 45.0
        } else if (self.difficulty == "Krazy") {
            self.changeLevelEvery = 30.0
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
        // we want to make sure the koala can
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
        // not sure why, but if someone hits pause, leaves the game and comes
        // back later, these sound files are no longer in memory so we will
        // reload them here
        jumpWav = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
        hitWav = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
        gameOverWav = SKAction.playSoundFileNamed("game-over.wav", waitForCompletion: true)
        energizeWav = SKAction.playSoundFileNamed("energize.wav", waitForCompletion: false)
        poofWav = SKAction.playSoundFileNamed("poof.wav", waitForCompletion: false)
        bombBeepsWav = SKAction.playSoundFileNamed("bomb_beeps.aiff", waitForCompletion: true)
        
        // if the user is returning to this scene we need
        // to call the pause method again since iOS
        // will unpause the game when returning even if
        // the game was paused to begin with
        
        // note: using the self.pause var seems to be unreliable
        // so a new var was created to keep track of game state
        if (self.isGamePaused == true) {
            self.paused = true
        }
    }
    
    func fromApplicationWillResignActive() {
        if (self.isGamePaused == false) {
            // if they are the leaving game because of a text message,
            // phone call or they just decided to hit the home button
            // mid-game, pause game if not already paused
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
        
        //view.frameInterval = 2
        
        self.highScore = self.helpers.getHighScore(self.difficulty)
        self.highclearStreak = self.helpers.getHighClearStreak(self.difficulty)
        
        self.gameStartTime = NSDate()
        
        // we need this so the iAd delegates know when to show
        // iAd and when to not
        self.controller.currentSceneName = "GameScene"
        
        // if no error, we will try to display an ad, however, ...
        if (self.controller.iAdError == false) {
            // no iAd during game play unless on a pause
            self.controller.adBannerView!.hidden = true
        }
        
        // game music
        if (self.helpers.getMusicSetting() == true) {
            self.isMusicEnabled = true
            self.audioPlayer.play()
            self.audioPlayer.numberOfLoops = -1
        }
        
        // add gravity to our game
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
        // notify this class when a contact occurs
        self.physicsWorld.contactDelegate = self
        
        self.loadBackground()
        self.addKoala()
        self.addDifficultyLabel()
        self.addScoreBoard(0)
        self.addLifeBar(self.lives)
        self.addRedRockIndicator()
        self.updateRedRockIndicator(0)
        self.addBlueRockIndicator()
        self.updateBlueRockIndicator(0)
        self.addPauseButton()
    }
    
    func showclearStreakLabel() {
        self.helpers.removeNodeByName(self, name: "clearStreakLabel")
        
        // only show kill streak if 5 kills in a row or greater
        if (self.clearStreak >= 5) {
            self.addChild(self.helpers.createLabel(String(format: "Clear streak: %i", self.clearStreak), fontSize: 20, position: CGPointMake(self.xOfRight()-610, self.yPosOfMenuBar()-9), name: "clearStreakLabel", color: SKColor.whiteColor()))
            
            if (self.clearStreak % 20 == 0) {
                // for every 20 kills, show a burst of text letting them know
                // of their kill streak
                self.textBurstQueue.append("Warrior!")
            }
        }
    }
    
    func addBlueRockIndicator() {
        var node = SKSpriteNode(imageNamed:"bluerock")
        node.zPosition = 1
        node.position = CGPointMake(155, self.yPosOfMenuBar())
        self.addChild(node)
    }
    
    func updateBlueRockIndicator(total: Int) {
        self.helpers.removeNodeByName(self, name: "blueRockIndicator")
        self.addChild(self.helpers.createLabel(String(format: "%i", total), fontSize: 20, position: CGPointMake(180, self.yPosOfMenuBar()-9), name: "blueRockIndicator", color: SKColor.whiteColor()))
    }
    
    func addRedRockIndicator() {
        var node = SKSpriteNode(imageNamed:"redrock")
        node.zPosition = 1
        node.position = CGPointMake(100, self.yPosOfMenuBar())
        self.addChild(node)
    }
    
    func updateRedRockIndicator(total: Int) {
        self.helpers.removeNodeByName(self, name: "redRockIndicator")
        self.addChild(self.helpers.createLabel(String(format: "%i", total), fontSize: 20, position: CGPointMake(125, self.yPosOfMenuBar()-9), name: "redRockIndicator", color: SKColor.whiteColor()))
    }
    
    func addScoreBoard(score: Int) {
        var node = SKSpriteNode(imageNamed:"PointsBar")
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
    
    func takeHit() {
        // good guy and bad guy collide so play sound
        self.runAction(self.hitWav)
        
        if (self.helpers.getVibrationSetting() == true) {
            // vibrate to notify user of contact
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        // blink backgrounds red to indicate hit
        self.enumerateChildNodesWithName("background", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let bg = node as! SKSpriteNode
            let colorRed = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 0.5, duration: 0.2)
            let colorOkay = SKAction.colorizeWithColor(SKColor.clearColor(), colorBlendFactor: 0.0, duration: 0)
            bg.runAction(SKAction.sequence([colorRed, colorOkay, colorRed, colorOkay]))
        })
        
        // blink foregrounds red to indicate hit
        self.enumerateChildNodesWithName("background2", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let bg = node as! SKSpriteNode
            let colorRed = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor: 0.5, duration: 0.2)
            let colorOkay = SKAction.colorizeWithColor(SKColor.clearColor(), colorBlendFactor: 0.0, duration: 0)
            bg.runAction(SKAction.sequence([colorRed, colorOkay, colorRed, colorOkay]))
        })
        
        self.lives-- // take away a life
        
        // save highest kill streak before resetting
        if (self.clearStreak > self.gameHighclearStreak) {
            self.gameHighclearStreak = self.clearStreak
        }
        
        // reset kill streak
        self.clearStreak = 0
        self.showclearStreakLabel()
        
        // update life bar
        self.addLifeBar(self.lives)
        
        if (self.lives == 0) {
            // game over!
            self.gameOver()
        }
    }
    
    func gameOver() {
        // remove any observers since we don't want to pause the game
        // while its ending and we also want to prevent an EXC_BAD_ACCESS
        // which is caused by this objects subscribers being deallocated
        // and then called from the app delegate
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        self.isGameOver = true
        self.gameOverTime = NSDate()
        self.removeAllItems()
        self.audioPlayer.stop() // stop game music
        
        //self.addChild(self.helpers.createLabel("Game Over!", fontSize: 72, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)), color: SKColor.whiteColor()))
        
        self.koala.removeActionForKey("walk")
        self.koala.removeActionForKey("jump")
        
        self.koala.physicsBody?.affectedByGravity = false
        self.koala.physicsBody?.collisionBitMask = 0
        self.koala.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
        
        self.applyDeathDanceToKoala()
        
        // dim background
        self.enumerateChildNodesWithName("background", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let bg = node as! SKSpriteNode
            let colorBlack = SKAction.colorizeWithColor(SKColor.blackColor(), colorBlendFactor: 0.7, duration: 2)
            bg.runAction(SKAction.sequence([colorBlack]))
        })
        
        // dim foreground
        self.enumerateChildNodesWithName("background2", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let bg = node as! SKSpriteNode
            let colorBlack = SKAction.colorizeWithColor(SKColor.blackColor(), colorBlendFactor: 0.7, duration: 2)
            bg.runAction(SKAction.sequence([colorBlack]))
        })
        
        // play game over sound
        self.runAction(self.gameOverWav, completion: {()
            // show game over scene
            let currentTime = Double(self.gameOverTime.timeIntervalSinceDate(self.gameStartTime))
            
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
    
    // collision between nodes detected
    func didBeginContact(contact: SKPhysicsContact) {
        if (self.isGameOver == false) {
            let cat1 = contact.bodyA.categoryBitMask
            let cat2 = contact.bodyB.categoryBitMask
            let collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
            
            // koala has contacted a red rock, blue rock or a bomb
            if (collision == (pointCategory | goodGuyCategory)) {
                var rock: SKSpriteNode?
                if (contact.bodyA.categoryBitMask == goodGuyCategory) {
                    rock = contact.bodyB.node as? SKSpriteNode
                } else {
                    rock = contact.bodyA.node as? SKSpriteNode
                }
                
                // play item pickup sound
                self.runAction(self.energizeWav)
                
                if (rock!.name == "bluerock") {
                    self.numBlueRocks = self.numBlueRocks + 3
                    self.updateBlueRockIndicator(self.numBlueRocks)
                } else if (rock!.name == "redrock") {
                    self.numRedRocks = self.numRedRocks + 3
                    self.updateRedRockIndicator(self.numRedRocks)
                } else if (rock!.name == "bomb") {
                    // play bomb beeps
                    //self.runAction(self.bombBeepsWav, completion: {() -> Void in
                        self.killAllBadGuys()
                    //})
                }
                
                rock!.removeFromParent()
            }
            
            // fly or ant has left the scene via x coordinates so let's remove it
            if (collision == (edgeCategory)) {
                if (round(contact.contactPoint.x) == 0) {
                    if (contact.bodyA.categoryBitMask == edgeCategory) {
                        contact.bodyB.node!.removeFromParent()
                    } else {
                        contact.bodyA.node!.removeFromParent()
                    }
                }
            }
            
            let velocity = self.koala.physicsBody?.velocity
            
            // koala collided with ant
            if (collision == (goodGuyCategory | badGuyCategory | antCategory | canBeShotCategory)) {
                if (velocity?.dy < 0.0 && self.koala.position.y > self.yOfGround()+20) {
                    // koala jumped on ant so we can kill ant
                    
                    // kill ant
                    if (contact.bodyA.categoryBitMask == (badGuyCategory | antCategory | canBeShotCategory)) {
                        killAnt(contact.bodyA.node! as! SKSpriteNode)
                    } else {
                        killAnt(contact.bodyB.node! as! SKSpriteNode)
                    }
                    
                    // when koala hits an ant it will bounce back up
                    // but we first need to reset velocity of koala so 
                    // every bounce is consistent
                    self.koala.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    self.koala.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
                } else {
                    // koala ran into ant
                    self.takeHit()
                }
            }
            
            if (collision == (goodGuyCategory | badGuyCategory | canBeShotCategory)) {
                // koala collided with fly
                self.takeHit()
            }
            
            if (collision == (goodGuyCategory | groundCategory)) {
                // FYI: for some reason when the koala hits the ground its velocity dy can increase
                self.canJump = true // koala is on the ground
                self.applyWalkToKoala()
            }
            
            // rock and fly collide
            if (collision == (bulletCategory | badGuyCategory | canBeShotCategory) || collision == (bulletCategory | badGuyCategory | antCategory | canBeShotCategory)) {
                // remove rock and fly and remove from queue
                if (contact.bodyA.categoryBitMask == bulletCategory) {
                    if (contact.bodyA.node?.name == "rock") {
                        contact.bodyA.node?.removeFromParent() // remove plain rock
                    }
                    
                    if (contact.bodyB.node?.name == "fly") {
                        self.killFly(contact.bodyB.node! as! SKSpriteNode)
                    } else {
                        self.killAnt(contact.bodyB.node! as! SKSpriteNode)
                    }
                } else {
                    if (contact.bodyB.node?.name == "rock") {
                        contact.bodyB.node?.removeFromParent() // remove plain rock
                    }
                    
                    if (contact.bodyA.node?.name == "fly") {
                        self.killFly(contact.bodyA.node! as! SKSpriteNode)
                    } else {
                        self.killAnt(contact.bodyA.node! as! SKSpriteNode)
                    }
                }
            }
        }
    }
    
    // loop through nodeQueue array and then call the killAnt or killFly
    // to kill all ants and flies on the scene
    func killAllBadGuys() {
        for node in self.nodeQueue {
            if (node.name == "ant" || node.name == "fly") {
                node.physicsBody?.contactTestBitMask = 0
                self.killQueue.append(node)
            }
        }
    }
    
    func removeAllItems() {
        for node in self.nodeQueue {
            let sknode = node as SKSpriteNode
            if (sknode.name == "ant" ||
                sknode.name == "fly" ||
                sknode.name == "bomb" ||
                sknode.name == "bluerock" ||
                sknode.name == "redrock") {
                sknode.removeFromParent()
            }
        }
    }
    
    func kill(node: SKSpriteNode, playSound: Bool=true) {
        
    }
    
    func killAnt(ant: SKSpriteNode, playSound: Bool=true) {
        self.addPoof(ant.position, playSound: playSound)
        
        ant.removeFromParent()
        
        if (self.nodeQueue.removeObject(ant) == true) {
            // we need to wrap this because multiple rocks from a
            // spray can hit the same ant and we don't want to
            // give them more than one point per kill
            self.antsKilled++
            self.lastKill = NSDate()
            self.score++
            self.clearStreak++
            self.updateScoreBoard(self.score)
            self.showclearStreakLabel()
        }
    }
    
    func killFly(fly: SKSpriteNode, playSound: Bool=true) {
        self.addPoof(fly.position, playSound: playSound)
        
        fly.removeFromParent()
        
        if (self.nodeQueue.removeObject(fly) == true) {
            // we need to wrap this because multiple rocks from a 
            // spray can hit the same fly and we don't want to
            // give them more than one point per kill
            self.fliesKilled++
            self.lastKill = NSDate()
            self.score++
            self.clearStreak++
            self.updateScoreBoard(self.score)
            self.showclearStreakLabel()
        }
    }
    
    func addPoof(loc: CGPoint, playSound: Bool=true) {
        var ok = true
        
        self.enumerateChildNodesWithName("poof", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if (node.position == loc) {
                ok = false // no need to add a poof to the same location
            }
        })
        
        if (ok) {
            if (playSound == true) {
                self.runAction(self.poofWav)
            }
            
            //println(color)
            
            var node = SKSpriteNode(imageNamed:"poof1_white")
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
    
    // user tapped the screen
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var nodeName: String = ""
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if (node.name != nil) {
                nodeName = node.name!
            }
        }
        
        if ((nodeName == "Pause" || nodeName == "PlayBtnFromDialog") && self.isGameOver == false) {
            if (self.paused == true) {
                self.cancelPause()
            } else {
                self.pause()
            }
        } else if (nodeName == "ReloadBtnFromDialog" && self.isGameOver == false) {
            // go to main menu
            self.audioPlayer.stop()
            let startScene = StartScene(size: self.size, gameViewController: self.controller)
            startScene.scaleMode = .AspectFill
            self.view?.presentScene(startScene)
        } else {
            if (self.paused != true && self.isGameOver != true) {
                if (self.canJump == true) {
                    self.applyJumpToKoala() // jump
                } else {
                    // if koala is in the air and a touch is received, throw a rock
                    // instead of jumping (if they are allowed to throw a rock)
                    if (self.numRedRocks > 0) {
                        // if they have red rocks, throw them first
                        self.throwRedRocks()
                        self.numRedRocks--
                        self.updateRedRockIndicator(self.numRedRocks)
                    } else if (numBlueRocks > 0) {
                        // if they have no red rocks to throw but they do blue rocks,
                        // throw blue rocks
                        self.throwBlueRock()
                        self.numBlueRocks--
                        self.updateBlueRockIndicator(self.numBlueRocks)
                    } else {
                        // no blue or red rocks to throw so throw a plain old rock
                        self.throw(CGPoint(x: self.xOfRight(), y: self.koala.position.y), type: "rock", speed: NSTimeInterval(1))
                    }
                }
            }
        }
    }
    
    func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
    }
    
    func pause(keepTime:Bool=false) {
        self.paused = true
        self.isGamePaused = true
        
        if (keepTime == false) {
            self.pauseStartTime = NSDate()
        }
        
        if (self.isMusicEnabled == true) {
            self.audioPlayer.pause()
        }
        
        var panel = SKSpriteNode(imageNamed:"Panel3")
        panel.xScale = 1.1
        panel.yScale = 1.1
        panel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        panel.zPosition = 102
        panel.name = "pauseDialog"
        self.addChild(panel)
        
        var ribbon = SKSpriteNode(imageNamed:"PausedRibbon")
        ribbon.xScale = 1.1
        ribbon.yScale = 1.1
        ribbon.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+80)
        ribbon.zPosition = 102
        ribbon.name = "pauseDialog"
        self.addChild(ribbon)
        
        let accept = SKSpriteNode(imageNamed:"Reloadbtn")
        accept.position = CGPointMake(CGRectGetMidX(self.frame)-100, CGRectGetMidY(self.frame))
        accept.zPosition = 102
        accept.name = "ReloadBtnFromDialog"
        self.addChild(accept)
        
        let warning = SKSpriteNode(imageNamed:"Playbtn")
        warning.position = CGPointMake(CGRectGetMidX(self.frame)+100, CGRectGetMidY(self.frame))
        warning.zPosition = 102
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
        
        if (self.isMusicEnabled == true) {
            self.audioPlayer.play()
        }
        
        // since there was a pause we need to make sure that the time elapsed
        // doesn't count towards the add item intervals because if so, items will
        // be immediately added to the scene which would be a cool hack but
        // we cannot allow that...
        
        if (self.pauseStartTime != nil) {
            let timeElaspedSincePause = Double(now.timeIntervalSinceDate(self.pauseStartTime!))
            
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
        
        // remove dialog items
        self.enumerateChildNodesWithName("pauseDialog", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        self.enumerateChildNodesWithName("pauseDialog", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        self.enumerateChildNodesWithName("PlayBtnFromDialog", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        self.enumerateChildNodesWithName("ReloadBtnFromDialog", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        // hide ad
        self.controller.adBannerView!.hidden = true
    }
    
    func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
    }
    
    func addKoala() {
        var koala = SKSpriteNode(imageNamed:"koala_walk01")
        koala.position = CGPoint(x: 150, y: 400)
        koala.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: koala.size.width, height: koala.size.height))
        koala.physicsBody?.restitution = 0
        koala.physicsBody?.allowsRotation = false // node should always be upright
        koala.physicsBody?.categoryBitMask = goodGuyCategory
        koala.physicsBody?.contactTestBitMask = badGuyCategory | groundCategory
        koala.physicsBody?.collisionBitMask = groundCategory
        koala.zPosition = 3
        
        self.koala = koala
        self.addChild(self.koala)
        self.applyWalkToKoala()
    }
    
    func applyWalkToKoala() {
        // show walk animation
        let walk1 = SKTexture(imageNamed: "koala_walk01")
        let walk2 = SKTexture(imageNamed: "koala_walk02")
        let walkAni = SKAction.animateWithTextures([walk1, walk2], timePerFrame: self.koalaAnimationWalkingSpeed)
        
        self.koala.runAction(SKAction.repeatActionForever(walkAni), withKey:"walk")
    }
    
    func applyDeathDanceToKoala() {
        let fade = SKAction.fadeOutWithDuration(2)
        self.koala.runAction(fade)
        
        let rotate = SKAction.rotateByAngle(10, duration: 2)
        self.koala.runAction(rotate)
        
        let implode = SKAction.scaleTo(50, duration: 2)
        self.koala.runAction(implode)
    }
    
    func applyJumpToKoala() {
        // remove walking animation
        self.koala.removeActionForKey("walk")
        
        // show jump animation
        let jump = SKAction.setTexture(SKTexture(imageNamed: "koala_jump"))
        self.koala.runAction(jump)
        
        // play jump sound
        self.runAction(self.jumpWav, withKey:"jump")
        
        // apply jump
        self.koala.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 250))
        
        // can't jump while in the air
        self.canJump = false
    }
    
    func addFly() {
        let yStart = self.randRange(UInt32(self.yOfGround()+30), upper: UInt32(self.yOfTop()))
        
        var node = SKSpriteNode(imageNamed:"fly_1")
        node.position = CGPoint(x: self.xOfRight(), y: CGFloat(yStart))
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: node.size.width, height: node.size.height))
        node.physicsBody?.restitution = 0
        node.physicsBody?.dynamic = true
        node.physicsBody?.categoryBitMask = badGuyCategory | canBeShotCategory
        node.physicsBody?.contactTestBitMask = goodGuyCategory | bulletCategory
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.affectedByGravity = false
        node.name = "fly"
        node.zPosition = 101
        
        // how fast each move is performed
        var duration = NSTimeInterval(self.flyDurationKrazy)
        if (self.difficulty == "Easy") {
            duration = NSTimeInterval(self.flyDurationEasy)
        } else if (self.difficulty == "Hard") {
            duration = NSTimeInterval(self.flyDurationHard)
        }
        
        // as time progresses, so does the length a fly will stay on the scene
        var moves:[SKAction] = []
        for i in 1...4+self.level {
            let randX = self.randRange(0, upper: UInt32(self.xOfRight()))
            let randY = self.randRange(UInt32(self.yOfGround()+30), upper: UInt32(self.yOfTop()))
            moves.append(SKAction.moveTo(CGPoint(x: Double(randX), y: Double(randY)), duration: duration))
        }
        
        let deQueue = SKAction.runBlock({()
            //println("deQueue fly")
            self.nodeQueue.removeObject(node)
        })
        
        moves.append(SKAction.moveToX(-100, duration: duration)) // fly will exit scene
        moves.append(deQueue) // remove from node Queue
        moves.append(SKAction.removeFromParent()) // remove from scene
        
        node.runAction(SKAction.sequence(moves), withKey:"moves")
        
        // flying animation
        let image1 = SKTexture(imageNamed: "fly_1")
        let image2 = SKTexture(imageNamed: "fly_2")
        
        var animationSpeed = self.flyAnimationSpeedEasy
        if (self.difficulty == "Hard") {
            animationSpeed = self.flyAnimationSpeedHard
        } else if (self.difficulty == "Krazy") {
            animationSpeed = self.flyAnimationSpeedKrazy
        }
        
        let images = SKAction.animateWithTextures([image1, image2], timePerFrame: animationSpeed)
        
        node.runAction(SKAction.repeatActionForever(images), withKey:"images")
        
        self.addChild(node)
        self.nodeQueue.append(node)
        
        var newInterval: Double = 0.0
        
        if (self.difficulty == "Hard") {
            if (self.minIntervalToAddFlyHard == self.maxIntervalToAddFlyHard) {
                newInterval = self.minIntervalToAddFlyHard
            } else {
                newInterval = Double(self.randRange(UInt32(self.minIntervalToAddFlyHard), upper: UInt32(self.maxIntervalToAddFlyHard)))
            }
        } else if (self.difficulty == "Krazy") {
            if (self.minIntervalToAddFlyKrazy == self.maxIntervalToAddFlyKrazy) {
                newInterval = self.minIntervalToAddFlyKrazy
            } else {
                newInterval = Double(self.randRange(UInt32(self.minIntervalToAddFlyKrazy), upper: UInt32(self.maxIntervalToAddFlyKrazy)))
            }
        } else {
            if (self.minIntervalToAddFlyEasy == self.maxIntervalToAddFlyEasy) {
                newInterval = self.minIntervalToAddFlyEasy
            } else {
                newInterval = Double(self.randRange(UInt32(self.minIntervalToAddFlyEasy), upper: UInt32(self.maxIntervalToAddFlyEasy)))
            }
        }
        
        self.randIntervalToAddFly = newInterval
        self.lastTimeFlyAdded = NSDate()
    }
    
    func addAnt() {
        let antTypeInt = Double(self.randRange(0, upper: 1))
        var antTypeStr = ""
        
        if (antTypeInt == 1) {
            antTypeStr = "_black"
        }
        
        var node = SKSpriteNode(imageNamed:"ant_walk_1"+antTypeStr)
        node.position = CGPoint(x: self.xOfRight(), y: self.yOfGround()+5)
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: node.size.width, height: node.size.height))
        node.physicsBody?.restitution = 0
        node.physicsBody?.dynamic = true
        node.physicsBody?.allowsRotation = false // node should always be upright
        node.physicsBody?.categoryBitMask = badGuyCategory | antCategory | canBeShotCategory
        node.physicsBody?.contactTestBitMask = goodGuyCategory | bulletCategory
        node.physicsBody?.collisionBitMask = groundCategory
        node.name = "ant"
        node.zPosition = 3
        
        let deQueue = SKAction.runBlock({()
            //println("deQueue ant")
            self.nodeQueue.removeObject(node)
        })
        
        var duration = NSTimeInterval(self.antDurationKrazy)
        if (self.difficulty == "Easy") {
            duration = NSTimeInterval(self.antDurationEasy)
        } else if (self.difficulty == "Hard") {
            duration = NSTimeInterval(self.antDurationHard)
        }
        
        var actions: [SKAction] = []
        if (antTypeStr == "") {
            // red ant
            // red ants will move once, and the dart towards koala
            // making them more dangerous than black ants
            actions.append(SKAction.moveToX(500, duration: 2))
            actions.append(SKAction.moveToX(-100, duration: 1.0))
        } else {
            // black ant
            actions.append(SKAction.moveToX(-200, duration: duration))
        }
        
        actions.append(deQueue)
        actions.append(SKAction.removeFromParent())
        
        node.runAction(SKAction.sequence(actions))
        
        // walking animation
        let move1 = SKTexture(imageNamed: "ant_walk_1"+antTypeStr)
        let move2 = SKTexture(imageNamed: "ant_walk_2"+antTypeStr)
        
        var animationSpeed = self.antAnimationSpeedEasy
        if (self.difficulty == "Hard") {
            animationSpeed = self.antAnimationSpeedHard
        } else if (self.difficulty == "Krazy") {
            animationSpeed = self.antAnimationSpeedKrazy
        }
        
        let moves = SKAction.animateWithTextures([move1, move2], timePerFrame: animationSpeed)
        
        node.runAction(SKAction.repeatActionForever(moves), withKey:"move")
        
        self.addChild(node)
        self.nodeQueue.append(node)
        
        let now = NSDate()

        var newInterval: Double = 0.0
        
        if (self.difficulty == "Hard") {
            newInterval = Double(self.randRange(UInt32(self.minIntervalToAddAntHard), upper: UInt32(self.maxIntervalToAddAntHard)))
        } else if (self.difficulty == "Krazy") {
            newInterval = Double(self.randRange(UInt32(self.minIntervalToAddAntKrazy), upper: UInt32(self.maxIntervalToAddAntKrazy)))
        } else {
            newInterval = Double(self.randRange(UInt32(self.minIntervalToAddAntEasy), upper: UInt32(self.maxIntervalToAddAntEasy)))
        }
        
        self.randIntervalToAddAnt = Double(newInterval)
        self.lastTimeAntAdded = NSDate()
    }
    
    func addRedRock() {
        let randomY = self.randRange(UInt32(self.yOfGround()+100), upper: UInt32(self.yMaxPlacementOfItem()))
        
        var node = SKSpriteNode(imageNamed:"redrocks")
        node.position = CGPoint(x: self.xOfRight(), y: CGFloat(randomY))
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: node.size.width, height: node.size.height))
        node.physicsBody?.restitution = 0
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = pointCategory
        node.physicsBody?.contactTestBitMask = goodGuyCategory
        node.physicsBody?.collisionBitMask = 0
        node.name = "redrock"
        
        // blink so user notices it
        let blink1 = SKTexture(imageNamed: "redrocks")
        let blink2 = SKTexture(imageNamed: "rocks")
        let blinks = SKAction.animateWithTextures([blink1, blink2], timePerFrame: 0.4)
        
        node.runAction(SKAction.repeatActionForever(blinks), withKey:"move")
        
        self.addChild(node)
        self.nodeQueue.append(node)
        
        // remember last time we did this so we only do it so often
        let now = NSDate()
        let newInterval = self.randRange(UInt32(self.minIntervalToAddRedRock), upper: UInt32(self.maxIntervalToAddRedRock))
        self.randIntervalToAddRedRock = Double(newInterval)
        self.lastTimeRedRockAdded = NSDate()
    }
    
    func addBlueRock() {
        let randomY = self.randRange(UInt32(self.yOfGround()+100), upper: UInt32(self.yMaxPlacementOfItem()))
        
        var node = SKSpriteNode(imageNamed:"bluerocks")
        node.position = CGPoint(x: self.xOfRight(), y: CGFloat(randomY))
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: node.size.width, height: node.size.height))
        node.physicsBody?.restitution = 0
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = pointCategory
        node.physicsBody?.contactTestBitMask = goodGuyCategory
        node.physicsBody?.collisionBitMask = 0
        node.name = "bluerock"
        
        // blink so user notices it
        let blink1 = SKTexture(imageNamed: "bluerocks")
        let blink2 = SKTexture(imageNamed: "rocks")
        let blinks = SKAction.animateWithTextures([blink1, blink2], timePerFrame: 0.4)
        
        node.runAction(SKAction.repeatActionForever(blinks), withKey:"move")
        
        self.addChild(node)
        self.nodeQueue.append(node)
        
        // remember last time we did this so we only do it so often
        let now = NSDate()
        let newInterval = self.randRange(UInt32(self.minIntervalToAddBlueRock), upper: UInt32(self.maxIntervalToAddBlueRock))
        let intervalForLastBlueRock = Double(now.timeIntervalSinceDate(self.lastTimeBlueRockAdded))
        self.randIntervalToAddBlueRock = Double(newInterval)
        self.lastTimeBlueRockAdded = NSDate()
    }
    
    func addBomb() {
        let randomY = self.randRange(UInt32(self.yOfGround()+100), upper: UInt32(self.yMaxPlacementOfItem()))
        
        var node = SKSpriteNode(imageNamed:"bomb_red")
        node.position = CGPoint(x: self.xOfRight(), y: CGFloat(randomY))
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: node.size.width, height: node.size.height))
        node.physicsBody?.restitution = 0
        node.physicsBody?.dynamic = false
        node.physicsBody?.categoryBitMask = pointCategory
        node.physicsBody?.contactTestBitMask = goodGuyCategory
        node.physicsBody?.collisionBitMask = 0
        node.name = "bomb"
        
        // blink so user notices it
        let blink1 = SKTexture(imageNamed: "bomb_red")
        let blink2 = SKTexture(imageNamed: "bomb_red_dark")
        let blinks = SKAction.animateWithTextures([blink1, blink2], timePerFrame: 0.4)
        
        node.runAction(SKAction.repeatActionForever(blinks), withKey:"move")
        
        self.addChild(node)
        self.nodeQueue.append(node)
        
        // remember last time we did this so we only do it so often
        let now = NSDate()
        let newInterval = self.randRange(UInt32(self.minIntervalToAddBomb), upper: UInt32(self.maxIntervalToAddBomb))
        let intervalForLastBomb = Double(now.timeIntervalSinceDate(self.lastTimeBombAdded))
        self.randIntervalToAddBomb = Double(newInterval)
        self.lastTimeBombAdded = NSDate()
    }
    
    func throw(point: CGPoint, type: String, speed: NSTimeInterval) {
        if (self.canThrow == true) {
            var node = SKSpriteNode(imageNamed: type)
            node.position = CGPoint(x: self.koala.position.x, y: CGFloat(self.koala.position.y))
            node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: node.size.width, height: node.size.height))
            node.physicsBody?.restitution = 0
            node.physicsBody?.dynamic = true
            node.physicsBody?.categoryBitMask = bulletCategory
            node.physicsBody?.contactTestBitMask = canBeShotCategory
            node.physicsBody?.collisionBitMask = 0
            node.physicsBody?.affectedByGravity = false
            node.name = type
            node.zPosition = 101
            
            let move = SKAction.moveTo(point, duration: speed)
            let removeNode = SKAction.removeFromParent()
            
            node.runAction(SKAction.repeatActionForever(SKAction.sequence([move, removeNode])))
            
            self.addChild(node)
            
            self.canThrow = false
            self.lastTimeThrown = NSDate()
        }
    }
    
    func throwRedRocks() {
        // a spray of rocks
        for i in 1...10 {
            self.canThrow = true
            self.throw(CGPoint(x: self.koala.position.x+CGFloat(1000), y: self.koala.position.y-500+CGFloat(i*100)), type: "redrock", speed: NSTimeInterval(1))
        }
    }
    
    func throwBlueRock() {
        // throw 5 rocks, one after another
        // blue rocks travel much faster than normal and red rocks
        
        var pos = CGPoint(x: self.xOfRight(), y: self.koala.position.y)
        
        self.throw(pos, type: "bluerock", speed: NSTimeInterval(0.1))
        self.canThrow = true
        self.throw(pos, type: "bluerock", speed: NSTimeInterval(0.2))
        self.canThrow = true
        self.throw(pos, type: "bluerock", speed: NSTimeInterval(0.3))
        self.canThrow = true
        self.throw(pos, type: "bluerock", speed: NSTimeInterval(0.4))
        self.canThrow = true
        self.throw(pos, type: "bluerock", speed: NSTimeInterval(0.5))
    }
    
    func SDistanceBetweenPoints(first: CGPoint , second: CGPoint ) -> CGFloat  {
        let dis = hypotf(Float(second.x - first.x), Float(second.y - first.y))
        return CGFloat(dis)
    }
    
    func addItemsToScene() {
        var addToScene = false;
        let now = NSDate()
        
        let intervalForAnt = Double(now.timeIntervalSinceDate(self.lastTimeAntAdded))
        let intervalForFly = Double(now.timeIntervalSinceDate(self.lastTimeFlyAdded))
        let intervalForRedRock = Double(now.timeIntervalSinceDate(self.lastTimeRedRockAdded))
        let intervalForBlueRock = Double(now.timeIntervalSinceDate(self.lastTimeBlueRockAdded))
        let intervalForBomb = Double(now.timeIntervalSinceDate(self.lastTimeBombAdded))
        
        if (intervalForAnt >= self.randIntervalToAddAnt && self.killQueue.count == 0) {
            self.addAnt()
        }
        
        if (intervalForFly >= self.randIntervalToAddFly && self.killQueue.count == 0) {
            self.addFly()
        }
        
        if (intervalForRedRock >= self.randIntervalToAddRedRock) {
            self.addRedRock()
        }
        
        if (intervalForBlueRock >= self.randIntervalToAddBlueRock) {
            self.addBlueRock()
        }
        
        if (intervalForBomb >= self.randIntervalToAddBomb) {
            self.addBomb()
        }
    }
    
    func loadBackground() {
        // to support a moving background we will add 3 background images,
        // one after another and when one reaches the end of the scene, we will
        // move it to the back so to create an endless moving background
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
        
        // foreground
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
        
        // add invisible barrier so our nodes don't go too high
        let topBody = SKNode()
        topBody.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: 0,y: CGFloat(self.yOfTop())+150), toPoint: CGPoint(x: self.xOfRight(), y: CGFloat(self.yOfTop())+150))
        
        topBody.physicsBody?.restitution = 0
        topBody.physicsBody?.categoryBitMask = groundCategory
        topBody.physicsBody?.dynamic = false
        self.addChild(topBody)
        
        // add invisible barrier so our nodes don't fall through
        let groundBody = SKNode()
        groundBody.physicsBody = SKPhysicsBody(edgeFromPoint: CGPoint(x: 0,y: self.yOfGround()), toPoint: CGPoint(x: self.xOfRight(), y: self.yOfGround()))
        
        groundBody.physicsBody?.restitution = 0
        groundBody.physicsBody?.categoryBitMask = groundCategory
        groundBody.physicsBody?.dynamic = false
        self.addChild(groundBody)
    }
    
    func showTextBurst(text: String, size: CGFloat) {
        let label = SKLabelNode(fontNamed: "Copperplate-Bold")
        label.text = text
        label.fontColor = SKColor.whiteColor()
        label.fontSize = size
        label.zPosition = 10
        label.position = CGPointMake(self.xOfRight()/2, self.yOfTop()/2)
        label.alpha = CGFloat(0.2)
        
        let scale = SKAction.scaleTo(CGFloat(10), duration: 0.5)
        let remove = SKAction.removeFromParent()
        
        label.runAction(SKAction.sequence([scale, remove]))
        
        self.addChild(label)
        
        self.lastTextBurst = NSDate()
    }
    
    func checkForNewClearStreak() {
        let now = NSDate()
        let intervalForTextBurst = now.timeIntervalSinceDate(self.lastTextBurst)
        
        if (self.shownHighclearStreakBurst == false && self.highclearStreak >= 1 && intervalForTextBurst >= 2) {
            if (self.clearStreak > self.highclearStreak) {
                self.textBurstQueue.append("Top Clear Streak!")
                self.shownHighclearStreakBurst = true // only show once
            }
        }
    }
    
    func checkForNewHighScore() {
        let now = NSDate()
        let intervalForTextBurst = now.timeIntervalSinceDate(self.lastTextBurst)
        
        if (self.shownHighScoreBurst == false && self.highScore >= 1 && intervalForTextBurst >= 2) {
            if (self.score > self.highScore) {
                self.textBurstQueue.append("Top Score!")
                self.shownHighScoreBurst = true // only show once
            }
        }

    }
    
    func checkForlevel() {
        let now = NSDate()
        let intervalForlevel = now.timeIntervalSinceDate(self.lastTimeLevelAdjusted)
        
        if (intervalForlevel >= self.changeLevelEvery) {
            self.lastTimeLevelAdjusted = NSDate()
            self.level = self.level + 1
            self.addDifficultyLabel() // update difficulty label
            self.addLifeBar(++self.lives) // add life for every difficulty adjustment
            //self.textBurstQueue.append(String(format:"Level %i", self.level))
            
            if (self.difficulty == "Easy") {
                self.minIntervalToAddFlyEasy--
                self.maxIntervalToAddFlyEasy--
                
                if (self.minIntervalToAddFlyEasy < 1) {
                    self.minIntervalToAddFlyEasy = 0.5
                }
                
                if (self.maxIntervalToAddFlyEasy < 1) {
                    self.maxIntervalToAddFlyEasy = 0.5
                }
            } else if (self.difficulty == "Hard") {
                self.minIntervalToAddFlyHard--
                self.maxIntervalToAddFlyHard--
                
                if (self.minIntervalToAddFlyHard < 1) {
                    self.minIntervalToAddFlyHard = 0.5
                }
                
                if (self.maxIntervalToAddFlyHard < 1) {
                    self.maxIntervalToAddFlyHard = 0.5
                }
            } else {
                self.minIntervalToAddFlyKrazy--
                self.maxIntervalToAddFlyKrazy--
                
                if (self.minIntervalToAddFlyKrazy < 1) {
                    self.minIntervalToAddFlyKrazy = 0.5
                }
                
                if (self.maxIntervalToAddFlyKrazy < 1) {
                    self.maxIntervalToAddFlyKrazy = 0.5
                }
            }
        }
    }
    
    func checkCanThrow() {
        let now = NSDate()
        
        // they can only shoot every half seconds
        let interval = now.timeIntervalSinceDate(self.lastTimeThrown)
        
        if (interval > 0.5) {
            self.canThrow = true
        }
    }
    
    func checkKillQueue() {
        let now = NSDate()
        let intervalKillQueue = now.timeIntervalSinceDate(self.lastTimeKillQueue)
        
        if (self.killQueue.count > 0) {
            let sknode = self.killQueue[0] as SKSpriteNode
            
            if (sknode.name == "ant") {
                self.killAnt(sknode)
            } else if(sknode.name == "fly") {
                self.killFly(sknode)
            }
            
            self.killQueue.removeAtIndex(0)
            self.lastTimeKillQueue = NSDate()
        }
    }
    
    func checkTextBurstQueue() {
        let now = NSDate()
        let intervalForTextBurst = now.timeIntervalSinceDate(self.lastTextBurst)
        
        if (intervalForTextBurst >= 2) {
            if (self.textBurstQueue.count > 0) {
                self.showTextBurst(self.textBurstQueue[0], size: 20)
                self.textBurstQueue.removeAtIndex(0)
            }
        }
    }
    
    func moveBackground() {
        // loop through our background images, moving each one 5 points to the left
        // if one image reaches the end of the scene, we will place it in the back
        self.enumerateChildNodesWithName("background", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let bg = node as! SKSpriteNode
            // move background to the left x points
            bg.position = CGPointMake(bg.position.x - CGFloat(self.backgroundSpeed), bg.position.y)
            
            // if background has moved out of scene, move it to the end
            if (bg.position.x <= -bg.size.width) {
                bg.position = CGPointMake(bg.position.x + bg.size.width * 3, bg.position.y)
            }
        })
    }
    
    func moveForeground() {
        self.enumerateChildNodesWithName("background2", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let bg = node as! SKSpriteNode
            // move background to the left x points
            bg.position = CGPointMake(bg.position.x - CGFloat(self.foregroundSpeed), bg.position.y)
            
            // if background has moved out of scene, move it to the end
            if (bg.position.x <= -bg.size.width) {
                bg.position = CGPointMake(bg.position.x + bg.size.width * 3, bg.position.y)
            }
        })
    }
    
    func moveItemsAlongForeground() {
        self.enumerateChildNodesWithName("poof", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let poof = node as! SKSpriteNode
            // move poof to the left x points
            poof.position = CGPointMake(poof.position.x - CGFloat(self.foregroundSpeed), poof.position.y)
        })
        
        self.enumerateChildNodesWithName("bomb", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let bomb = node as! SKSpriteNode
            // move bomb to the left x points
            bomb.position = CGPointMake(bomb.position.x - CGFloat(self.foregroundSpeed), bomb.position.y)
            
            if (bomb.position.x <= -200) {
                bomb.removeFromParent()
                self.nodeQueue.removeObject(bomb)
            }
        })
        
        self.enumerateChildNodesWithName("bluerock", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let rock = node as! SKSpriteNode
            // move rock to the left x points
            rock.position = CGPointMake(rock.position.x - CGFloat(self.foregroundSpeed), rock.position.y)
            
            if (rock.position.x <= -200) {
                rock.removeFromParent()
                self.nodeQueue.removeObject(rock)
            }
        })
        
        self.enumerateChildNodesWithName("redrock", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let rock = node as! SKSpriteNode
            // move rock to the left x points
            rock.position = CGPointMake(rock.position.x - CGFloat(self.foregroundSpeed), rock.position.y)
            
            if (rock.position.x <= -200) {
                rock.removeFromParent()
                self.nodeQueue.removeObject(rock)
            }
        })
    }
    
    override func update(currentTime: CFTimeInterval) {
        if (self.isGamePaused == true) {
            // not sure why I need to do this but if the user hits the home
            // button and it's longer than a couple of minutes before they
            // return, iOS will play the game even though it should be paused
            self.paused = true
        }
        
        if (self.isGamePaused == false && self.isGameOver == false) {
            self.moveBackground()
            self.moveForeground()
            self.moveItemsAlongForeground()
            self.checkCanThrow()
            self.addItemsToScene()
            self.checkForNewClearStreak()
            self.checkForNewHighScore()
            self.checkForlevel()
            self.checkKillQueue()
            self.checkTextBurstQueue()
            
            //println(self.koala.physicsBody?.velocity.dy)
        }
        
    }
}
