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
        banner.position = CGPoint(x: self.frame.midX, y: self.frame.height-200)
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
        let node = SKSpriteNode(imageNamed:"Backbtn")
        node.xScale = 1.5
        node.yScale = 1.5
        node.position = CGPoint(x: 175, y: self.frame.midY)
        node.zPosition = 2
        node.name = "Back"
        self.addChild(node)
    }
    
    func addEasyButton() {
        let button = SKSpriteNode(imageNamed:"EasyButton")
        button.position = CGPoint(x: self.frame.midX, y: self.frame.midY+75)
        button.zPosition = 2
        button.name = name
        button.name = "Easy"
        self.addChild(button)
        
        let node2 = SKSpriteNode(imageNamed:"LeaderboardGreenbtn")
        node2.xScale = 1.5
        node2.yScale = 1.5
        node2.position = CGPoint(x: button.frame.midX+75, y: button.frame.midY+25)
        node2.zPosition = 3
        node2.name = "Easy"
        node2.xScale = 1.1
        node2.yScale = 1.1
        self.addChild(node2)
    }
    
    func addHardButton() {
        let button = SKSpriteNode(imageNamed:"HardButton")
        button.position = CGPoint(x: self.frame.midX, y: self.frame.midY-25)
        button.zPosition = 2
        button.name = name
        button.name = "Hard"
        self.addChild(button)
        
        let node2 = SKSpriteNode(imageNamed:"Leaderboardbtn")
        node2.xScale = 1.5
        node2.yScale = 1.5
        node2.position = CGPoint(x: button.frame.midX+75, y: button.frame.midY+25)
        node2.zPosition = 3
        node2.name = "Hard"
        node2.xScale = 1.1
        node2.yScale = 1.1
        self.addChild(node2)
    }
    
    func addKrazyButton() {
        let button = SKSpriteNode(imageNamed:"KrazyButton")
        button.position = CGPoint(x: self.frame.midX, y: self.frame.midY-125)
        button.zPosition = 2
        button.name = name
        button.name = "Krazy"
        self.addChild(button)
        
        let node2 = SKSpriteNode(imageNamed:"LeaderboardRedbtn")
        node2.xScale = 1.5
        node2.yScale = 1.5
        node2.position = CGPoint(x: button.frame.midX+75, y: button.frame.midY+25)
        node2.zPosition = 3
        node2.name = "Krazy"
        node2.xScale = 1.1
        node2.yScale = 1.1
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
