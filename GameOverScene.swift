//
//  GameOverScene.swift
//  KrazyKoala
//
//  Created by Andrew Schools on 1/4/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

import SpriteKit
import iAd

class GameOverScene: SKScene {
    var difficulty = ""
    var loadTime = NSDate()
    var playedWav = false
    
    var lastScore = 0
    var lastclearStreak = 0
    var lastLevel = 0
    
    var currentScore = 0
    var highScore = 0
    
    var currentclearStreak = 0
    var highclearStreak = 0
    
    var currentLevel = 0
    var highLevel = 0
    
    var antsKilled = 0
    var fliesKilled = 0
    
    var controller: GameViewController
    
    var newHighScore = false
    var newClearStreak = false
    var newHighLevel = false
    var newHighScoreShown = false
    var newClearStreakShown = false
    var newHighLevelShown = false
    
    var helpers = Helpers()
    var gameCenterController = GameCenterController()
    
    var banner = SKSpriteNode()
    var panel = SKSpriteNode()
    
    init(size: CGSize, gameViewController: GameViewController, score: Int, antsKilled: Int, fliesKilled: Int, clearStreak: Int, difficulty: String, level: Int) {
        self.controller = gameViewController
        self.currentScore = score
        self.antsKilled = antsKilled
        self.fliesKilled = fliesKilled
        self.currentclearStreak = clearStreak
        self.difficulty = difficulty
        self.currentLevel = level
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showGameOverWindow() {
        self.addChild(self.helpers.createLabel(String(format: "Number of insects cleared:"), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), self.frame.height-300), color: SKColor.blackColor(), name: "screenItem"))
        
