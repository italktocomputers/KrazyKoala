/*

Copyright (c) 2021 Andrew Schools

*/

import Foundation
import SpriteKit
import GameKit

class GameCenterController: NSObject, GKGameCenterControllerDelegate {
    var gameCenterEnabled = false
    
    func showGameCenter() {
        let gameCenterController: GKGameCenterViewController = GKGameCenterViewController()
        gameCenterController.gameCenterDelegate = self
    }
    
    // Authenticate player for game center
    func authenticateLocalPlayer(controller: UIViewController, callback:@escaping ()->Void) {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        if localPlayer.isAuthenticated == false {
            localPlayer.authenticateHandler = {(viewController : UIViewController?, error : Error?) -> Void in
                // Handle authentication
                if viewController != nil {
                    controller.present(viewController!, animated: true, completion: nil)
                }
                else {
                    if localPlayer.isAuthenticated == true {
                        self.gameCenterEnabled = true
                        callback()
                    }
                }
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        
    }

    func getUserScoreAndRank(type: String, difficulty: String, callback: @escaping (Int64, Int)->Void) {
        let leaderboardRequest = GKLeaderboard() as GKLeaderboard?
        leaderboardRequest?.identifier = type + "_" + difficulty
        
        if leaderboardRequest != nil {
            leaderboardRequest?.loadScores(completionHandler: { (scores:[GKScore]?, error:Error?) -> Void in
                if error != nil {
                    //handle error
                    print("Error: " + error!.localizedDescription)
                }
                else {
                    var score: Int64 = 0
                    var rank: Int = -1
                    
                    if leaderboardRequest?.localPlayerScore != nil {
                        score = (leaderboardRequest?.localPlayerScore!.value)!
                        rank = (leaderboardRequest?.localPlayerScore!.rank)!
                    }
                    
                    callback(score, rank)
                }
            })
        }
    }
    
    func getLeaderBoard(type: String, difficulty: String, range: NSRange=NSMakeRange(1,10), callback: @escaping ([AnyObject])->Void) {
        let leaderboardRequest = GKLeaderboard() as GKLeaderboard?
        leaderboardRequest?.identifier = type + "_" + difficulty
        leaderboardRequest?.range = range
        leaderboardRequest?.timeScope = GKLeaderboardTimeScope.allTime
        leaderboardRequest?.playerScope = GKLeaderboardPlayerScope.global
        
        if leaderboardRequest != nil {
            leaderboardRequest?.loadScores(completionHandler: { (scores:[GKScore]?, error:Error?) -> Void in
                if error != nil {
                    print("Error: " + error!.localizedDescription)
                }
                else {
                    if leaderboardRequest?.scores != nil {
                        callback((leaderboardRequest?.scores!)!)
                    }
                    else {
                        let emptyArray = [AnyObject]()
                        callback(emptyArray)
                    }
                }
            })
        }
    }
    
    func saveScore(type: String, score: Int, difficulty: String) {
        // If player is logged in to GC, then report the score
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let gkScore = GKScore(leaderboardIdentifier: type + "_" + difficulty)
            gkScore.value = Int64(score)
            GKScore.report(
                [gkScore],
                withCompletionHandler: ( { (error: Error?) -> Void in
                    if error != nil {
                        print("Error: " + error!.localizedDescription)
                    }
                    else {
                        print("Score reported: %i", gkScore.value)
                    }
                })
            )
        }
    }
    
    func getAchievements(callback: @escaping ([AnyObject])->Void) {
        if GKLocalPlayer.localPlayer().isAuthenticated {
            GKAchievementDescription.loadAchievementDescriptions(completionHandler: {(achievements, error) -> Void in
                if error != nil {
                    print(error)
                }
                
                if achievements != nil {
                    callback(achievements!)
                }
            })
        }
    }
    
    func reportAchievement(identifier: String, percent: Double) {
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = percent
        GKAchievement.report([achievement], withCompletionHandler: {(error)->Void in
            if error != nil {
                print(error)
            }
            else {
                print("Achievement reported to Game Center: " + identifier)
            }
        })
    }
}
