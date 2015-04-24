//
//  GameCenterController.swift
//  KrazyKoala
//
//  Created by Andrew Schools on 1/30/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

class GameCenterController: NSObject, GKGameCenterControllerDelegate {
    var gameCenterEnabled = false
    
    func showGameCenter() {
        let gameCenterController: GKGameCenterViewController = GKGameCenterViewController()
        gameCenterController.gameCenterDelegate = self
    }
    
    // authenticate player for game center
    func authenticateLocalPlayer(controller: UIViewController, callback:(Void)->Void) {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        if (localPlayer.authenticated == false) {
            localPlayer.authenticateHandler = {(viewController : UIViewController!, error : NSError!) -> Void in
                // handle authentication
                if (viewController != nil) {
                    controller.presentViewController(viewController, animated: true, completion: nil)
                } else {
                    if (localPlayer.authenticated == true) {
                        self.gameCenterEnabled = true
                        callback()
                    }
                }
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        
    }

    func getUserScoreAndRank(type: String, difficulty: String, callback: (Int64, Int)->Void) {
        let leaderboardRequest = GKLeaderboard() as GKLeaderboard!
        leaderboardRequest.identifier = type + "_" + difficulty
        
        if leaderboardRequest != nil {
            leaderboardRequest.loadScoresWithCompletionHandler({ (scores:[AnyObject]!, error:NSError!) -> Void in
                if error != nil {
                    //handle error
                    println("Error: " + error.localizedDescription)
                } else {
                    var score: Int64 = 0
                    var rank: Int = -1
                    
                    if (leaderboardRequest.localPlayerScore != nil) {
                        score = leaderboardRequest.localPlayerScore.value
                        rank = leaderboardRequest.localPlayerScore.rank
                    }
                    
                    callback(score, rank)
                }
            })
        }
    }
    
    func getLeaderBoard(type: String, difficulty: String, callback: ([AnyObject])->Void, range: NSRange=NSMakeRange(1,10)) {
        let leaderboardRequest = GKLeaderboard() as GKLeaderboard!
        leaderboardRequest.identifier = type + "_" + difficulty
        leaderboardRequest.range = range
        leaderboardRequest.timeScope = GKLeaderboardTimeScope.AllTime
        leaderboardRequest.playerScope = GKLeaderboardPlayerScope.Global
        
        if leaderboardRequest != nil {
            leaderboardRequest.loadScoresWithCompletionHandler({ (scores:[AnyObject]!, error:NSError!) -> Void in
                if error != nil {
                    //handle error
                    println("Error: " + error.localizedDescription)
                } else {
                    if (leaderboardRequest.scores != nil) {
                        callback(leaderboardRequest.scores)
                    } else {
                        let emptyArray = [AnyObject]()
                        callback(emptyArray)
                    }
                }
            })
        }
    }
    
    func saveScore(type: String, score: Int, difficulty: String) {
        // if player is logged in to GC, then report the score
        if GKLocalPlayer.localPlayer().authenticated {
            let gkScore = GKScore(leaderboardIdentifier: type + "_" + difficulty)
            gkScore.value = Int64(score)
            GKScore.reportScores([gkScore], withCompletionHandler: ( { (error: NSError!) -> Void in
                if (error != nil) {
                    // handle error
                    println("Error: " + error.localizedDescription);
                } else {
                    //println("Score reported: \(gkScore.value)")
                }
            }))
        }
    }
}