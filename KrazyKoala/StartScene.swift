/*

Copyright (c) 2021 Andrew Schools

*/

import SpriteKit
import iAd

class StartScene: SKScene {
    var controller: GameViewController
    var helpers = Helpers()
    var gameCenterController = GameCenterController()
    var startTime = Date()
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
    var lastTimeToolTipShown = Date()
    
    init(size: CGSize, gameViewController: GameViewController) {
        self.controller = gameViewController
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        /*
        if self.controller.iAdError == true {
            if self.controller.isLoadingiAd == false {
                // There was an error loading iAd so let's try again
                self.controller.loadAds()
            }
        }
        else {
            // We already have loaded iAd so let's just show it
            self.controller.adBannerView?.isHidden = false
        }
        */
        
        var background = SKSpriteNode()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            background = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1280x800")
        }
        else {
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
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        panel.zPosition = 1
        self.addChild(panel)
        
        let banner = SKSpriteNode(imageNamed:"KrazyKoalaRibbon")
        banner.position = CGPoint(x: self.frame.midX, y: self.frame.height-175)
        banner.zPosition = 2
        banner.name = name
        banner.xScale = 1
        banner.yScale = 1
        self.addChild(banner)
        
        self.addEasyButton()
        self.addHardButton()
        self.addKrazyButton()
        self.addKoala()
        self.addToolTip()
        self.addVerticalMenu()
        
        self.addChild(
            self.helpers.createLabel(
                text: "Copyright 2021, Andrew Schools.  All rights reserved.",
                fontSize: 14,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY-150)
            )
        )
        
        self.addChild(
            self.helpers.createLabel(
                text: "v2.3.",
                fontSize: 10,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY-165)
            )
        )
    }
    
    func addVerticalMenu() {
        let bar = SKSpriteNode(imageNamed:"VerticalMenu")
        bar.position = CGPoint(x: self.frame.width-100, y: self.frame.height/2)
        bar.name = "vBar"
        bar.zPosition = 2
        self.addChild(bar)
        
        let info = SKSpriteNode(imageNamed:"Info_icon")
        info.position = CGPoint(x: bar.frame.midX, y: bar.frame.midY+130)
        info.name = "info"
        info.zPosition = 3
        self.addChild(info)
        
        let leader = SKSpriteNode(imageNamed:"Leaderboard_icon")
        leader.position = CGPoint(x: bar.frame.midX, y: bar.frame.midY+45)
        leader.name = "leaderboards"
        leader.zPosition = 3
        self.addChild(leader)
        
        let fb = SKSpriteNode(imageNamed:"Facebook_icon")
        fb.position = CGPoint(x: bar.frame.midX, y: bar.frame.midY-35)
        fb.name = "facebook"
        fb.zPosition = 3
        self.addChild(fb)
        
        let gear = SKSpriteNode(imageNamed:"Gear_icon")
        gear.position = CGPoint(x: bar.frame.midX, y: bar.frame.midY-120)
        gear.name = "settings"
        gear.zPosition = 3
        self.addChild(gear)
    }
    
    func addKoala() {
        let koala = SKSpriteNode(imageNamed: "koala_walk01")
        koala.position = CGPoint(x: self.frame.midX, y: self.frame.midY+20)
        koala.zPosition = 2
        
        let walk1 = SKTexture(imageNamed: "koala_walk01")
        let walk2 = SKTexture(imageNamed: "koala_walk02")
        let walkAni = SKAction.animate(with: [walk1, walk2], timePerFrame: 0.2)
        
        koala.run(SKAction.repeatForever(walkAni), withKey:"walk")
        
        self.addChild(koala)
    }
    
    func addToolTip() {
        let node = SKSpriteNode(imageNamed: "Tooltip")
        node.position = CGPoint(x: self.frame.midX+10, y: self.frame.midY+95)
        node.zPosition = 2
        
        self.toolTip = node
        
        self.addChild(node)
        
        self.addToolTipMsg(msg: "Choose a level!")
    }
    
    func addToolTipMsg(msg: String) {
        self.helpers.removeNodeByName(scene: self, name: "Tooltip_Message")
        self.addChild(
            self.helpers.createLabel(
                text: msg,
                fontSize: 14,
                position: CGPoint(x: self.toolTip.frame.midX, y: self.toolTip.frame.midY),
                name: "Tooltip_Message",
                color: SKColor.black
            )
        )
        
        self.lastTimeToolTipShown = Date()
        self.toolTipIndex+=1
    }
    
    func addEasyButton() {
        let button = SKSpriteNode(imageNamed:"EasyButton")
        button.position = CGPoint(x: self.frame.midX-225, y: self.frame.midY-80)
        button.zPosition = 99
        button.name = name
        button.name = "Easy"
        
        self.addChild(button)
    }
    
    func addHardButton() {
        let button = SKSpriteNode(imageNamed:"HardButton")
        button.position = CGPoint(x: self.frame.midX, y: self.frame.midY-80)
        button.zPosition = 99
        button.name = name
        button.name = "Hard"
        
        self.addChild(button)
    }
    
    func addKrazyButton() {
        let button = SKSpriteNode(imageNamed:"KrazyButton")
        button.position = CGPoint(x: self.frame.midX+225, y: self.frame.midY-80)
        button.zPosition = 99
        button.name = name
        button.name = "Krazy"
        
        self.addChild(button)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var difficulty = ""
        var nodeName: String = ""
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name != nil {
                nodeName = node.name!
            }
            
            if nodeName == "Hard" {
                difficulty = "Hard"
            }
            else if nodeName == "Krazy" {
                difficulty = "Krazy"
            }
            else if nodeName == "Easy" {
                difficulty = "Easy"
            }
        }
        
        // If difficulty is empty, they clicked an ad
        if difficulty != "" {
            let stagingScene = StagingScene(size: self.size, gameViewController: controller, difficulty: difficulty)
            stagingScene.scaleMode = .aspectFill
            self.view?.presentScene(stagingScene)
        }
        else {
            if nodeName == "info" {
                let scene = HelpScene(size: self.size, gameViewController: self.controller)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
            else if nodeName == "settings" {
                let scene = SettingsScene(size: self.size, gameViewController: self.controller)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
            else if nodeName == "leaderboards" {
                let scene = LeaderboardMenuScene(size: self.size, gameViewController: self.controller)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
            else if nodeName == "facebook" {
                //FacebookHelpers().shareKrazyKoala(self.controller)
            }
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        let now = Date()
        let interval = now.timeIntervalSince(self.lastTimeToolTipShown)
        
        if self.toolTipIndex > self.toolTipMsg.count-1 {
            self.toolTipIndex = 0
        }
        
        if interval > 15 {
            self.addToolTipMsg(msg: self.toolTipMsg[self.toolTipIndex])
        }
    }
}
