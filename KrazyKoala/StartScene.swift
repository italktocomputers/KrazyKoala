//
//  StartScene.swift
//  KrazyKoala
//
//  Created by Andrew Schools on 1/4/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

import SpriteKit
import iAd

class StartScene: SKScene {
    var controller: GameViewController
    var helpers = Helpers()
    var gameCenterController = GameCenterController()
    var startTime = NSDate()
    var toolTip = SKSpriteNode()
    var toolTipIndex = 0
    var toolTipMsg: [String] = [
        "Let's do this!",
        "I'm bored!",
        "@;&?@#",
        "Dang flies!",
        "Watcha doing?",
        "Ready to play?",
        "Eucalypt leaves!",
        "...",
        "You can do it!",
        "What was that?",
        "Don't mind me.",
        "Are you there?",
        "Howdy!",
        "Got Facebook?"
    ]
    var lastTimeToolTipShown = NSDate()
    
    init(size: CGSize, gameViewController: GameViewController) {
        self.controller = gameViewController
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        let highScore = self.helpers.getHighScore("Easy")
        let highClearStreak = self.helpers.getHighClearStreak("Easy")
        
        let highScore2 = self.helpers.getHighScore("Hard")
        let highClearStreak2 = self.helpers.getHighClearStreak("Hard")
        
        let highScore3 = self.helpers.getHighScore("Krazy")
        let highClearStreak3 = self.helpers.getHighClearStreak("Krazy")
        
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
        //banner.zRotation = 0.6
        
        self.addChild(banner)
        
        let facebookButton = SKSpriteNode(imageNamed:"Fb")
        //facebookButton.position = CGPointMake(CGRectGetMidX(self.frame)-100, 250)
        facebookButton.position = CGPointMake(100, self.frame.height-175)
        facebookButton.name = "Facebook"
        facebookButton.zPosition = 2
        self.addChild(facebookButton)
        
        let googleButton = SKSpriteNode(imageNamed:"G_")
        googleButton.position = CGPointMake(CGRectGetMidX(self.frame), 250)
        googleButton.name = "Google"
        googleButton.zPosition = 2
        //self.addChild(googleButton)
        
        let twitterButton = SKSpriteNode(imageNamed:"Twitter")
        twitterButton.position = CGPointMake(CGRectGetMidX(self.frame)+100, 250)
        twitterButton.name = "Twitter"
        twitterButton.zPosition = 2
        //self.addChild(twitterButton)
        
        let settingsButton = SKSpriteNode(imageNamed:"Settingsbtn")
        settingsButton.position = CGPointMake(self.frame.width-100, 175)
        settingsButton.name = "Settings"
        settingsButton.zPosition = 2
        self.addChild(settingsButton)
        
        let helpButton = SKSpriteNode(imageNamed:"Infobtn")
        helpButton.position = CGPointMake(self.frame.width-100, self.frame.height-175)
        helpButton.name = "Help/Info"
        helpButton.zPosition = 2
        self.addChild(helpButton)
        
        if (self.helpers.getGameCenterSetting() == true) {
            let leaderboardButton = SKSpriteNode(imageNamed:"Leaderboardbtn")
            leaderboardButton.position = CGPointMake(100, 175)
            leaderboardButton.name = "Leaderboards"
            leaderboardButton.zPosition = 2
            self.addChild(leaderboardButton)
        }
        
        self.addEasyButton()
        self.addHardButton()
        self.addKrazyButton()
        self.addKoala()
        self.addToolTip()
        
        self.addChild(self.helpers.createLabel("Copyright 2015, Andrew Schools.  All rights reserved.", fontSize: 14, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-150)))
        
