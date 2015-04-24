//
//  StagingScene.swift
//  KrazyKoala
//
//  Created by Andrew Schools on 1/4/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

import SpriteKit
import iAd

class StagingScene: SKScene {
    var controller: GameViewController?
    var helpers = Helpers()
    var gameCenterController = GameCenterController()
    var difficulty = ""
    
    init(size: CGSize, gameViewController: GameViewController, difficulty: String) {
        self.controller = gameViewController
        self.difficulty = difficulty
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
        
        //self.addHighScorePanel(panel)
        //self.addHighClearStreakPanel(panel)
        
        self.addBestGameStats()
        self.addLastGameStats()
        self.addPlayButton(panel)
        self.addBackButton(panel)
    }
    
    func addBestGameStats() {
        var panel = SKSpriteNode(imageNamed:"Panel2")
        panel.xScale = 1.1
        panel.yScale = 1.1
        panel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+35)
        panel.zPosition = 2
        self.addChild(panel)
        
        let label = self.helpers.createLabel("Best Game", fontSize: 36, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+50), name: "HighScoreLabel", color: SKColor.blackColor())
        
        self.addChild(label)
        
        let highScore = self.helpers.getHighScore(self.difficulty)
        let highClearStreak = self.helpers.getHighClearStreak(self.difficulty)
        
        let label2 = self.helpers.createLabel("Score: " + String(highScore) + " | " + "Clear Streak: " + String(highClearStreak), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)), name: "HighScoreLabel", color: SKColor.blackColor())
        
        self.addChild(label2)
    }
    
    func addLastGameStats() {
        var panel = SKSpriteNode(imageNamed:"Panel2")
        panel.xScale = 1.1
        panel.yScale = 1.1
        panel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-100)
        panel.zPosition = 2
        self.addChild(panel)
        
        let label = self.helpers.createLabel("Last Game", fontSize: 36, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-85), name: "HighScoreLabel", color: SKColor.blackColor())
        
        self.addChild(label)
        
        let highScore = self.helpers.getLastScore(self.difficulty)
        let highClearStreak = self.helpers.getLastClearStreak(self.difficulty)
        
        let label2 = self.helpers.createLabel("Score: " + String(highScore) + " | " + "Clear Streak: " + String(highClearStreak), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-135), name: "HighScoreLabel", color: SKColor.blackColor())
        
        self.addChild(label2)
    }
    
    func addPlayButton(parentPanel: SKSpriteNode) {
        let button = SKSpriteNode(imageNamed:"Playbtn")
        button.position = CGPointMake(self.frame.width-175, CGRectGetMidY(self.frame))
        button.zPosition = 2
        button.name = "Play"
        self.addChild(button)
    }
    
    func addBackButton(parentPanel: SKSpriteNode) {
        let button = SKSpriteNode(imageNamed:"Backbtn")
        button.position = CGPointMake(175, CGRectGetMidY(self.frame))
        button.zPosition = 2
        button.name = "Back"
        button.xScale = 1.5
        button.yScale = 1.5
        self.addChild(button)
    }
    
    func addHighScorePanel(parentPanel: SKSpriteNode) {
        let panel = SKSpriteNode(imageNamed:"HighScore")
        panel.position = CGPointMake(CGRectGetMidX(parentPanel.frame), CGRectGetMidY(parentPanel.frame)+25)
        panel.zPosition = 2
        self.addChild(panel)
        
        let highScore = self.helpers.getHighScore(self.difficulty)
        let label = self.helpers.createLabel(String(highScore), fontSize: 36, position: CGPointMake(CGRectGetMidX(panel.frame), CGRectGetMidY(panel.frame)-25), name: "HighScoreLabel", color: SKColor.blackColor())
        
        self.addChild(label)
    }
    
    func addHighClearStreakPanel(parentPanel: SKSpriteNode) {
        let panel = SKSpriteNode(imageNamed:"HighClearStreak")
        panel.position = CGPointMake(CGRectGetMidX(parentPanel.frame), CGRectGetMidY(parentPanel.frame)-100)
        panel.zPosition = 2
        self.addChild(panel)
        
        let highClearStreak = self.helpers.getHighClearStreak(self.difficulty)
        let label = self.helpers.createLabel(String(highClearStreak), fontSize: 36, position: CGPointMake(CGRectGetMidX(panel.frame), CGRectGetMidY(panel.frame)-25), name: "HighClearStreakLabel", color: SKColor.blackColor())
        
        self.addChild(label)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var difficulty = ""
        var nodeName: String = ""
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if (node.name != nil) {
                nodeName = node.name!
            }
        }
        
        if (nodeName == "Play") {
            let gameScene = GameScene(size: self.size, gameViewController: self.controller!, difficulty: self.difficulty)
            gameScene.scaleMode = .AspectFill
            self.view?.presentScene(gameScene)
        } else if (nodeName == "Back") {
            let startScene = StartScene(size: self.size, gameViewController: self.controller!)
            startScene.scaleMode = .AspectFill
            self.view?.presentScene(startScene)
        }
    }
}