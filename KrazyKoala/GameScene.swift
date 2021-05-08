/*

Copyright (c) 2021 Andrew Schools

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

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameStartTime = Date()
    var gameOverTime = Date()
    var koala: Koala?
    var nodeQueue: [SKSpriteNode] = []
    var poofQueue: [SKSpriteNode] = []
    var killQueue: [SKSpriteNode] = []
    var textBurstQueue: [String] = []
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    var score = 0
    var antsKilled = 0
    var fliesKilled = 0
    var pauseStartTime: Date?
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
    var minIntervalToAddFireball: Double = 45.0
    var minIntervalToAddBomb: Double = 15.0
    
    var maxIntervalToAddFlyEasy: Double = 6.0
    var maxIntervalToAddAntEasy: Double = 6.0
    var maxIntervalToAddFlyHard: Double = 5.0
    var maxIntervalToAddAntHard: Double = 5.0
    var maxIntervalToAddFlyKrazy: Double = 4.0
    var maxIntervalToAddAntKrazy: Double = 4.0
    
    var maxIntervalToAddRedRock: Double = 35.0
    var maxIntervalToAddBlueRock: Double = 50.0
    var maxIntervalToAddFireball: Double = 60.0
    var maxIntervalToAddBomb: Double = 20.0
    
    var randIntervalToAddFly: Double = 2.0
    var randIntervalToAddAnt: Double = 2.0
    var randIntervalToAddRedRock: Double = 30.0
    var randIntervalToAddBlueRock: Double = 45.0
    var randIntervalToAddFireball: Double = 60.0
    var randIntervalToAddBomb: Double = 15.0
    
    var lastTimeFlyAdded = Date()
    var lastTimeAntAdded = Date()
    var lastTimeRedRockAdded = Date()
    var lastTimeBlueRockAdded = Date()
    var lastTimeFireballAdded = Date()
    var lastTimeBombAdded = Date()
    var lastTimeLevelAdjusted = Date()
    var lastTimeKillQueue = Date()
    
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
    
    var lastTimeNodeJumped = Date()
    var secsToWaitForJump: Double = 1.0
    
    var difficulty = ""
    
    var lastKill: Date? = nil
    var clearStreak = 0
    var gameHighclearStreak = 0
    
    var isGameOver = false
    var isGamePaused = false
    var isMusicEnabled = false
    
    var controller: GameViewController
    
    var highScore = 0
    var highclearStreak = 0
    
    var lastTextBurst = Date()
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
        }
        else if self.difficulty == "Krazy" {
            self.changeLevelEvery = 30.0
        }
        
        do {
            try self.audioPlayer = AVAudioPlayer(
                contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: "beet", ofType: "wav")!) as URL,
                fileTypeHint: nil
            )
        } catch {
            print("Cannot play music!")
        }
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func yOfGround() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 130
        }
        else if self.view?.bounds.width == 480 {
            return 135
        }
        else {
            return 155
        }
    }
    
    func yOfTop() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 700
        }
        else if self.view?.bounds.width == 480 {
            return 700
        }
        
        return 700
    }
    
    func yMaxPlacementOfItem() -> CGFloat {
        // We want to make sure the koala can
        // reach each item
        return self.yOfTop()-300
    }
    
    func xOfRight() -> CGFloat {
        return 1024
    }
    
    func yPosOfMenuBar() -> CGFloat {
        return self.frame.height - 150
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
            self.isPaused = true
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
    
    override func didMove(to view: SKView) {
        NotificationCenter.default.addObserver(
            self,
            selector: "fromApplicationDidBecomeActive",
            name: NSNotification.Name(rawValue: "fromApplicationDidBecomeActive"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: "fromApplicationWillResignActive",
            name: NSNotification.Name(rawValue: "fromApplicationWillResignActive"),
            object: nil
        )
        
        self.koala = Koala(gameScene: self, difficulty: self.difficulty)
        
        self.highScore = self.helpers.getHighScore(difficulty: self.difficulty)
        self.highclearStreak = self.helpers.getHighClearStreak(difficulty: self.difficulty)
        
        self.gameStartTime = Date()
        
        // We need this so the iAd delegates knows when to show
        // iAd and when to not.
        self.controller.currentSceneName = "GameScene"
        
        /*
        // If no error, we will try to display an ad, however, ...
        if self.controller.iAdError == false {
            // No iAd during game play unless on a pause.
            self.controller.adBannerView!.isHidden = true
        }
        */
        
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
        self.addScoreBoard(score: 0)
        self.addLifeBar(numLives: self.koala!.lives)
        self.addRedRockIndicator()
        self.updateRedRockIndicator(total: 0)
        self.addBlueRockIndicator()
        self.updateBlueRockIndicator(total: 0)
        self.addFireballIndicator()
        self.updateFireballIndicator(total: 0)
        self.addPauseButton()
    }
    
    func showclearStreakLabel() {
        self.helpers.removeNodeByName(scene: self, name: "clearStreakLabel")
        
        // Only show kill streak if 5 kills in a row or greater
        if self.clearStreak >= 5 {
            self.addChild(
                self.helpers.createLabel(
                    text: String(format: "Clear streak: %i", self.clearStreak),
                    fontSize: 20, position: CGPoint(x: self.xOfRight()-610, y: self.yPosOfMenuBar()-9),
                    name: "clearStreakLabel",
                    color: SKColor.white
                )
            )
            
            if self.clearStreak % 20 == 0 {
                // For every 20 kills, show text letting them know
                // of their clear streak.
                self.textBurstQueue.append("Warrior!")
            }
        }
    }
    
    func addRedRockIndicator() {
        let node = SKSpriteNode(imageNamed:"redrock")
        node.zPosition = 1
        node.position = CGPoint(x: 100, y: self.yPosOfMenuBar())
        self.addChild(node)
    }
    
    func updateRedRockIndicator(total: Int) {
        self.helpers.removeNodeByName(scene: self, name: "redRockIndicator")
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "%i", total),
                fontSize: 20,
                position: CGPoint(x: 125, y: self.yPosOfMenuBar()-9),
                name: "redRockIndicator",
                color: SKColor.white
            )
        )
    }
    
    func addBlueRockIndicator() {
        let node = SKSpriteNode(imageNamed:"bluerock")
        node.zPosition = 1
        node.position = CGPoint(x: 155, y: self.yPosOfMenuBar())
        self.addChild(node)
    }
    
    func updateBlueRockIndicator(total: Int) {
        self.helpers.removeNodeByName(scene: self, name: "blueRockIndicator")
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "%i", total),
                fontSize: 20,
                position: CGPoint(x: 180, y: self.yPosOfMenuBar()-9),
                name: "blueRockIndicator",
                color: SKColor.white
            )
        )
    }
    
    func addFireballIndicator() {
        let node = SKSpriteNode(imageNamed:"fireball")
        node.zPosition = 1
        node.xScale = 0.2
        node.yScale = 0.2
        node.position = CGPoint(x: 210, y: self.yPosOfMenuBar())
        self.addChild(node)
    }
    
    func updateFireballIndicator(total: Int) {
        self.helpers.removeNodeByName(scene: self, name: "fireballIndicator")
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "%i", total),
                fontSize: 20,
                position: CGPoint(x: 235, y: self.yPosOfMenuBar()-9),
                name: "fireballIndicator",
                color: SKColor.white
            )
        )
    }
    
    func addScoreBoard(score: Int) {
        let node = SKSpriteNode(imageNamed:"PointsBar")
        node.zPosition = 1
        node.position = CGPoint(x: self.xOfRight()-100, y: self.yPosOfMenuBar())
        self.addChild(node)
        
        self.updateScoreBoard(score: score)
    }
    
    func updateScoreBoard(score: Int) {
        self.helpers.removeNodeByName(scene: self, name: "scoreBoardLabel")
        
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "%06d", score),
                fontSize: 24,
                position: CGPoint(x: self.xOfRight()-67, y: self.yPosOfMenuBar()-16),
                name: "scoreBoardLabel",
                color: SKColor.white
            )
        )
    }
    
    func addDifficultyLabel() {
        self.helpers.removeNodeByName(scene: self, name: "difficultyLabel")
        
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "Difficulty: %@", self.difficulty),
                fontSize: 20, position: CGPoint(x: self.xOfRight()-405, y: self.yPosOfMenuBar()-9),
                name: "difficultyLabel",
                color: SKColor.white
            )
        )
    }
    
    func addLifeBar(numLives: Int) {
        self.helpers.removeNodeByName(scene: self, name: "lifeBar")
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "Lives: %i", numLives),
                fontSize: 20,
                position: CGPoint(x: self.xOfRight()-250, y: self.yPosOfMenuBar()-9),
                name: "lifeBar",
                color: SKColor.white
            )
        )
    }
    
    func addPauseButton() {
        let btn = SKSpriteNode(imageNamed:"Pausebtn")
        btn.position = CGPoint(x: 40, y: self.yPosOfMenuBar())
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
        NotificationCenter.default.removeObserver(self)
        
        self.isGameOver = true
        self.gameOverTime = Date()
        self.removeAllItems()
        self.audioPlayer.stop() // stop game music
        
        self.koala!.kill()
        
        // Dim background
        self.enumerateChildNodes(
            withName: "background",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let bg = node as! SKSpriteNode
                let colorBlack = SKAction.colorize(with: SKColor.black, colorBlendFactor: 0.7, duration: 2)
                bg.run(SKAction.sequence([colorBlack]))
            }
        )
        
        // Dim foreground
        self.enumerateChildNodes(
            withName: "background2",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let bg = node as! SKSpriteNode
                let colorBlack = SKAction.colorize(with: SKColor.black, colorBlendFactor: 0.7, duration: 2)
                bg.run(SKAction.sequence([colorBlack]))
            }
        )
        
        // Play game over sound
        self.run(self.gameOverWav, completion: {()
            // Show game over scene
            let gameOverScene = GameOverScene(size: self.size,
                                              gameViewController: self.controller,
                                              score: self.score,
                                              antsKilled: self.antsKilled,
                                              fliesKilled: self.fliesKilled,
                                              clearStreak: self.gameHighclearStreak,
                                              difficulty: self.difficulty,
                                              level: self.level)
            
            gameOverScene.scaleMode = .aspectFill
            self.view?.presentScene(gameOverScene, transition: SKTransition.moveIn(with: SKTransitionDirection.down, duration: 2))
        })
    }
    
    // Collision between nodes detected
    func didBegin(_ contact: SKPhysicsContact) {
        let body1 = contact.bodyA.node
        let body2 = contact.bodyB.node
        
        if body1 == nil || body2 == nil {
            return
        }
        
        if let e = body1 as? IEntity {
            e.contact(scene: self, other: body2!)
        }
        
        if let e = body2 as? IEntity {
            e.contact(scene: self, other: body1!)
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
                x+=1
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
            if sknode.name == "ant" || sknode.name == "fly" || sknode.name == "bomb" ||
                sknode.name == "bluerock" || sknode.name == "redrock" {
                sknode.removeFromParent()
            }
        }
    }
    
    func fireBallSeek() {
        var flys: [SKSpriteNode] = []
        
        for node in self.nodeQueue {
            let sknode = node as SKSpriteNode
            if sknode.name == "fly" {
                flys.append(sknode)
            }
        }
        
        self.enumerateChildNodes(
            withName: "fireball",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                var closetEnemy = CGPoint(x: 1000,y: 1000)
                for fly in flys {
                    let distance = abs(node.position.x - fly.position.x)
                    if distance < abs(node.position.x - closetEnemy.x) {
                        closetEnemy = fly.position
                    }
                }
                
                node.run(
                    SKAction.move(
                        to: closetEnemy, duration: TimeInterval(0.1)
                    )
                )
            }
        )
    }
    
    func addPoof(loc: CGPoint, playSound: Bool=true) {
        var ok = true
        
        self.enumerateChildNodes(
            withName: "poof",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                if node.position == loc {
                    ok = false // No need to add a poof to the same location
                }
            }
        )
        
        if ok {
            if playSound == true {
                self.run(self.poofWav)
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
            let images = SKAction.animate(with: [image1, image2, image3, image4, image5], timePerFrame: 0.2)
            
            let deQueue = SKAction.run({()
                let index = self.poofQueue.index(of: node)
                self.poofQueue.remove(at: index!)
            })
            
            node.run(SKAction.repeatForever(SKAction.sequence([images, deQueue, removeNode])))
            
            self.addChild(node)
            self.poofQueue.append(node)
        }
    }
    
    // User tapped the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var nodeName: String = ""
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name != nil {
                nodeName = node.name!
            }
        }
        
        if nodeName == "Pause" || nodeName == "PlayBtnFromDialog" {
            if self.isGameOver == false {
                if self.isPaused == true {
                    self.cancelPause()
                }
                else {
                    self.pause()
                }
            }
        }
        else if nodeName == "ReloadBtnFromDialog" && self.isGameOver == false {
            // Go to main menu
            self.audioPlayer.stop()
            let startScene = StartScene(size: self.size, gameViewController: self.controller)
            startScene.scaleMode = .aspectFill
            self.view?.presentScene(startScene)
        }
        else {
            if self.isPaused != true && self.isGameOver != true {
                if (self.koala?.position.y)! >= CGFloat(206) && (self.koala?.position.y)! <= CGFloat(209) {
                    self.koala!.jump() // jump
                }
                else {
                    // If koala is in the air and a touch is received, throw a rock
                    // instead of jumping (if they are allowed to throw a rock)
                    self.koala!.throwRock()
                }
            }
        }
    }
    
    func pause(keepTime:Bool=false) {
        self.isPaused = true
        self.isGamePaused = true
        
        if keepTime == false {
            self.pauseStartTime = Date()
        }
        
        if self.isMusicEnabled == true {
            self.audioPlayer.pause()
        }
        
        let panel = SKSpriteNode(imageNamed:"Panel3")
        panel.xScale = 1.1
        panel.yScale = 1.1
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        panel.zPosition = 102
        panel.name = "pauseDialog"
        self.addChild(panel)
        
        let ribbon = SKSpriteNode(imageNamed:"PausedRibbon")
        ribbon.xScale = 1.1
        ribbon.yScale = 1.1
        ribbon.position = CGPoint(x: self.frame.midX, y: self.frame.midY+80)
        ribbon.zPosition = 103
        ribbon.name = "pauseDialog"
        self.addChild(ribbon)
        
        let accept = SKSpriteNode(imageNamed:"Reloadbtn")
        accept.position = CGPoint(x: self.frame.midX-100, y: self.frame.midY)
        accept.zPosition = 103
        accept.name = "ReloadBtnFromDialog"
        self.addChild(accept)
        
        let warning = SKSpriteNode(imageNamed:"Playbtn")
        warning.position = CGPoint(x: self.frame.midX+100, y: self.frame.midY)
        warning.zPosition = 103
        warning.name = "PlayBtnFromDialog"
        warning.xScale = 0.7
        warning.yScale = 0.7
        self.addChild(warning)
        
        // show ad
        //self.controller.adBannerView!.isHidden = false
    }
    
    func cancelPause() {
        self.isPaused = false
        self.isGamePaused = false
        
        let now = Date()
        
        if self.isMusicEnabled == true {
            self.audioPlayer.play()
        }
        
        // Since there was a pause we need to make sure that the time elapsed
        // doesn't count towards the add item intervals because if so, items will
        // be immediately added to the scene which would be a cool hack but
        // we cannot allow that...
        
        if self.pauseStartTime != nil {
            let pauseIntervalForAnt = Double(
                self.lastTimeAntAdded.timeIntervalSince(pauseStartTime!)
            )
            let pauseIntervalForBomb = Double(
                self.lastTimeBombAdded.timeIntervalSince(pauseStartTime!)
            )
            let pauseIntervalForRedRock = Double(
                self.lastTimeRedRockAdded.timeIntervalSince(pauseStartTime!)
            )
            let pauseIntervalForBlueRock = Double(
                self.lastTimeBlueRockAdded.timeIntervalSince(pauseStartTime!)
            )
            let pauseIntervalForFly = Double(
                self.lastTimeFlyAdded.timeIntervalSince(pauseStartTime!)
            )
            let pauseIntervalForNodeJump = Double(
                self.lastTimeNodeJumped.timeIntervalSince(pauseStartTime!)
            )
            let pauseIntervalForLastTextBurst = Double(
                self.lastTextBurst.timeIntervalSince(pauseStartTime!)
            )
            let pauseIntervalForlevel = Double(
                self.lastTimeLevelAdjusted.timeIntervalSince(pauseStartTime!)
            )
            
            self.lastTimeAntAdded = Date(
                timeInterval: TimeInterval(pauseIntervalForAnt),
                since: now
            )
            self.lastTimeBombAdded = Date(
                timeInterval: TimeInterval(pauseIntervalForBomb),
                since: now
            )
            self.lastTimeRedRockAdded = Date(
                timeInterval: TimeInterval(pauseIntervalForRedRock),
                since: now
            )
            self.lastTimeBlueRockAdded = Date(
                timeInterval: TimeInterval(pauseIntervalForBlueRock),
                since: now
            )
            self.lastTimeFlyAdded = Date(
                timeInterval: TimeInterval(pauseIntervalForFly),
                since: now
            )
            self.lastTimeNodeJumped = Date(
                timeInterval: TimeInterval(pauseIntervalForNodeJump),
                since: now
            )
            self.lastTextBurst = Date(
                timeInterval: TimeInterval(pauseIntervalForLastTextBurst),
                since: now
            )
            self.lastTimeLevelAdjusted = Date(
                timeInterval: TimeInterval(pauseIntervalForlevel),
                since: now
            )
        }
        
        self.pauseStartTime = nil
        
        // Remove dialog items
        self.enumerateChildNodes(
            withName: "pauseDialog",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                node.removeFromParent()
            }
        )
        
        self.enumerateChildNodes(
            withName: "PlayBtnFromDialog",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                node.removeFromParent()
            }
        )
        
        self.enumerateChildNodes(
            withName: "ReloadBtnFromDialog",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                node.removeFromParent()
            }
        )
        
        // Hide ad
        //self.controller.adBannerView!.isHidden = true
    }
    
    func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
    }
    
    func addItemsToScene() {
        let now = Date()
        
        let intervalForAnt = Double(now.timeIntervalSince(self.lastTimeAntAdded))
        let intervalForFly = Double(now.timeIntervalSince(self.lastTimeFlyAdded))
        let intervalForRedRock = Double(now.timeIntervalSince(self.lastTimeRedRockAdded))
        let intervalForBlueRock = Double(now.timeIntervalSince(self.lastTimeBlueRockAdded))
        let intervalForFireball = Double(now.timeIntervalSince(self.lastTimeFireballAdded))
        let intervalForBomb = Double(now.timeIntervalSince(self.lastTimeBombAdded))
        
        if intervalForAnt >= self.randIntervalToAddAnt && self.killQueue.count == 0 {
            let ant = Ant(gameScene: self, difficulty: self.difficulty)
            self.addChild(ant)
            self.nodeQueue.append(ant)
            
            var newInterval: Double = 0.0
            
            if self.difficulty == "Hard" {
                newInterval = Double(
                    self.randRange(
                        lower: UInt32(self.minIntervalToAddAntHard),
                        upper: UInt32(self.maxIntervalToAddAntHard)
                    )
                )
            }
            else if self.difficulty == "Krazy" {
                newInterval = Double(
                    self.randRange(
                        lower: UInt32(self.minIntervalToAddAntKrazy),
                        upper: UInt32(self.maxIntervalToAddAntKrazy)
                    )
                )
            }
            else {
                newInterval = Double(
                    self.randRange(
                        lower: UInt32(self.minIntervalToAddAntEasy),
                        upper: UInt32(self.maxIntervalToAddAntEasy)
                    )
                )
            }
            
            self.randIntervalToAddAnt = Double(newInterval)
            self.lastTimeAntAdded = Date()
        }
        
        if intervalForFly >= self.randIntervalToAddFly && self.killQueue.count == 0 {
            let fly = Fly(gameScene: self, difficulty: self.difficulty)
            self.addChild(fly)
            self.nodeQueue.append(fly)
            
            var newInterval: Double = 0.0
            
            if self.difficulty == "Hard" {
                if self.minIntervalToAddFlyHard == self.maxIntervalToAddFlyHard {
                    newInterval = self.minIntervalToAddFlyHard
                }
                else {
                    newInterval = Double(
                        self.randRange(
                            lower: UInt32(self.minIntervalToAddFlyHard),
                            upper: UInt32(self.maxIntervalToAddFlyHard)
                        )
                    )
                }
            }
            else if self.difficulty == "Krazy" {
                if self.minIntervalToAddFlyKrazy == self.maxIntervalToAddFlyKrazy {
                    newInterval = self.minIntervalToAddFlyKrazy
                }
                else {
                    newInterval = Double(
                        self.randRange(
                            lower: UInt32(self.minIntervalToAddFlyKrazy),
                            upper: UInt32(self.maxIntervalToAddFlyKrazy)
                        )
                    )
                }
            }
            else {
                if self.minIntervalToAddFlyEasy == self.maxIntervalToAddFlyEasy {
                    newInterval = self.minIntervalToAddFlyEasy
                }
                else {
                    newInterval = Double(
                        self.randRange(
                            lower: UInt32(self.minIntervalToAddFlyEasy),
                            upper: UInt32(self.maxIntervalToAddFlyEasy)
                        )
                    )
                }
            }
            
            self.randIntervalToAddFly = newInterval
            self.lastTimeFlyAdded = Date()
        }
        
        if intervalForRedRock >= self.randIntervalToAddRedRock {
            let rock = RedRockItem(gameScene: self, difficulty: self.difficulty)
            self.addChild(rock)
            self.nodeQueue.append(rock)
            
            // Remember last time we did this so we only do it so often
            let newInterval = self.randRange(
                lower: UInt32(self.minIntervalToAddRedRock),
                upper: UInt32(self.maxIntervalToAddRedRock)
            )
            self.randIntervalToAddRedRock = Double(newInterval)
            self.lastTimeRedRockAdded = Date()

        }
        
        if intervalForBlueRock >= self.randIntervalToAddBlueRock {
            let rock = BlueRockItem(gameScene: self, difficulty: self.difficulty)
            self.addChild(rock)
            self.nodeQueue.append(rock)
            
            // Remember last time we did this so we only do it so often
            let newInterval = self.randRange(
                lower: UInt32(self.minIntervalToAddBlueRock),
                upper: UInt32(self.maxIntervalToAddBlueRock)
            )
            self.randIntervalToAddBlueRock = Double(newInterval)
            self.lastTimeBlueRockAdded = Date()
        }
        
        if intervalForFireball >= self.randIntervalToAddFireball {
            let fireball = FireballItem(gameScene: self, difficulty: self.difficulty)
            self.addChild(fireball)
            self.nodeQueue.append(fireball)
            
            // Remember last time we did this so we only do it so often
            let newInterval = self.randRange(
                lower: UInt32(self.minIntervalToAddFireball),
                upper: UInt32(self.maxIntervalToAddFireball)
            )
            self.randIntervalToAddFireball = Double(newInterval)
            self.lastTimeFireballAdded = Date()
        }
        
        if intervalForBomb >= self.randIntervalToAddBomb {
            let bomb = BombItem(gameScene: self, difficulty: self.difficulty)
            self.addChild(bomb)
            self.nodeQueue.append(bomb)
            
            // Remember last time we did this so we only do it so often
            let newInterval = self.randRange(
                lower: UInt32(self.minIntervalToAddBomb),
                upper: UInt32(self.maxIntervalToAddBomb)
            )
            self.randIntervalToAddBomb = Double(newInterval)
            self.lastTimeBombAdded = Date()
        }
    }
    
    func loadBackground() {
        // To support a moving background we will add 3 background images,
        // one after another and when one reaches the end of the scene, we will
        // move it to the back so to create an endless moving background.
        for i in 0...3 {
            var bg = SKSpriteNode()
            if UIDevice.current.userInterfaceIdiom == .pad {
                bg = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1280x800")
            }
            else {
                bg = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1920x640")
            }
            
            if self.view?.bounds.width == 480 {
                bg.yScale = 1.1
                bg.xScale = 1.1
            }
            
            bg.position = CGPoint(x: CGFloat(i * Int(bg.size.width)), y: self.size.height/2)
            bg.name = "background";
            self.addChild(bg)
        }
        
        // Foreground
        for i in 0...3 {
            var bg = SKSpriteNode()
            if UIDevice.current.userInterfaceIdiom == .pad || self.view?.bounds.width == 480 {
                bg = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_ground_1280x800")
                bg.position = CGPoint(x: CGFloat(i * Int(bg.size.width)), y: 75)
            }
            else {
                bg = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_ground_1920x640")
                bg.position = CGPoint(x: CGFloat(i * Int(bg.size.width)), y: 120)
            }
            
            bg.name = "background2";
            bg.zPosition = 2
            self.addChild(bg)
        }
        
        // Add invisible barrier so our nodes don't go too high
        let topBody = SKNode()
        topBody.physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: 0,y: CGFloat(self.yOfTop())+150),
            to: CGPoint(x: self.xOfRight(), y: CGFloat(self.yOfTop())+150)
        )
        
        topBody.physicsBody?.restitution = 0
        topBody.physicsBody?.categoryBitMask = groundCategory
        topBody.physicsBody?.isDynamic = false
        self.addChild(topBody)
        
        // Add invisible barrier so our nodes don't fall through
        let groundBody = SKNode()
        groundBody.physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: 0,y: self.yOfGround()),
            to: CGPoint(x: self.xOfRight(), y: self.yOfGround())
        )
        
        groundBody.physicsBody?.restitution = 0
        groundBody.physicsBody?.categoryBitMask = groundCategory
        groundBody.physicsBody?.isDynamic = false
        groundBody.name = "ground"
        self.addChild(groundBody)
    }
    
    func showTextBurst(text: String) {
        let panel = SKSpriteNode(imageNamed:"jumbotron")
        
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY+150)
        panel.zPosition = 9
        panel.name = "jumbotron"
        panel.alpha = 0.5
        self.addChild(panel)
        
        var size = CGFloat(20.0)
        if text.count >= 20 {
            size = CGFloat(16.0)
        }
        
        self.addChild(
            self.helpers.createLabel(
                text: text,
                fontSize: size,
                position: CGPoint(x: panel.frame.midX, y: panel.frame.midY-7),
                name: "jumbotron",
                color: SKColor.white
            )
        )
        
        self.lastTextBurst = Date()
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
        let now = Date()
        let intervalForTextBurst = now.timeIntervalSince(self.lastTextBurst)
        
        if self.shownHighclearStreakBurst == false && self.highclearStreak >= 1 && intervalForTextBurst >= 2 {
            if self.clearStreak > self.highclearStreak {
                self.textBurstQueue.append("Top Clear Streak!")
                self.shownHighclearStreakBurst = true // Only show once
            }
        }
    }
    
    func checkForNewHighScore() {
        let now = Date()
        let intervalForTextBurst = now.timeIntervalSince(self.lastTextBurst)
        
        if self.shownHighScoreBurst == false && self.highScore >= 1 && intervalForTextBurst >= 2 {
            if self.score > self.highScore {
                self.textBurstQueue.append("Top Score!")
                self.shownHighScoreBurst = true // Only show once
            }
        }

    }
    
    func checkForlevel() {
        let now = Date()
        let intervalForlevel = now.timeIntervalSince(self.lastTimeLevelAdjusted)
        
        if intervalForlevel >= self.changeLevelEvery {
            self.lastTimeLevelAdjusted = Date()
            self.level = self.level + 1
            self.addDifficultyLabel() // Update difficulty label
            self.koala!.lives+=1
            self.addLifeBar(numLives: self.koala!.lives) // Add life for every difficulty adjustment
            
            if self.difficulty == "Easy" {
                self.minIntervalToAddFlyEasy-=1
                self.maxIntervalToAddFlyEasy-=1
                
                if self.minIntervalToAddFlyEasy < 1 {
                    self.minIntervalToAddFlyEasy = 0.5
                }
                
                if self.maxIntervalToAddFlyEasy < 1 {
                    self.maxIntervalToAddFlyEasy = 0.5
                }
            }
            else if self.difficulty == "Hard" {
                self.minIntervalToAddFlyHard-=1
                self.maxIntervalToAddFlyHard-=1
                
                if self.minIntervalToAddFlyHard < 1 {
                    self.minIntervalToAddFlyHard = 0.5
                }
                
                if self.maxIntervalToAddFlyHard < 1 {
                    self.maxIntervalToAddFlyHard = 0.5
                }
            }
            else {
                self.minIntervalToAddFlyKrazy-=1
                self.maxIntervalToAddFlyKrazy-=1
                
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
            let sknode = self.killQueue[0] as! IEntity
            sknode.kill()
            
            self.killQueue.remove(at: 0)
            self.lastTimeKillQueue = Date()
        }
    }
    
    func checkTextBurstQueue() {
        let now = Date()
        let intervalForTextBurst = now.timeIntervalSince(self.lastTextBurst)
        
        if intervalForTextBurst >= 2 {
            // remove old
            self.enumerateChildNodes(
                withName: "jumbotron",
                using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    node.removeFromParent()
                }
            )
            
            if self.textBurstQueue.count > 0 {
                self.showTextBurst(text: self.textBurstQueue[0])
                self.textBurstQueue.remove(at: 0)
            }
        }
    }
    
    func moveBackground() {
        // Loop through our background images, moving each one 5 points to the left.
        // If one image reaches the end of the scene, we will place it in the back.
        self.enumerateChildNodes(
            withName: "background",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let bg = node as! SKSpriteNode
                // Move background to the left x points
                bg.position = CGPoint(x: bg.position.x - CGFloat(self.backgroundSpeed), y: bg.position.y)
                
                // If background has moved out of scene, move it to the end
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPoint(x: bg.position.x + bg.size.width * 3, y: bg.position.y)
                }
            }
        )
    }
    
    func moveForeground() {
        self.enumerateChildNodes(
            withName: "background2",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let bg = node as! SKSpriteNode
                // Move background to the left x points
                bg.position = CGPoint(x: bg.position.x - CGFloat(self.foregroundSpeed), y: bg.position.y)
                
                // If background has moved out of scene, move it to the end
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPoint(x: bg.position.x + bg.size.width * 3, y: bg.position.y)
                }
            }
        )
    }
    
    func moveItemsAlongForeground() {
        self.enumerateChildNodes(
            withName: "poof",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let poof = node as! SKSpriteNode
                // Move poof to the left x points
                poof.position = CGPoint(x: poof.position.x - CGFloat(self.foregroundSpeed), y: poof.position.y)
            }
        )
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        if self.isGamePaused == true {
            // Not sure why I need to do this but if the user hits the home
            // button and it's longer than a couple of minutes before they
            // return, iOS will play the game even though it should be paused.
            self.isPaused = true
        }
        
        if self.isGamePaused == false && self.isGameOver == false {
            self.koala!.update(currentTime: currentTime)
            
            // For each entity in the scene, execute their
            // update method so they can do what they need
            // to do during this frame cycle.
            for node in self.nodeQueue {
                let entity = node as! IEntity
                entity.update(currentTime: currentTime)
            }
            
            self.moveBackground()
            self.moveForeground()
            self.fireBallSeek()
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
