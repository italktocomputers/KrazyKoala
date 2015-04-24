//
//  LeaderboardMenuScene.swift
//  KrazyKoala
//
//  Created by Andrew Schools on 1/4/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

import SpriteKit
import iAd
import GameKit

class LeaderboardMenuScene: SKScene {
    var controller: GameViewController?
    var helpers = Helpers()
    var gameCenterController = GameCenterController()
    
    var easyButton = SKSpriteNode()
    var hardButton = SKSpriteNode()
    var krazyButton = SKSpriteNode()
    
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
        
        let banner = SKSpriteNode(imageNamed:"LeaderboardsRibbon")
        banner.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height-200)
        banner.zPosition = 2
        banner.name = name
        banner.xScale = 1.5
        banner.yScale = 1.5
        self.addChild(banner)
        
        self.addBackButton()
        
        self.addEasyButton()
        self.addHardButton()
        self.addKrazyButton()
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
    
    func addEasyButton() {
        let button = SKSpriteNode(imageNamed:"EasyButton")
        button.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+75)
        button.zPosition = 2
        button.name = name
        button.name = "Easy"
        self.addChild(button)
        
        var node2 = SKSpriteNode(imageNamed:"LeaderboardGreenbtn")
        node2.xScale = 1.5
        node2.yScale = 1.5
        node2.position = CGPointMake(CGRectGetMidX(button.frame)+75, CGRectGetMidY(button.frame)+25)
        node2.zPosition = 3
        node2.name = "Easy"
        node2.xScale = 1.1
        node2.yScale = 1.1
        self.addChild(node2)
    }
    
    func addHardButton() {
        let button = SKSpriteNode(imageNamed:"HardButton")
        button.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-25)
        button.zPosition = 2
        button.name = name
        button.name = "Hard"
        self.addChild(button)
        
        var node2 = SKSpriteNode(imageNamed:"Leaderboardbtn")
        node2.xScale = 1.5
        node2.yScale = 1.5
        node2.position = CGPointMake(CGRectGetMidX(button.frame)+75, CGRectGetMidY(button.frame)+25)
        node2.zPosition = 3
        node2.name = "Hard"
        node2.xScale = 1.1
        node2.yScale = 1.1
        self.addChild(node2)
    }
    
    func addKrazyButton() {
        let button = SKSpriteNode(imageNamed:"KrazyButton")
        button.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-125)
        button.zPosition = 2
        button.name = name
        button.name = "Krazy"
        self.addChild(button)
        
        var node2 = SKSpriteNode(imageNamed:"LeaderboardRedbtn")
        node2.xScale = 1.5
        node2.yScale = 1.5
        node2.position = CGPointMake(CGRectGetMidX(button.frame)+75, CGRectGetMidY(button.frame)+25)
        node2.zPosition = 3
        node2.name = "Krazy"
        node2.xScale = 1.1
        node2.yScale = 1.1
        self.addChild(node2)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var difficulty = ""
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            var nodeName = ""
            
            if (node.name != nil) {
                nodeName = node.name!
            }
            
            var difficulty = ""
            
            //if fire button touched, bring the rain
            if nodeName == "Hard" {
                difficulty = "Hard"
            } else if nodeName == "Krazy" {
                difficulty = "Krazy"
            } else if nodeName == "Easy" {
                difficulty = "Easy"
            }
            
            // if difficulty is empty, they did not click a button
            if (difficulty != "") {
                let leaderboardScene = LeaderboardScene(size: self.size, gameViewController: self.controller!, difficulty: difficulty)
                leaderboardScene.scaleMode = .AspectFill
                self.view?.presentScene(leaderboardScene)
            } else if (nodeName == "Back") {
                // go back to start menu
                let startScene = StartScene(size: self.size, gameViewController: self.controller!)
                startScene.scaleMode = .AspectFill
                self.view?.presentScene(startScene)
            }
        }
    }
}