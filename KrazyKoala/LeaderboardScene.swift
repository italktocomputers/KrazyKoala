/*

Copyright (c) 2021 Andrew Schools

*/

import SpriteKit
import iAd
import GameKit

class LeaderboardScene: SKScene {
    var controller: GameViewController?
    var helpers = Helpers()
    var gameCenterController = GameCenterController()
    var difficulty = ""
    var customSegmentedControl = UISegmentedControl()
    var segmentedBase = SKSpriteNode()
    var loc = 1
    var len = 5
    var lastSwipe = ""
    var type = "Score"
    
    init(size: CGSize, gameViewController: GameViewController, difficulty: String) {
        self.controller = gameViewController
        self.difficulty = difficulty
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {        
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
        addHighScoreLabel()
        addHighClearStreakLabel()
        
        self.gameCenterController.getLeaderBoard(type: self.type, difficulty: self.difficulty, range: NSMakeRange(self.loc, self.len), callback: self.showStatsTable)
        
        self.getUserScoreAndRank()
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if sender.direction == .left {
            // Fetch next 10 records
            self.loc = self.loc + self.len
            self.lastSwipe = "left"
            
            if self.loc < 1 {
                self.loc = 1
            }
            
            self.gameCenterController.getLeaderBoard(type: "Score", difficulty: self.difficulty, range: NSMakeRange(self.loc, self.len), callback: self.showStatsTable)
        }
        
        if sender.direction == .right {
            // Fetch previous 10 records
            self.loc = self.loc - self.len
            self.lastSwipe = "right"
            
            if self.loc < 1 {
                self.loc = 1
            }
            
            self.gameCenterController.getLeaderBoard(type: self.type, difficulty: self.difficulty, range: NSMakeRange(self.loc, self.len), callback: self.showStatsTable)
        }
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
    
    func addHighScoreLabel() {
        let labelScore = self.helpers.createLabel(
            text: String("High Score"),
            fontSize: 18,
            position: CGPoint(x: self.frame.midX-125, y: self.frame.midY+95),
            name: "highScore"
        )
        self.addChild(labelScore)
    }
    
    func addHighClearStreakLabel() {
        let labelScore = self.helpers.createLabel(
            text: String("High Clear Streak"),
            fontSize: 18,
            position: CGPoint(x: self.frame.midX+125, y: self.frame.midY+95),
            name: "highScore"
        )
        self.addChild(labelScore)
    }
    
    func updateScoreBoard(index: Int) {
        if index == 0 {
            self.type = "Score"
            self.helpers.removeNodeByName(scene: self, name: "SegmentedScoreBtn1")
            self.helpers.removeNodeByName(scene: self, name: "SegmentedScoreBtn2")
            self.helpers.removeNodeByName(scene: self, name: "SegmentedClearStreakBtn1")
            self.helpers.removeNodeByName(scene: self, name: "SegmentedClearStreakBtn2")
        }
        else if index == 1 {
            self.type = "ClearStreak"
            self.helpers.removeNodeByName(scene: self, name: "SegmentedClearStreakBtn1")
            self.helpers.removeNodeByName(scene: self, name: "SegmentedClearStreakBtn2")
            self.helpers.removeNodeByName(scene: self, name: "SegmentedScoreBtn1")
            self.helpers.removeNodeByName(scene: self, name: "SegmentedScoreBtn2")
        }
        
        self.loc = 1 // Switching leaderboards so we need to start back at 1
        
        // Get leaderboard from Apple
        self.gameCenterController.getLeaderBoard(type: self.type, difficulty: self.difficulty, range: NSMakeRange(self.loc, self.len), callback: self.showStatsTable)
        
        // Show user where they are in the leaderboard
        self.getUserScoreAndRank()
    }
    
    func getUserScoreAndRank() {
        self.gameCenterController.getUserScoreAndRank(type: self.type, difficulty: self.difficulty, callback: self.displayUserScoreAndRank)
    }
    
    func displayUserScoreAndRank(score: Int64, rank: Int) {
        self.helpers.removeNodeByName(scene: self, name: "userScore")
        let labelScore = self.helpers.createLabel(
            text: String(format: "Your score: %i", score),
            fontSize: 24,
            position: CGPoint(x: self.frame.midX-125, y: self.frame.height-375),
            name: "userScore"
        )
        self.addChild(labelScore)
        
        self.helpers.removeNodeByName(scene: self, name: "userRank")
        let labelRank = self.helpers.createLabel(
            text: String(format: "Your rank: %i", rank),
            fontSize: 24,
            position: CGPoint(x: self.frame.midX+125, y: self.frame.height-375),
            name: "userRank"
        )
        self.addChild(labelRank)
    }
    
    func showStatsTable(scores: [AnyObject]) {
        if scores.count == 0 {
            if self.lastSwipe == "left" {
                self.loc = self.loc - self.len
            } else {
                self.loc = self.loc + self.len
            }
        }
        else {
            if self.loc < 1 {
                self.loc = 1
            }
            
            //println(self.loc)
            
            // Clear current displayed stats
            self.helpers.removeNodeByName(scene: self, name: "stats")
            
            var rank = self.loc
            var i = 425
            
            for score in scores {
                let item = score as? GKScore
                
                if item != nil {
                    let labelRank = self.helpers.createLabel(
                        text: String(format: "#%i. ", rank),
                        fontSize: 24,
                        position: CGPoint(x: 250, y: self.frame.height-CGFloat(i)),
                        name: "stats"
                    )
                    labelRank.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
                    self.addChild(labelRank)
                    
                    let labelPlayer = self.helpers.createLabel(
                        text: item!.player.alias,
                        fontSize: 24,
                        position: CGPoint(x: 325, y: self.frame.height-CGFloat(i)),
                        name: "stats"
                    )
                    labelPlayer.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
                    self.addChild(labelPlayer)
                    
                    let labelScore = self.helpers.createLabel(
                        text: String(item!.value),
                        fontSize: 24,
                        position: CGPoint(x: 800, y: self.frame.height-CGFloat(i)),
                        name: "stats"
                    )
                    labelScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
                    self.addChild(labelScore)
                    
                    i = i + 25
                    rank+=1
                }
                
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            var nodeName = ""
            
            if node.name != nil {
                nodeName = node.name!
            }
            
            if nodeName == "Back" {
                self.customSegmentedControl.removeFromSuperview()
                
                // Go back to leaderboards
                let scene = LeaderboardMenuScene(size: self.size, gameViewController: self.controller!)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
            else if nodeName == "SegmentedScoreBtn1" || nodeName == "SegmentedScoreBtn2" {
                self.updateScoreBoard(index: 0)
            }
            else if nodeName == "SegmentedClearStreakBtn1" || nodeName == "SegmentedClearStreakBtn2" {
                self.updateScoreBoard(index: 1)
            }
        }
    }
}
