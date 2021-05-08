/*

Copyright (c) 2021 Andrew Schools

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
        banner.position = CGPoint(x: self.frame.midX, y: self.frame.height-175)
        banner.zPosition = 2
        banner.name = name
        banner.xScale = 1
        banner.yScale = 1
        self.addChild(banner)
        
        self.addGameStats()
        self.addPlayButton(parentPanel: panel)
        self.addBackButton(parentPanel: panel)
    }
    
    func addGameStats() {
        let bestGameLabel = self.helpers.createLabel(
            text: "Best Game",
            fontSize: 24,
            position: CGPoint(x: self.frame.midX-150, y: self.frame.midY),
            name: "HighScoreLabel",
            color: SKColor.black
        )
        
        self.addChild(bestGameLabel)
        
        let lastGameLabel = self.helpers.createLabel(
            text: "Last Game",
            fontSize: 24,
            position: CGPoint(x: self.frame.midX+150, y: self.frame.midY),
            name: "HighScoreLabel",
            color: SKColor.black
        )
        
        self.addChild(lastGameLabel)
        
        let highScore = self.helpers.getHighScore(difficulty: self.difficulty)
        let highClearStreak = self.helpers.getHighClearStreak(difficulty: self.difficulty)
        
        let bestScoreLabel = self.helpers.createLabel(
            text: "Score: " + String(highScore) + " | " + "Clear Streak: " + String(highClearStreak),
            fontSize: 16,
            position: CGPoint(x: self.frame.midX-150, y: self.frame.midY-30),
            name: "HighScoreLabel",
            color: SKColor.black
        )
        
        self.addChild(bestScoreLabel)
        
        let lastScoreLabel = self.helpers.createLabel(
            text: "Score: " + String(highScore) + " | " + "Clear Streak: " + String(highClearStreak),
            fontSize: 16,
            position: CGPoint(x: self.frame.midX+150, y: self.frame.midY-30),
            name: "HighScoreLabel",
            color: SKColor.black)
        
        self.addChild(lastScoreLabel)
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
