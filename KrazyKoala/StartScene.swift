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
        if self.controller.iAdError == true {
            if self.controller.isLoadingiAd == false {
                // There was an error loading iAd so let's try again
                self.controller.loadAds()
            }
        } else {
            // We already have loaded iAd so let's just show it
            self.controller.adBannerView?.hidden = false
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
        
        let panel = SKSpriteNode(imageNamed:"Panel")
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
        
        self.addEasyButton()
        self.addHardButton()
        self.addKrazyButton()
        self.addKoala()
        self.addToolTip()
        self.addVerticalMenu()
        
        self.addChild(self.helpers.createLabel("Copyright 2016, Andrew Schools.  All rights reserved.", fontSize: 14, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-150)))
        
        self.addChild(self.helpers.createLabel("v2.2.  Build date: " + compileDate() + ", " + compileTime(), fontSize: 10, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-165)))
    }
    
    func addVerticalMenu() {
        let bar = SKSpriteNode(imageNamed:"VerticalMenu")
        bar.position = CGPointMake(self.frame.width-100, self.frame.height/2)
        bar.name = "vBar"
        bar.zPosition = 2
        self.addChild(bar)
        
        let info = SKSpriteNode(imageNamed:"Info_icon")
        info.position = CGPointMake(CGRectGetMidX(bar.frame), CGRectGetMidY(bar.frame)+130)
        info.name = "info"
        info.zPosition = 3
        self.addChild(info)
        
        let leader = SKSpriteNode(imageNamed:"Leaderboard_icon")
        leader.position = CGPointMake(CGRectGetMidX(bar.frame), CGRectGetMidY(bar.frame)+45)
        leader.name = "leaderboards"
        leader.zPosition = 3
        self.addChild(leader)
        
        let fb = SKSpriteNode(imageNamed:"Facebook_icon")
        fb.position = CGPointMake(CGRectGetMidX(bar.frame), CGRectGetMidY(bar.frame)-35)
        fb.name = "facebook"
        fb.zPosition = 3
        self.addChild(fb)
        
        let gear = SKSpriteNode(imageNamed:"Gear_icon")
        gear.position = CGPointMake(CGRectGetMidX(bar.frame), CGRectGetMidY(bar.frame)-120)
        gear.name = "settings"
        gear.zPosition = 3
        self.addChild(gear)
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var difficulty = ""
        var nodeName: String = ""
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if node.name != nil {
                nodeName = node.name!
            }
            
            if nodeName == "Hard" {
                difficulty = "Hard"
            } else if nodeName == "Krazy" {
                difficulty = "Krazy"
            } else if nodeName == "Easy" {
                difficulty = "Easy"
            }
        }
        
        // If difficulty is empty, they clicked an ad
        if difficulty != "" {
            let stagingScene = StagingScene(size: self.size, gameViewController: controller, difficulty: difficulty)
            stagingScene.scaleMode = .AspectFill
            self.view?.presentScene(stagingScene)
        } else {
            if nodeName == "info" {
                let scene = HelpScene(size: self.size, gameViewController: self.controller)
                scene.scaleMode = .AspectFill
                self.view?.presentScene(scene)
            } else if nodeName == "settings" {
                let scene = SettingsScene(size: self.size, gameViewController: self.controller)
                scene.scaleMode = .AspectFill
                self.view?.presentScene(scene)
            } else if nodeName == "leaderboards" {
                let scene = LeaderboardMenuScene(size: self.size, gameViewController: self.controller)
                scene.scaleMode = .AspectFill
                self.view?.presentScene(scene)
            } else if nodeName == "facebook" {
                FacebookHelpers().shareKrazyKoala(self.controller)
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        let now = NSDate()
        let interval = now.timeIntervalSinceDate(self.lastTimeToolTipShown)
        
        if self.toolTipIndex > self.toolTipMsg.count-1 {
            self.toolTipIndex = 0
        }
        
        if interval > 15 {
            self.addToolTipMsg(self.toolTipMsg[self.toolTipIndex])
        }
    }
}