        let antsClearedLabel = self.helpers.createLabel(String(format: "%i", self.antsKilled), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame)-125, self.frame.height-340), color: SKColor.blackColor(), name: "screenItem")
        self.addChild(antsClearedLabel)
        
        let fliesClearedLabel = self.helpers.createLabel(String(format: "%i", self.fliesKilled), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), self.frame.height-340), color: SKColor.blackColor(), name: "screenItem")
        self.addChild(fliesClearedLabel)
        
        let plusLabel = self.helpers.createLabel(" + ", fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame)-60, CGRectGetMidY(antsClearedLabel.frame)-60), color: SKColor.blackColor(), name: "screenItem")
        self.addChild(plusLabel)
        
        let equalLabel = self.helpers.createLabel(" = ", fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame)+45, CGRectGetMidY(antsClearedLabel.frame)-60), color: SKColor.blackColor(), name: "screenItem")
        self.addChild(equalLabel)
        
        let clearedLabel = self.helpers.createLabel(String(format: "%i", self.fliesKilled+self.antsKilled), fontSize: 36, position: CGPointMake(CGRectGetMidX(self.frame)+125, CGRectGetMidY(antsClearedLabel.frame)-67), color: SKColor.blackColor(), name: "screenItem")
        self.addChild(clearedLabel)
        
        var antnodeBlack = SKSpriteNode(imageNamed:"ant_stand_black")
        antnodeBlack.position = CGPointMake(CGRectGetMidX(antsClearedLabel.frame), CGRectGetMidY(antsClearedLabel.frame)-60)
        antnodeBlack.name = "screenItem"
        antnodeBlack.zPosition = 2
        self.addChild(antnodeBlack)
        
        var flynode = SKSpriteNode(imageNamed:"fly_1")
        flynode.position = CGPointMake(CGRectGetMidX(fliesClearedLabel.frame), CGRectGetMidY(fliesClearedLabel.frame)-60)
        flynode.name = "screenItem"
        flynode.zPosition = 2
        self.addChild(flynode)
        
        var clearnode = SKSpriteNode(imageNamed:"poof1_white")
        clearnode.position = CGPointMake(CGRectGetMidX(clearedLabel.frame), CGRectGetMidY(fliesClearedLabel.frame)-60)
        clearnode.name = "screenItem"
        clearnode.zPosition = 2
        self.addChild(clearnode)
        
        let totalClearedLabel = self.helpers.createLabel(String(format: "Clear streak: %i", self.currentclearStreak), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), self.frame.height-475), color: SKColor.blackColor(), name: "screenItem")
        self.addChild(totalClearedLabel)
        
        self.addFacebookButton("game")
    }
    
    func showNewHighScore() {
        self.newHighScoreShown = true
        
        self.helpers.removeNodeByName(self, name: "screenItem")
        
        let wav = SKAction.playSoundFileNamed("success.wav", waitForCompletion: false)
        self.runAction(wav)
        self.playedWav = true
        
        self.banner.texture = SKTexture(imageNamed: "Congratulations")
        
        let star = SKSpriteNode(imageNamed:"Star")
        star.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+20)
        star.zPosition = 2
        star.name = "screenItem"
        star.xScale = 3.5
        star.yScale = 3.5
        star.alpha = 0.3
        
        self.addChild(star)
        
        let label = self.helpers.createLabel("Best score yet!", fontSize: 36, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+30), name: "screenItem", color: SKColor.blackColor())
        
        self.addChild(label)
        
        let oldScoreLabel = self.helpers.createLabel("Old: " + String(self.highScore) + "     New: " + String(self.currentScore), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-10), name: "screenItem", color: SKColor.blackColor())
        
        self.addChild(oldScoreLabel)
        
        self.addFacebookButton("score")
    }
    
    func showNewClearStreak() {
        self.newClearStreakShown = true
        
        self.helpers.removeNodeByName(self, name: "screenItem")
        
        let wav = SKAction.playSoundFileNamed("success.wav", waitForCompletion: false)
        self.runAction(wav)
        self.playedWav = true
        
        self.banner.texture = SKTexture(imageNamed: "Congratulations")
        
        let star = SKSpriteNode(imageNamed:"Star")
        star.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+20)
        star.zPosition = 2
        star.name = "screenItem"
        star.xScale = 3.5
        star.yScale = 3.5
        star.alpha = 0.3
        
        self.addChild(star)
        
        let label = self.helpers.createLabel("Best clear streak yet!", fontSize: 36, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+30), name: "screenItem", color: SKColor.blackColor())
        
        self.addChild(label)
        
        let oldScoreLabel = self.helpers.createLabel("Old: " + String(self.highclearStreak) + "     New: " + String(self.currentclearStreak), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-10), name: "screenItem", color: SKColor.blackColor())
        
        self.addChild(oldScoreLabel)
        
        self.addFacebookButton("clearStreak")
    }
    
    func showNewHighLevel() {
        self.newHighLevelShown = true
        
        self.helpers.removeNodeByName(self, name: "screenItem")
        
        let wav = SKAction.playSoundFileNamed("success.wav", waitForCompletion: false)
        self.runAction(wav)
        self.playedWav = true
        
        self.banner.texture = SKTexture(imageNamed: "Congratulations")
        
        let star = SKSpriteNode(imageNamed:"Star")
        star.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+20)
        star.zPosition = 2
        star.name = "screenItem"
        star.xScale = 3.5
        star.yScale = 3.5
        star.alpha = 0.3
        
        self.addChild(star)
        
        let label = self.helpers.createLabel("Highest level yet!", fontSize: 36, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+30), name: "screenItem", color: SKColor.blackColor())
        
        self.addChild(label)
        
        let oldScoreLabel = self.helpers.createLabel("Old: " + String(self.highLevel) + "     New: " + String(self.currentLevel), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-10), name: "screenItem", color: SKColor.blackColor())
        
        self.addChild(oldScoreLabel)
        
        self.addFacebookButton("level")
    }
    
    func addFacebookButton(name: String) {
        let facebook = SKSpriteNode(imageNamed:"Facebook2")
        facebook.position = CGPointMake(CGRectGetMidX(self.panel.frame), CGRectGetMidY(self.panel.frame)-145)
        facebook.zPosition = 2
        facebook.name = "Facebook_" + name
        self.addChild(facebook)
    }

    override func didMoveToView(view: SKView) {
        if (self.controller.iAdError == true) {
            if (self.controller.isLoadingiAd == false) {
                // there was an error loading iAd so let's try again
                self.controller.loadAds()
            }
        } else {
            // we already have loaded iAd so let's just show it
            self.controller.adBannerView?.hidden = false
        }
        
        let lastScore = self.helpers.getLastScore(self.difficulty)
        let lastClearStreak = self.helpers.getLastClearStreak(self.difficulty)
        let lastLevel = self.helpers.getLastLevel(self.difficulty)
        
        let highScore = self.helpers.getHighScore(self.difficulty)
        let highClearStreak = self.helpers.getHighClearStreak(self.difficulty)
        let highLevel = self.helpers.getHighLevel(self.difficulty)
        
        self.lastScore = lastScore
        self.lastclearStreak = lastClearStreak
        self.lastLevel = lastLevel
        
        self.highScore = highScore
        self.highclearStreak = highClearStreak
        self.highLevel = highLevel
        
        // save current stats so we can show them how their last
        // game was when we come back to this scene
        self.helpers.saveLastScore(self.currentScore, difficulty: self.difficulty)
        self.helpers.saveLastClearStreak(self.currentclearStreak, difficulty: self.difficulty)
        self.helpers.saveLastLevel(self.currentLevel, difficulty: self.difficulty)
        
        if (self.currentScore > highScore) {
            // save new high score
            self.helpers.saveHighScore(self.currentScore, difficulty: self.difficulty)
            self.newHighScore = true
        }
        
        if (self.helpers.getGameCenterSetting() == true) {
            // save score to game center
            self.gameCenterController.saveScore("Score",  score: self.currentScore, difficulty: self.difficulty)
        }
        
        if (self.currentclearStreak > highclearStreak) {
            // save a new high kill streak
            self.helpers.saveHighClearStreak(self.currentclearStreak, difficulty: self.difficulty)
            self.newClearStreak = true
        }
        
        if (self.helpers.getGameCenterSetting() == true) {
            // save score to game center
            self.gameCenterController.saveScore("ClearStreak",  score: self.currentclearStreak, difficulty: self.difficulty)
        }
        
        if (self.currentLevel > highLevel) {
            // save new high difficulty adjustment
            self.helpers.saveHighLevel(self.currentLevel, difficulty: self.difficulty)
            self.newHighLevel = true
        }
        
        if (self.helpers.getGameCenterSetting() == true) {
            // save difficulty adjustment to game center
            self.gameCenterController.saveScore("Level",  score: self.currentLevel, difficulty: self.difficulty)
        }
        
        self.loadBackground()
        self.showGameOverWindow()
    }
    
    func loadBackground() {
        var background = SKSpriteNode()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            background = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1280x800")
        } else {
            background = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1920x640")
        }
        
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        if self.view?.bounds.width == 480 {
            background.yScale = 1.1
            background.xScale = 1.1
        }
        
        self.addChild(background)
        
        self.banner = SKSpriteNode(imageNamed:"GameOverRibbon")
        self.banner.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height-200)
        self.banner.zPosition = 4
        self.banner.name = name
        self.banner.xScale = 1.5
        self.banner.yScale = 1.5
        self.addChild(self.banner)
        
        self.panel = SKSpriteNode(imageNamed:"Panel")
        self.panel.xScale = 1
        self.panel.yScale = 1
        self.panel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.panel.zPosition = 1
        self.addChild(self.panel)
        
        var node = SKSpriteNode(imageNamed:"Forwardbtn")
        node.xScale = 1.5
        node.yScale = 1.5
        node.position = CGPointMake(self.frame.width-200, CGRectGetMidY(self.frame))
        node.zPosition = 1
        node.name = "Forward"
        self.addChild(node)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var proceed = false
        var name = ""
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if (node.name != nil) {
                name = node.name!
                
                if node.name == "Forward" {
                    proceed = true
                }
            }
        }
        
        // if proceed is false, they clicked an ad
        if (proceed == true) {
            if (self.newHighScore == true && self.newHighScoreShown == false) {
                // new high score
                self.showNewHighScore()
            } else if (self.newClearStreak == true && self.newClearStreakShown == false) {
                // new clear streak
                self.showNewClearStreak()
            //} else if (self.newHighLevel == true && self.newHighLevelShown == false) {
                // new high level
                //self.showNewHighLevel()
            } else {
                // send them back to the start menu
                let startScene = StartScene(size: self.size, gameViewController: self.controller)
                startScene.scaleMode = .AspectFill
                self.view?.presentScene(startScene)
            }
        } else if (name == "Facebook_score") {
            let facebookhelpers = FacebookHelpers()
            facebookhelpers.sendPostWithScore(Int32(self.currentScore), clearStreak: Int32(self.currentclearStreak), level: Int32(self.currentLevel), type: "score", difficulty: self.difficulty)
        } else if (name == "Facebook_clearStreak") {
            let facebookhelpers = FacebookHelpers()
            facebookhelpers.sendPostWithScore(Int32(self.currentScore), clearStreak: Int32(self.currentclearStreak), level: Int32(self.currentLevel), type: "clearStreak", difficulty: self.difficulty)
        } else if (name == "Facebook_level") {
            let facebookhelpers = FacebookHelpers()
            facebookhelpers.sendPostWithScore(Int32(self.currentLevel), clearStreak: Int32(self.currentclearStreak), level: Int32(self.currentLevel), type: "level", difficulty: self.difficulty)
        } else if (name == "Facebook_game") {
            let facebookhelpers = FacebookHelpers()
            facebookhelpers.sendPostWithScore(Int32(self.currentScore), clearStreak: Int32(self.currentclearStreak), level: Int32(self.currentLevel), type: "game", difficulty: self.difficulty)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {

    }

}