        self.addChild(self.helpers.createLabel("v2.0.  Build date: " + compileDate() + ", " + compileTime(), fontSize: 10, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-165)))
    }
    
    func addKoala() {
        let koala = SKSpriteNode(imageNamed: "koala_walk01")
        koala.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+50)
        koala.zPosition = 2
        
        let walk1 = SKTexture(imageNamed: "koala_walk01")
        let walk2 = SKTexture(imageNamed: "koala_walk02")
        let walkAni = SKAction.animateWithTextures([walk1, walk2], timePerFrame: 0.2)
        
        koala.runAction(SKAction.repeatActionForever(walkAni), withKey:"walk")
        
        self.addChild(koala)
    }
    
    func addToolTip() {
        let node = SKSpriteNode(imageNamed: "Tooltip")
        node.position = CGPointMake(CGRectGetMidX(self.frame)+10, CGRectGetMidY(self.frame)+125)
        node.zPosition = 2
        
        self.toolTip = node
        
        self.addChild(node)
        
        self.addToolTipMsg("Choose a level!")
    }
    
    func addToolTipMsg(msg: String) {
        self.helpers.removeNodeByName(self, name: "Tooltip_Message")
        self.addChild(self.helpers.createLabel(msg, fontSize: 14, position: CGPointMake(CGRectGetMidX(self.toolTip.frame), CGRectGetMidY(self.toolTip.frame)), name: "Tooltip_Message", color: SKColor.blackColor()))
        
        self.lastTimeToolTipShown = NSDate()
        self.toolTipIndex++
    }
    
    func addEasyButton() {
        let button = SKSpriteNode(imageNamed:"EasyButton")
        button.position = CGPointMake(CGRectGetMidX(self.frame)-225, CGRectGetMidY(self.frame)-50)
        button.zPosition = 99
        button.name = name
        button.name = "Easy"
        
        self.addChild(button)
    }
    
    func addHardButton() {
        let button = SKSpriteNode(imageNamed:"HardButton")
        button.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-50)
        button.zPosition = 99
        button.name = name
        button.name = "Hard"
        
        self.addChild(button)
    }
    
    func addKrazyButton() {
        let button = SKSpriteNode(imageNamed:"KrazyButton")
        button.position = CGPointMake(CGRectGetMidX(self.frame)+225, CGRectGetMidY(self.frame)-50)
        button.zPosition = 99
        button.name = name
        button.name = "Krazy"
        
        self.addChild(button)
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
            
            //if fire button touched, bring the rain
            if nodeName == "Hard" {
                difficulty = "Hard"
            } else if nodeName == "Krazy" {
                difficulty = "Krazy"
            } else if nodeName == "Easy" {
                difficulty = "Easy"
            }
        }
        
        // if difficulty is empty, they clicked an ad
        if (difficulty != "") {
            let stagingScene = StagingScene(size: self.size, gameViewController: controller, difficulty: difficulty)
            stagingScene.scaleMode = .AspectFill
            self.view?.presentScene(stagingScene)
        } else {
            if (nodeName == "Help/Info") {
                let scene = HelpScene(size: self.size, gameViewController: self.controller)
                scene.scaleMode = .AspectFill
                self.view?.presentScene(scene)
            } else if (nodeName == "Settings") {
                let scene = SettingsScene(size: self.size, gameViewController: self.controller)
                scene.scaleMode = .AspectFill
                self.view?.presentScene(scene)
            } else if (nodeName == "Leaderboards") {
                let scene = LeaderboardMenuScene(size: self.size, gameViewController: self.controller)
                scene.scaleMode = .AspectFill
                self.view?.presentScene(scene)
            } else if (nodeName == "Facebook") {
                let facebookhelpers = FacebookHelpers()
                facebookhelpers.shareLink()
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        let now = NSDate()
        let interval = now.timeIntervalSinceDate(self.lastTimeToolTipShown)
        
        if (self.toolTipIndex > self.toolTipMsg.count-1) {
            self.toolTipIndex = 0
        }
        
        if (interval > 15) {
            self.addToolTipMsg(self.toolTipMsg[self.toolTipIndex])
        }
    }
}