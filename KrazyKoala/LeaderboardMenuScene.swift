/*

Copyright (c) 2021 Andrew Schools

*/

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
    
    override func didMove(to view: SKView) {
        /*
        if self.controller!.iAdError == true {
            if self.controller!.isLoadingiAd == false {
                // There was an error loading iAd so let's try again
                self.controller!.loadAds()
            }
        }
        else {
            // We already have loaded iAd so let's just show it
            self.controller!.adBannerView?.isHidden = false
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
        
        let banner = SKSpriteNode(imageNamed:"LeaderboardsRibbon")
        banner.position = CGPoint(x: self.frame.midX, y: self.frame.height-175)
        banner.zPosition = 2
        banner.name = name
        banner.xScale = 1
        banner.yScale = 1
        self.addChild(banner)
        
        self.addBackButton()
        
        self.addEasyButton()
        self.addHardButton()
        self.addKrazyButton()
    }
    
    func addBackButton() {
        let node = SKSpriteNode(imageNamed:"Backbtn")
        node.xScale = 1.5
        node.yScale = 1.5
        node.position = CGPoint(x: 175, y: self.frame.midY)
        node.zPosition = 2
        node.name = "Back"
        self.addChild(node)
    }
    
    func addEasyButton() {
        let label = self.helpers.createLabel(
            text: "easy",
            fontSize: 18,
            position: CGPoint(x: self.frame.midX-150, y: self.frame.midY+60),
            color: SKColor.black
        )
        
        self.addChild(label)
        
        let node2 = SKSpriteNode(imageNamed:"LeaderboardGreenbtn")
        node2.xScale = 1.5
        node2.yScale = 1.5
        node2.position = CGPoint(x: self.frame.midX-150, y: self.frame.midY)
        node2.zPosition = 3
        node2.name = "Easy"
        self.addChild(node2)
    }
    
    func addHardButton() {
        let label = self.helpers.createLabel(
            text: "hard",
            fontSize: 18,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY+40),
            color: SKColor.black
        )
        
        self.addChild(label)
        
        let node2 = SKSpriteNode(imageNamed:"Leaderboardbtn")
        node2.xScale = 1.5
        node2.yScale = 1.5
        node2.position = CGPoint(x: self.frame.midX, y: self.frame.midY-20)
        node2.zPosition = 3
        node2.name = "Hard"
        self.addChild(node2)
    }
    
    func addKrazyButton() {
        let label = self.helpers.createLabel(
            text: "krazy",
            fontSize: 18,
            position: CGPoint(x: self.frame.midX+150, y: self.frame.midY+60),
            color: SKColor.black
        )
        
        self.addChild(label)
        
        let node2 = SKSpriteNode(imageNamed:"LeaderboardRedbtn")
        node2.xScale = 1.5
        node2.yScale = 1.5
        node2.position = CGPoint(x: self.frame.midX+150, y: self.frame.midY)
        node2.zPosition = 3
        node2.name = "Krazy"
        self.addChild(node2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            var nodeName = ""
            
            if node.name != nil {
                nodeName = node.name!
            }
            
            var difficulty = ""
            
            if nodeName == "Hard" {
                difficulty = "Hard"
            }
            else if nodeName == "Krazy" {
                difficulty = "Krazy"
            }
            else if nodeName == "Easy" {
                difficulty = "Easy"
            }
            
            // If difficulty is empty, they did not click a button
            if difficulty != "" {
                let leaderboardScene = LeaderboardScene(size: self.size, gameViewController: self.controller!, difficulty: difficulty)
                leaderboardScene.scaleMode = .aspectFill
                self.view?.presentScene(leaderboardScene)
            }
            else if nodeName == "Back" {
                // Go back to start menu
                let startScene = StartScene(size: self.size, gameViewController: self.controller!)
                startScene.scaleMode = .aspectFill
                self.view?.presentScene(startScene)
            }
        }
    }
}
