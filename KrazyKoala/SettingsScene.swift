/*

Copyright (c) 2021 Andrew Schools

*/

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
        
        self.addBackButton()
        
        // Vibration
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "Vibrate on: "),
                fontSize: 18,
                position: CGPoint(x: panel.frame.midX-150, y: panel.frame.midY+75)
            )
        )
        
        if self.helpers.getVibrationSetting() == true {
            self.vibrationSwitch = SKSpriteNode(imageNamed:"button_checked")
        }
        else {
            self.vibrationSwitch = SKSpriteNode(imageNamed:"button_unchecked")
        }
        
        self.vibrationSwitch.position = CGPoint(x: self.frame.midX-70, y: self.frame.midY+80)
        self.vibrationSwitch.name = "vibration"
        self.vibrationSwitch.zPosition = 2
        self.vibrationSwitch.xScale = 0.8
        self.vibrationSwitch.yScale = 0.8
        self.addChild(self.vibrationSwitch)
        
        // Play music
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "Music on: "),
                fontSize: 18,
                position: CGPoint(x: self.frame.midX-144, y: self.frame.midY)
            )
        )
        
        if self.helpers.getMusicSetting() == true {
            self.musicSwitch = SKSpriteNode(imageNamed:"button_checked")
        }
        else {
            self.musicSwitch = SKSpriteNode(imageNamed:"button_unchecked")
        }
        
        self.musicSwitch.position = CGPoint(x: self.frame.midX-70, y: self.frame.midY+10)
        self.musicSwitch.name = "music"
        self.musicSwitch.zPosition = 2
        self.musicSwitch.xScale = 0.8
        self.musicSwitch.yScale = 0.8
        self.addChild(self.musicSwitch)
        
        // Game center
        self.addChild(self.helpers.createLabel(
            text: String(format: "Game center on: "),
            fontSize: 18,
            position: CGPoint(x: self.frame.midX-175, y: self.frame.midY-75))
        )
        
        if self.helpers.getGameCenterSetting() == true {
            self.gameCenterSwitch = SKSpriteNode(imageNamed:"button_checked")
        }
        else {
            self.gameCenterSwitch = SKSpriteNode(imageNamed:"button_unchecked")
        }
        
        self.gameCenterSwitch.position = CGPoint(x: self.frame.midX-70, y: self.frame.midY-65)
        self.gameCenterSwitch.name = "gamecenter"
        self.gameCenterSwitch.zPosition = 2
        self.gameCenterSwitch.xScale = 0.8
        self.gameCenterSwitch.yScale = 0.8
        self.addChild(self.gameCenterSwitch)
        
        // Clear stats
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "Clear Stats"),
                fontSize: 18,
                position: CGPoint(x: self.frame.midX+250, y: self.frame.midY-175),
                color: SKColor.blue
            )
        )
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
    
    func reportScoresToGameCenter() {
        let topScoreEasy = self.helpers.getHighScore(difficulty: "Easy")
        let topScoreHard = self.helpers.getHighScore(difficulty: "Hard")
        let topScoreKrazy = self.helpers.getHighScore(difficulty: "Krazy")
        
        let topClearStreakEasy = self.helpers.getHighClearStreak(difficulty: "Easy")
        let topClearStreakHard = self.helpers.getHighClearStreak(difficulty: "Hard")
        let topClearStreakKrazy = self.helpers.getHighClearStreak(difficulty: "Krazy")
        
        // Report top scores for the first time
        self.gameCenterController.saveScore(type: "Score",  score: topScoreEasy, difficulty: "Easy")
        self.gameCenterController.saveScore(type: "ClearStreak",  score: topClearStreakEasy, difficulty: "Easy")
        
        self.gameCenterController.saveScore(type: "Score",  score: topScoreHard, difficulty: "Hard")
        self.gameCenterController.saveScore(type: "ClearStreak",  score: topClearStreakHard, difficulty: "Hard")
        
        self.gameCenterController.saveScore(type: "Score",  score: topScoreKrazy, difficulty: "Krazy")
        self.gameCenterController.saveScore(type: "ClearStreak",  score: topClearStreakKrazy, difficulty: "Krazy")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var nodeName = ""
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name != nil {
                nodeName = node.name!
            }
            
            if nodeName == "Back" {
                // Go back to start menu
                let startScene = StartScene(size: self.size, gameViewController: self.controller!)
                startScene.scaleMode = .aspectFill
                self.view?.presentScene(startScene)
            }
            else if nodeName == "music" {
                if self.helpers.getMusicSetting() == true {
                    self.helpers.saveMusicSetting(option: false)
                    self.musicSwitch.texture = SKTexture(imageNamed: "button_unchecked")
                }
                else {
                    self.helpers.saveMusicSetting(option: true)
                    self.musicSwitch.texture = SKTexture(imageNamed: "button_checked")
                }
            }
            else if nodeName == "vibration" {
                if self.helpers.getVibrationSetting() == true {
                    self.helpers.saveVibrationSetting(option: false)
                    self.vibrationSwitch.texture = SKTexture(imageNamed: "button_unchecked")
                }
                else {
                    self.helpers.saveVibrationSetting(option: true)
                    self.vibrationSwitch.texture = SKTexture(imageNamed: "button_checked")
                }
            }
            else if nodeName == "gamecenter" {
                if self.helpers.getGameCenterSetting() == true {
                    self.helpers.saveGameCenterSetting(option: false)
                    self.gameCenterSwitch.texture = SKTexture(imageNamed: "button_unchecked")
                }
                else {
                    self.helpers.saveGameCenterSetting(option: true)
                    self.gameCenterSwitch.texture = SKTexture(imageNamed: "button_checked")
                    
                    // Enable game center
                    if self.view != nil && self.view!.window != nil && self.view!.window!.rootViewController != nil {
                        // When they enable game center we want to report their top scores
                        self.gameCenterController.authenticateLocalPlayer(controller: self.view!.window!.rootViewController!, callback: self.reportScoresToGameCenter)
                        //println("Update gamecenter stats")
                    }
                }
            }
            else if nodeName == "Clear Stats" {
                let confirmScene = ConfirmClearStatsScene(size: self.size, gameViewController: self.controller!)
                confirmScene.scaleMode = .aspectFill
                self.view?.presentScene(confirmScene)
            }
        }
    }
}
