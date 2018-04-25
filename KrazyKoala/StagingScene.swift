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
        
        let banner = SKSpriteNode(imageNamed:"KrazyKoalaRibbon")
        banner.position = CGPoint(x: self.frame.midX, y: self.frame.height-200)
        banner.zPosition = 2
        banner.name = name
        banner.xScale = 1.5
        banner.yScale = 1.5
        self.addChild(banner)
        
        //self.addHighScorePanel(panel)
        //self.addHighClearStreakPanel(panel)
        
        self.addBestGameStats()
        self.addLastGameStats()
        self.addPlayButton(parentPanel: panel)
        self.addBackButton(parentPanel: panel)
    }
    
    func addBestGameStats() {
        let panel = SKSpriteNode(imageNamed:"Panel2")
        panel.xScale = 1.1
        panel.yScale = 1.1
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY+35)
        panel.zPosition = 2
        self.addChild(panel)
        
        let label = self.helpers.createLabel(
            text: "Best Game",
            fontSize: 36,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY+50),
            name: "HighScoreLabel",
            color: SKColor.black
        )
        
        self.addChild(label)
        
        let highScore = self.helpers.getHighScore(difficulty: self.difficulty)
        let highClearStreak = self.helpers.getHighClearStreak(difficulty: self.difficulty)
        
        let label2 = self.helpers.createLabel(
            text: "Score: " + String(highScore) + " | " + "Clear Streak: " + String(highClearStreak),
            fontSize: 24,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY),
            name: "HighScoreLabel",
            color: SKColor.black
        )
        
        self.addChild(label2)
    }
    
    func addLastGameStats() {
        let panel = SKSpriteNode(imageNamed:"Panel2")
        panel.xScale = 1.1
        panel.yScale = 1.1
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY-100)
        panel.zPosition = 2
        self.addChild(panel)
        
        let label = self.helpers.createLabel(
            text: "Last Game",
            fontSize: 36,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY-85),
            name: "HighScoreLabel",
            color: SKColor.black
        )
        
        self.addChild(label)
        
        let highScore = self.helpers.getLastScore(difficulty: self.difficulty)
        let highClearStreak = self.helpers.getLastClearStreak(difficulty: self.difficulty)
        
        let label2 = self.helpers.createLabel(
            text: "Score: " + String(highScore) + " | " + "Clear Streak: " + String(highClearStreak),
            fontSize: 24,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY-135),
            name: "HighScoreLabel",
            color: SKColor.black)
        
        self.addChild(label2)
    }
    
    func addPlayButton(parentPanel: SKSpriteNode) {
        let button = SKSpriteNode(imageNamed:"Playbtn")
        button.position = CGPoint(x: self.frame.width-175, y: self.frame.midY)
        button.zPosition = 2
        button.name = "Play"
        self.addChild(button)
    }
    
    func addBackButton(parentPanel: SKSpriteNode) {
        let button = SKSpriteNode(imageNamed:"Backbtn")
        button.position = CGPoint(x: 175, y: self.frame.midY)
        button.zPosition = 2
        button.name = "Back"
        button.xScale = 1.5
        button.yScale = 1.5
        self.addChild(button)
    }
    
    func addHighScorePanel(parentPanel: SKSpriteNode) {
        let panel = SKSpriteNode(imageNamed:"HighScore")
        panel.position = CGPoint(x: parentPanel.frame.midX, y: parentPanel.frame.midY+25)
        panel.zPosition = 2
        self.addChild(panel)
        
        let highScore = self.helpers.getHighScore(difficulty: self.difficulty)
        let label = self.helpers.createLabel(
            text: String(highScore),
            fontSize: 36,
            position: CGPoint(x: panel.frame.midX, y: panel.frame.midY-25),
            name: "HighScoreLabel",
            color: SKColor.black
        )
        
        self.addChild(label)
    }
    
    func addHighClearStreakPanel(parentPanel: SKSpriteNode) {
        let panel = SKSpriteNode(imageNamed:"HighClearStreak")
        panel.position = CGPoint(x: parentPanel.frame.midX, y: parentPanel.frame.midY-100)
        panel.zPosition = 2
        self.addChild(panel)
        
        let highClearStreak = self.helpers.getHighClearStreak(difficulty: self.difficulty)
        let label = self.helpers.createLabel(
            text: String(highClearStreak),
            fontSize: 36,
            position: CGPoint(x: panel.frame.midX, y: panel.frame.midX-25),
            name: "HighClearStreakLabel",
            color: SKColor.black
        )
        
        self.addChild(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var nodeName: String = ""
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name != nil {
                nodeName = node.name!
            }
        }
        
        if nodeName == "Play" {
            let gameScene = GameScene(size: self.size, gameViewController: self.controller!, difficulty: self.difficulty)
            gameScene.scaleMode = .aspectFill
            self.view?.presentScene(gameScene)
        }
        else if nodeName == "Back" {
            let startScene = StartScene(size: self.size, gameViewController: self.controller!)
            startScene.scaleMode = .aspectFill
            self.view?.presentScene(startScene)
        }
    }
}
