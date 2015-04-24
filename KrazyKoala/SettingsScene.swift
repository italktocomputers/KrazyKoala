//
//  SettingsScene.swift
//  KrazyKoala
//
//  Created by Andrew Schools on 1/4/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

import SpriteKit
import iAd

class SettingsScene: SKScene {
    var controller: GameViewController?
    var gameCenterController = GameCenterController()
    var helpers = Helpers()
    
    var vibrationSwitch = SKSpriteNode()
    var musicSwitch = SKSpriteNode()
    var gameCenterSwitch = SKSpriteNode()
    
    init(size: CGSize, gameViewController: GameViewController) {
        self.controller = gameViewController
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        if (self.controller!.iAdError == true) {
            if (self.controller!.isLoadingiAd == false) {
                // there was an error loading iAd so let's try again
                self.controller!.loadAds()
            }
        } else {
            // we already have loaded iAd so let's just show it
            self.controller!.adBannerView?.hidden = false
        }
        
        var background = SKSpriteNode()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            background = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1280x800")
        } else {
            background = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1920x640")
        }
        
        if self.view?.bounds.width == 480 {
            background.yScale = 1.1
            background.xScale = 1.1
        }
        
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(background)
        
        var panel = SKSpriteNode(imageNamed:"Panel")
        panel.xScale = 1.1
        panel.yScale = 1.1
        panel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        panel.zPosition = 1
        self.addChild(panel)
        
        let banner = SKSpriteNode(imageNamed:"KrazyKoalaRibbon")
        banner.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height-200)
        banner.zPosition = 2
        banner.name = name
        banner.xScale = 1.5
        banner.yScale = 1.5
        self.addChild(banner)
        
        self.addBackButton()
        
        // vibration
        self.addChild(self.helpers.createLabel(String(format: "Vibrate on: "), fontSize: 24, position: CGPointMake(CGRectGetMidX(panel.frame)-200, CGRectGetMidY(panel.frame)+75)))
        
        if (self.helpers.getVibrationSetting() == true) {
            self.vibrationSwitch = SKSpriteNode(imageNamed:"button_checked")
        } else {
            self.vibrationSwitch = SKSpriteNode(imageNamed:"button_unchecked")
        }
        
        self.vibrationSwitch.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+75)
        self.vibrationSwitch.name = "vibration"
        self.vibrationSwitch.zPosition = 2
        self.addChild(self.vibrationSwitch)
        
        // play music
        self.addChild(self.helpers.createLabel(String(format: "Music on: "), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame)-200, CGRectGetMidY(self.frame))))
        
        if (self.helpers.getMusicSetting() == true) {
            self.musicSwitch = SKSpriteNode(imageNamed:"button_checked")
        } else {
            self.musicSwitch = SKSpriteNode(imageNamed:"button_unchecked")
        }
        
        self.musicSwitch.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.musicSwitch.name = "music"
        self.musicSwitch.zPosition = 2
        self.addChild(self.musicSwitch)
        
        // game center
        self.addChild(self.helpers.createLabel(String(format: "Game center on: "), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame)-200, CGRectGetMidY(self.frame)-75)))
        
        if (self.helpers.getGameCenterSetting() == true) {
            self.gameCenterSwitch = SKSpriteNode(imageNamed:"button_checked")
        } else {
            self.gameCenterSwitch = SKSpriteNode(imageNamed:"button_unchecked")
        }
        
        self.gameCenterSwitch.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-75)
        self.gameCenterSwitch.name = "gamecenter"
        self.gameCenterSwitch.zPosition = 2
        self.addChild(self.gameCenterSwitch)
        
        // clear stats
        self.addChild(self.helpers.createLabel(String(format: "Clear Stats"), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame)+250, CGRectGetMidY(self.frame)-175), color: SKColor.blueColor()))
    }
    
    func addBackButton() {
        var node = SKSpriteNode(imageNamed:"Backbtn")
        node.xScale = 1.5
        node.yScale = 1.5
        node.position = CGPointMake(175, CGRectGetMidY(self.frame))
        node.zPosition = 2
        node.name = "Back"
        self.addChild(node)
    }
    
    func reportScoresToGameCenter() {
        let topScoreEasy = self.helpers.getHighScore("Easy")
        let topScoreHard = self.helpers.getHighScore("Hard")
        let topScoreKrazy = self.helpers.getHighScore("Krazy")
        
        let topClearStreakEasy = self.helpers.getHighClearStreak("Easy")
        let topClearStreakHard = self.helpers.getHighClearStreak("Hard")
        let topClearStreakKrazy = self.helpers.getHighClearStreak("Krazy")
        
        // report top scores for the first time
        self.gameCenterController.saveScore("Score",  score: topScoreEasy, difficulty: "Easy")
        self.gameCenterController.saveScore("ClearStreak",  score: topClearStreakEasy, difficulty: "Easy")
        
        self.gameCenterController.saveScore("Score",  score: topScoreHard, difficulty: "Hard")
        self.gameCenterController.saveScore("ClearStreak",  score: topClearStreakHard, difficulty: "Hard")
        
        self.gameCenterController.saveScore("Score",  score: topScoreKrazy, difficulty: "Krazy")
        self.gameCenterController.saveScore("ClearStreak",  score: topClearStreakKrazy, difficulty: "Krazy")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var difficulty = ""
        var nodeName = ""
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if (node.name != nil) {
                nodeName = node.name!
            }
            
            if (nodeName == "Back") {
                // go back to start menu
                let startScene = StartScene(size: self.size, gameViewController: self.controller!)
                startScene.scaleMode = .AspectFill
                self.view?.presentScene(startScene)
            } else if (nodeName == "music") {
                if (self.helpers.getMusicSetting() == true) {
                    self.helpers.saveMusicSetting(false)
                    self.musicSwitch.texture = SKTexture(imageNamed: "button_unchecked")
                } else {
                    self.helpers.saveMusicSetting(true)
                    self.musicSwitch.texture = SKTexture(imageNamed: "button_checked")
                }
            } else if (nodeName == "vibration") {
                if (self.helpers.getVibrationSetting() == true) {
                    self.helpers.saveVibrationSetting(false)
                    self.vibrationSwitch.texture = SKTexture(imageNamed: "button_unchecked")
                } else {
                    self.helpers.saveVibrationSetting(true)
                    self.vibrationSwitch.texture = SKTexture(imageNamed: "button_checked")
                }
            } else if (nodeName == "gamecenter") {
                if (self.helpers.getGameCenterSetting() == true) {
                    self.helpers.saveGameCenterSetting(false)
                    self.gameCenterSwitch.texture = SKTexture(imageNamed: "button_unchecked")
                } else {
                    self.helpers.saveGameCenterSetting(true)
                    self.gameCenterSwitch.texture = SKTexture(imageNamed: "button_checked")
                    
                    // enable game center
                    if (self.view != nil && self.view!.window != nil && self.view!.window!.rootViewController != nil) {
                        // when they enable game center we want to report their top scores
                        self.gameCenterController.authenticateLocalPlayer(self.view!.window!.rootViewController!, callback: self.reportScoresToGameCenter)
                        //println("Update gamecenter stats")
                    }
                }
            } else if (nodeName == "Clear Stats") {
                let confirmScene = ConfirmClearStatsScene(size: self.size, gameViewController: self.controller!)
                confirmScene.scaleMode = .AspectFill
                self.view?.presentScene(confirmScene)
            }
        }
    }
}