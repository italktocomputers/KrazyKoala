//
//  LeaderboardsScene.swift
//  KrazyKoala
//
//  Created by Andrew Schools on 1/4/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

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
    
    override func didMoveToView(view: SKView) {
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        if (self.controller!.iAdError == true) {
            if (self.controller!.isLoadingiAd == false) {
                // there was an error loading iAd so let's try again
                self.controller!.loadAds()
            }
        } else {
            // we already have loaded iAd so let's just show it
            self.controller!.adBannerView?.hidden = false
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
        
        var panel = SKSpriteNode(imageNamed:"Panel")
        panel.xScale = 1.1
        panel.yScale = 1.1
        panel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        panel.zPosition = 1
        self.addChild(panel)
        
        let banner = SKSpriteNode(imageNamed:"LeaderboardsRibbon")
        banner.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height-200)
        banner.zPosition = 2
        banner.name = name
        banner.xScale = 1.5
        banner.yScale = 1.5
        self.addChild(banner)
        
        self.addBackButton()
        
        self.segmentedBase = self.addSegmentedBase()
        self.addSegmentedScoreButtonOn(self.segmentedBase)
        self.addSegmentedClearStreakButtonOff(self.segmentedBase)
        
        self.gameCenterController.getLeaderBoard(self.type, difficulty: self.difficulty, callback: self.showStatsTable, range: NSMakeRange(self.loc, self.len))
        
        self.getUserScoreAndRank()
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            // fetch next 10 records
            self.loc = self.loc + self.len
            self.lastSwipe = "left"
            
            if (self.loc < 1) {
                self.loc = 1
            }
            
            self.gameCenterController.getLeaderBoard("Score", difficulty: self.difficulty, callback: self.showStatsTable, range: NSMakeRange(self.loc, self.len))
        }
        
        if (sender.direction == .Right) {
            // fetch previous 10 records
            self.loc = self.loc - self.len
            self.lastSwipe = "right"
            
            if (self.loc < 1) {
                self.loc = 1
            }
            
            self.gameCenterController.getLeaderBoard(self.type, difficulty: self.difficulty, callback: self.showStatsTable, range: NSMakeRange(self.loc, self.len))
        }
    }
    
    func addBackButton() {
        var node = SKSpriteNode(imageNamed:"Backbtn")
        node.xScale = 1.5
        node.yScale = 1.5
        node.position = CGPointMake(175, CGRectGetMidY(self.frame))
        node.zPosition = 2
        node.name = "Back"
        self.addChild(node)
    }
    
    func addSegmentedBase() -> SKSpriteNode {
        var node = SKSpriteNode(imageNamed:"SegmentedBase")
        node.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+70)
        node.zPosition = 2
        node.name = "SegmentedBase"
        self.addChild(node)
        
        return node
    }
    
    func addSegmentedScoreButtonOn(parentNode: SKSpriteNode) {
        var node = SKSpriteNode(imageNamed:"SegmentedScore1")
        node.position = CGPointMake(CGRectGetMidX(parentNode.frame)-105, CGRectGetMidY(parentNode.frame))
        node.zPosition = 3
        node.name = "SegmentedScoreBtn1"
        self.addChild(node)
    }
    
    func addSegmentedScoreButtonOff(parentNode: SKSpriteNode) {
        var node = SKSpriteNode(imageNamed:"SegmentedScore2")
        node.position = CGPointMake(CGRectGetMidX(parentNode.frame)-105, CGRectGetMidY(parentNode.frame))
        node.zPosition = 3
        node.name = "SegmentedScoreBtn2"
        self.addChild(node)
    }
    
    func addSegmentedClearStreakButtonOn(parentNode: SKSpriteNode) {
        var node = SKSpriteNode(imageNamed:"SegmentedClearStreak1")
        node.position = CGPointMake(CGRectGetMidX(parentNode.frame)+105, CGRectGetMidY(parentNode.frame))
        node.zPosition = 3
        node.name = "SegmentedClearStreakBtn1"
        self.addChild(node)
    }
    
    func addSegmentedClearStreakButtonOff(parentNode: SKSpriteNode) {
        var node = SKSpriteNode(imageNamed:"SegmentedClearStreak2")
        node.position = CGPointMake(CGRectGetMidX(parentNode.frame)+105, CGRectGetMidY(parentNode.frame))
        node.zPosition = 3
        node.name = "SegmentedClearStreakBtn2"
        self.addChild(node)
    }
    
    func updateScoreBoard(index: Int) {
        if (index == 0) {
            self.type = "Score"
            self.helpers.removeNodeByName(self, name: "SegmentedScoreBtn1")
            self.helpers.removeNodeByName(self, name: "SegmentedScoreBtn2")
            self.helpers.removeNodeByName(self, name: "SegmentedClearStreakBtn1")
            self.helpers.removeNodeByName(self, name: "SegmentedClearStreakBtn2")
            self.addSegmentedScoreButtonOn(self.segmentedBase)
            self.addSegmentedClearStreakButtonOff(self.segmentedBase)
        } else if (index == 1) {
            self.type = "ClearStreak"
            self.helpers.removeNodeByName(self, name: "SegmentedClearStreakBtn1")
            self.helpers.removeNodeByName(self, name: "SegmentedClearStreakBtn2")
            self.helpers.removeNodeByName(self, name: "SegmentedScoreBtn1")
            self.helpers.removeNodeByName(self, name: "SegmentedScoreBtn2")
            self.addSegmentedClearStreakButtonOn(self.segmentedBase)
            self.addSegmentedScoreButtonOff(self.segmentedBase)
        }
        
        self.loc = 1 // switching leaderboards so we need to start back at 1
        
        // get leaderboard from Apple
        self.gameCenterController.getLeaderBoard(self.type, difficulty: self.difficulty, callback: self.showStatsTable, range: NSMakeRange(self.loc, self.len))
        
        // show user where they are in the leaderboard
        self.getUserScoreAndRank()
    }
    
    func getUserScoreAndRank() {
        self.gameCenterController.getUserScoreAndRank(self.type, difficulty: self.difficulty, callback: self.displayUserScoreAndRank)
    }
    
    func displayUserScoreAndRank(score: Int64, rank: Int) {
        self.helpers.removeNodeByName(self, name: "userScore")
        let labelScore = self.helpers.createLabel(String(format: "Your score: %i", score), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame)-125, self.frame.height-375), name: "userScore")
        self.addChild(labelScore)
        
        self.helpers.removeNodeByName(self, name: "userRank")
        let labelRank = self.helpers.createLabel(String(format: "Your rank: %i", rank), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame)+125, self.frame.height-375), name: "userRank")
        self.addChild(labelRank)
    }
    
    func showStatsTable(scores: [AnyObject]) {
        if (scores.count == 0) {
            if (self.lastSwipe == "left") {
                self.loc = self.loc - self.len
            } else {
                self.loc = self.loc + self.len
            }
        } else {
            if (self.loc < 1) {
                self.loc = 1
            }
            
            //println(self.loc)
            
            // clear current displayed stats
            self.helpers.removeNodeByName(self, name: "stats")
            
            var rank = self.loc
            var i = 425
            for score in scores {
                let item = score as? GKScore
                if (item != nil) {
                    let labelRank = self.helpers.createLabel(String(format: "#%i. ", rank), fontSize: 24, position: CGPointMake(250, self.frame.height-CGFloat(i)), name: "stats")
                    labelRank.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
                    self.addChild(labelRank)
                    
                    let labelPlayer = self.helpers.createLabel(item!.player.alias, fontSize: 24, position: CGPointMake(325, self.frame.height-CGFloat(i)), name: "stats")
                    labelPlayer.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
                    self.addChild(labelPlayer)
                    
                    let labelScore = self.helpers.createLabel(String(item!.value), fontSize: 24, position: CGPointMake(800, self.frame.height-CGFloat(i)), name: "stats")
                    labelScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
                    self.addChild(labelScore)
                    
                    i = i + 25
                    rank++
                }
                
            }
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var difficulty = ""
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            var nodeName = ""
            
            if (node.name != nil) {
                nodeName = node.name!
            }
            
            if (nodeName == "Back") {
                self.customSegmentedControl.removeFromSuperview()
                
                // go back to leaderboards
                let scene = LeaderboardMenuScene(size: self.size, gameViewController: self.controller!)
                scene.scaleMode = .AspectFill
                self.view?.presentScene(scene)
            } else if(nodeName == "SegmentedScoreBtn1" || nodeName == "SegmentedScoreBtn2") {
                self.updateScoreBoard(0)
            } else if(nodeName == "SegmentedClearStreakBtn1" || nodeName == "SegmentedClearStreakBtn2") {
                self.updateScoreBoard(1)
            }
        }
    }
}