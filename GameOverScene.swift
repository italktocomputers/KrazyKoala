/*

Copyright (c) 2021 Andrew Schools

*/

import SpriteKit
import iAd

class GameOverScene: SKScene {
    var difficulty = ""
    var loadTime = NSDate()
    var playedWav = false
    
    var lastScore = 0
    var lastclearStreak = 0
    var lastLevel = 0
    
    var currentScore = 0
    var highScore = 0
    
    var currentclearStreak = 0
    var highclearStreak = 0
    
    var currentLevel = 0
    var highLevel = 0
    
    var antsKilled = 0
    var fliesKilled = 0
    
    var controller: GameViewController
    
    var newHighScore = false
    var newClearStreak = false
    var newHighLevel = false
    var newHighScoreShown = false
    var newClearStreakShown = false
    var newHighLevelShown = false
    
    var helpers = Helpers()
    var gameCenterController = GameCenterController()
    
    var banner = SKSpriteNode()
    var panel = SKSpriteNode()
    
    init(size: CGSize, gameViewController: GameViewController, score: Int, antsKilled: Int, fliesKilled: Int, clearStreak: Int, difficulty: String, level: Int) {
        self.controller = gameViewController
        self.currentScore = score
        self.antsKilled = antsKilled
        self.fliesKilled = fliesKilled
        self.currentclearStreak = clearStreak
        self.difficulty = difficulty
        self.currentLevel = level
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showGameOverWindow() {
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "Number of insects cleared:"),
                fontSize: 24,
                position: CGPoint(x: self.frame.midX, y: self.frame.height-300),
                name: "screenItem",
                color: SKColor.black
            )
        )
        
        let antsClearedLabel = self.helpers.createLabel(
            text: String(format: "%i", self.antsKilled),
            fontSize: 24,
            position: CGPoint(x: self.frame.midX-125, y: self.frame.height-340),
            name: "screenItem",
            color: SKColor.black
        )
        
        self.addChild(antsClearedLabel)
        
        let fliesClearedLabel = self.helpers.createLabel(
            text: String(format: "%i", self.fliesKilled),
            fontSize: 24,
            position: CGPoint(x: self.frame.midX, y: self.frame.height-340),
            name: "screenItem",
            color: SKColor.black
        )
        
        self.addChild(fliesClearedLabel)
        
        let plusLabel = self.helpers.createLabel(
            text: " + ",
            fontSize: 24,
            position: CGPoint(x: self.frame.midX-60, y: antsClearedLabel.frame.midY-60),
            name: "screenItem",
            color: SKColor.black
        )
        
        self.addChild(plusLabel)
        
        let equalLabel = self.helpers.createLabel(
            text: " = ",
            fontSize: 24,
            position: CGPoint(x: self.frame.midX+45, y: antsClearedLabel.frame.midY-60),
            name: "screenItem",
            color: SKColor.black
        )
        
        self.addChild(equalLabel)
        
        let clearedLabel = self.helpers.createLabel(
            text: String(format: "%i", self.fliesKilled+self.antsKilled),
            fontSize: 36,
            position: CGPoint(x: self.frame.midX+125, y: antsClearedLabel.frame.midY-67),
            name: "screenItem",
            color: SKColor.black
        )
        
        self.addChild(clearedLabel)
        
        let antnodeBlack = SKSpriteNode(imageNamed:"ant_stand_black")
        antnodeBlack.position = CGPoint(x: antsClearedLabel.frame.midX, y: antsClearedLabel.frame.midY-60)
        antnodeBlack.name = "screenItem"
        antnodeBlack.zPosition = 2
        self.addChild(antnodeBlack)
        
        let flynode = SKSpriteNode(imageNamed:"fly_1")
        flynode.position = CGPoint(x: fliesClearedLabel.frame.midX, y: fliesClearedLabel.frame.midY-60)
        flynode.name = "screenItem"
        flynode.zPosition = 2
        self.addChild(flynode)
        
        let clearnode = SKSpriteNode(imageNamed:"poof1_white")
        clearnode.position = CGPoint(x: clearedLabel.frame.midX, y: fliesClearedLabel.frame.midY-60)
        clearnode.name = "screenItem"
        clearnode.zPosition = 2
        self.addChild(clearnode)
        
        let totalClearedLabel = self.helpers.createLabel(
            text: String(format: "Clear streak: %i", self.currentclearStreak),
            fontSize: 24,
            position: CGPoint(x: self.frame.midX, y: self.frame.height-475),
            name: "screenItem",
            color: SKColor.black
        )
        
        self.addChild(totalClearedLabel)
        
        self.addFacebookButton(name: "game")
    }
    
    func showNewHighScore() {
        self.newHighScoreShown = true
        
        self.helpers.removeNodeByName(scene: self, name: "screenItem")
        
        let wav = SKAction.playSoundFileNamed("success.wav", waitForCompletion: false)
        self.run(wav)
        self.playedWav = true
        
        self.banner.texture = SKTexture(imageNamed: "Congratulations")
        
        let star = SKSpriteNode(imageNamed:"Star")
        star.position = CGPoint(x: self.frame.midX, y: self.frame.midY+20)
        star.zPosition = 2
        star.name = "screenItem"
        star.xScale = 3.5
        star.yScale = 3.5
        star.alpha = 0.3
        
        self.addChild(star)
        
        let label = self.helpers.createLabel(
            text: "Best score yet!",
            fontSize: 36,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY+30),
            name: "screenItem",
            color: SKColor.black
        )
        
        self.addChild(label)
        
        let oldScoreLabel = self.helpers.createLabel(
            text: "Old: " + String(self.highScore) + "     New: " + String(self.currentScore),
            fontSize: 24,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY-10),
            name: "screenItem",
            color: SKColor.black
        )
        
        self.addChild(oldScoreLabel)
        
        self.addFacebookButton(name: "score")
    }
    
    func showNewClearStreak() {
        self.newClearStreakShown = true
        
        self.helpers.removeNodeByName(scene: self, name: "screenItem")
        
        let wav = SKAction.playSoundFileNamed("success.wav", waitForCompletion: false)
        self.run(wav)
        self.playedWav = true
        
        self.banner.texture = SKTexture(imageNamed: "Congratulations")
        
        let star = SKSpriteNode(imageNamed:"Star")
        star.position = CGPoint(x: self.frame.midX, y: self.frame.midY+20)
        star.zPosition = 2
        star.name = "screenItem"
        star.xScale = 3.5
        star.yScale = 3.5
        star.alpha = 0.3
        
        self.addChild(star)
        
        let label = self.helpers.createLabel(
            text: "Best clear streak yet!",
            fontSize: 36,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY+30),
            name: "screenItem",
            color: SKColor.black
        )
        
        self.addChild(label)
        
        let oldScoreLabel = self.helpers.createLabel(
            text: "Old: " + String(self.highclearStreak) + "     New: " + String(self.currentclearStreak),
            fontSize: 24,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY-10),
            name: "screenItem",
            color: SKColor.black
        )
        
        self.addChild(oldScoreLabel)
        
        self.addFacebookButton(name: "clearStreak")
    }
    
    func showNewHighLevel() {
        self.newHighLevelShown = true
        
        self.helpers.removeNodeByName(scene: self, name: "screenItem")
        
        let wav = SKAction.playSoundFileNamed("success.wav", waitForCompletion: false)
        self.run(wav)
        self.playedWav = true
        
        self.banner.texture = SKTexture(imageNamed: "Congratulations")
        
        let star = SKSpriteNode(imageNamed:"Star")
        star.position = CGPoint(x: self.frame.midX, y: self.frame.midY+20)
        star.zPosition = 2
        star.name = "screenItem"
        star.xScale = 3.5
        star.yScale = 3.5
        star.alpha = 0.3
        
        self.addChild(star)
        
        let label = self.helpers.createLabel(
            text: "Highest level yet!",
            fontSize: 36,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY+30),
            name: "screenItem",
            color: SKColor.black
        )
        
        self.addChild(label)
        
        let oldScoreLabel = self.helpers.createLabel(
            text: "Old: " + String(self.highLevel) + "     New: " + String(self.currentLevel),
            fontSize: 24,
            position: CGPoint(x: self.frame.midX, y: self.frame.midY-10),
            name: "screenItem",
            color: SKColor.black
        )
        
        self.addChild(oldScoreLabel)
        
        self.addFacebookButton(name: "level")
    }
    
    func addFacebookButton(name: String) {
        let facebook = SKSpriteNode(imageNamed:"Facebook2")
        facebook.position = CGPoint(x: self.panel.frame.midX, y: self.panel.frame.midY-145)
        facebook.zPosition = 2
        facebook.name = "Facebook_" + name
        self.addChild(facebook)
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
        
        let lastScore = self.helpers.getLastScore(difficulty: self.difficulty)
        let lastClearStreak = self.helpers.getLastClearStreak(difficulty: self.difficulty)
        let lastLevel = self.helpers.getLastLevel(difficulty: self.difficulty)
        
        let highScore = self.helpers.getHighScore(difficulty: self.difficulty)
        let highClearStreak = self.helpers.getHighClearStreak(difficulty: self.difficulty)
        let highLevel = self.helpers.getHighLevel(difficulty: self.difficulty)
        
        self.lastScore = lastScore
        self.lastclearStreak = lastClearStreak
        self.lastLevel = lastLevel
        
        self.highScore = highScore
        self.highclearStreak = highClearStreak
        self.highLevel = highLevel
        
        // Save current stats so we can show them how their last
        // game was when we come back to this scene
        self.helpers.saveLastScore(score: self.currentScore, difficulty: self.difficulty)
        self.helpers.saveLastClearStreak(score: self.currentclearStreak, difficulty: self.difficulty)
        self.helpers.saveLastLevel(level: self.currentLevel, difficulty: self.difficulty)
        
        if self.currentScore > highScore {
            // Save new high score
            self.helpers.saveHighScore(score: self.currentScore, difficulty: self.difficulty)
            self.newHighScore = true
        }
        
        if self.helpers.getGameCenterSetting() == true {
            // Save score to game center
            self.gameCenterController.saveScore(type: "Score",  score: self.currentScore, difficulty: self.difficulty)
        }
        
        if self.currentclearStreak > highclearStreak {
            // Save a new high kill streak
            self.helpers.saveHighClearStreak(score: self.currentclearStreak, difficulty: self.difficulty)
            self.newClearStreak = true
        }
        
        if self.helpers.getGameCenterSetting() == true {
            // Save score to game center
            self.gameCenterController.saveScore(type: "ClearStreak",  score: self.currentclearStreak, difficulty: self.difficulty)
        }
        
        if self.currentLevel > highLevel {
            // Save new high difficulty adjustment
            self.helpers.saveHighLevel(level: self.currentLevel, difficulty: self.difficulty)
            self.newHighLevel = true
        }
        
        if self.helpers.getGameCenterSetting() == true {
            // Save difficulty adjustment to game center
            self.gameCenterController.saveScore(type: "Level",  score: self.currentLevel, difficulty: self.difficulty)
        }
        
        self.loadBackground()
        self.showGameOverWindow()
    }
    
    func loadBackground() {
        var background = SKSpriteNode()
        if UIDevice.current.userInterfaceIdiom == .pad {
            background = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1280x800")
        }
        else {
            background = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1920x640")
        }
        
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        
        if self.view?.bounds.width == 480 {
            background.yScale = 1.1
            background.xScale = 1.1
        }
        
        self.addChild(background)
        
        self.banner = SKSpriteNode(imageNamed:"GameOverRibbon")
        self.banner.position = CGPoint(x: self.frame.midX, y: self.frame.height-200)
        self.banner.zPosition = 4
        self.banner.name = name
        self.banner.xScale = 1.5
        self.banner.yScale = 1.5
        self.addChild(self.banner)
        
        self.panel = SKSpriteNode(imageNamed:"Panel")
        self.panel.xScale = 1
        self.panel.yScale = 1
        self.panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.panel.zPosition = 1
        self.addChild(self.panel)
        
        let node = SKSpriteNode(imageNamed:"Forwardbtn")
        node.xScale = 1.5
        node.yScale = 1.5
        node.position = CGPoint(x: self.frame.width-200, y: self.frame.midY)
        node.zPosition = 2
        node.name = "Forward"
        self.addChild(node)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var proceed = false
        var name = ""
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name != nil {
                name = node.name!
                
                if node.name == "Forward" {
                    proceed = true
                }
            }
        }
        
        // If proceed is false, they clicked an ad
        if proceed == true {
            if self.newHighScore == true && self.newHighScoreShown == false {
                // New high score
                self.showNewHighScore()
            }
            else if self.newClearStreak == true && self.newClearStreakShown == false {
                // New clear streak
                self.showNewClearStreak()
            }
            else {
                // Send them back to the start menu
                let startScene = StartScene(size: self.size, gameViewController: self.controller)
                startScene.scaleMode = .aspectFill
                self.view?.presentScene(startScene)
            }
        }
        else if name == "Facebook_score" {
            //FacebookHelpers().postNewHighScore(self.controller, score: self.currentScore, difficulty: self.difficulty)
        }
        else if name == "Facebook_clearStreak" {
            //FacebookHelpers().postNewClearStreak(self.controller, score: self.currentclearStreak, difficulty: self.difficulty)
        }
        else if name == "Facebook_game" {
            //FacebookHelpers().postCompletedGame(self.controller, score: self.currentScore, clearStreak: self.currentclearStreak, difficulty: self.difficulty)
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {

    }

}
