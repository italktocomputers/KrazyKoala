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
    func authenticateLocalPlayer(controller: UIViewController, callback:(Void)->Void) {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        if localPlayer.authenticated == false {
            localPlayer.authenticateHandler = {(viewController : UIViewController?, error : NSError?) -> Void in
                // Handle authentication
                if viewController != nil {
                    controller.presentViewController(viewController!, animated: true, completion: nil)
                } else {
                    if localPlayer.authenticated == true {
                        self.gameCenterEnabled = true
                        callback()
                    }
                }
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        
    }

    func getUserScoreAndRank(type: String, difficulty: String, callback: (Int64, Int)->Void) {
        let leaderboardRequest = GKLeaderboard() as GKLeaderboard!
        leaderboardRequest.identifier = type + "_" + difficulty
        
        if leaderboardRequest != nil {
            leaderboardRequest.loadScoresWithCompletionHandler({ (scores:[GKScore]?, error:NSError?) -> Void in
                if error != nil {
                    //handle error
                    print("Error: " + error!.localizedDescription)
                } else {
                    var score: Int64 = 0
                    var rank: Int = -1
                    
                    if leaderboardRequest.localPlayerScore != nil {
                        score = leaderboardRequest.localPlayerScore!.value
                        rank = leaderboardRequest.localPlayerScore!.rank
                    }
                    
                    callback(score, rank)
                }
            })
        }
    }
    
    func getLeaderBoard(type: String, difficulty: String, range: NSRange=NSMakeRange(1,10), callback: ([AnyObject])->Void) {
        let leaderboardRequest = GKLeaderboard() as GKLeaderboard!
        leaderboardRequest.identifier = type + "_" + difficulty
        leaderboardRequest.range = range
        leaderboardRequest.timeScope = GKLeaderboardTimeScope.AllTime
        leaderboardRequest.playerScope = GKLeaderboardPlayerScope.Global
        
        if leaderboardRequest != nil {
            leaderboardRequest.loadScoresWithCompletionHandler({ (scores:[GKScore]?, error:NSError?) -> Void in
                if error != nil {
                    print("Error: " + error!.localizedDescription)
                } else {
                    if leaderboardRequest.scores != nil {
                        callback(leaderboardRequest.scores!)
                    } else {
                        let emptyArray = [AnyObject]()
                        callback(emptyArray)
                    }
                }
            })
        }
    }
    
    func saveScore(type: String, score: Int, difficulty: String) {
        // If player is logged in to GC, then report the score
        if GKLocalPlayer.localPlayer().authenticated {
            let gkScore = GKScore(leaderboardIdentifier: type + "_" + difficulty)
            gkScore.value = Int64(score)
            GKScore.reportScores([gkScore], withCompletionHandler: ( { (error: NSError?) -> Void in
                if error != nil {
                    print("Error: " + error!.localizedDescription)
                } else {
                    print("Score reported: %i", gkScore.value)
                }
            }))
        }
    }
    
    func getAchievements(callback: ([AnyObject])->Void) {
        if GKLocalPlayer.localPlayer().authenticated {
            GKAchievementDescription.loadAchievementDescriptionsWithCompletionHandler({(achievements, error) -> Void in
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
        GKAchievement.reportAchievements([achievement], withCompletionHandler: {(error)->Void in
            if error != nil {
                print(error)
            } else {
                print("Achievement reported to Game Center: " + identifier)
            }
        })
    }
}