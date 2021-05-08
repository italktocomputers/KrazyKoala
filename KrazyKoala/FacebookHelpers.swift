/*

Copyright (c) 2021 Andrew Schools

*/

/*
import Foundation
import SpriteKit

class FacebookHelpers {
    func shareKrazyKoala(view: UIViewController) -> Void {
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = URL(string: "https://www.facebook.com/pages/Krazy-Koala/1553928058198425")
        content.setValue("Krazy Koala", forKey: "contentTitle")
        content.setValue("FREE iOS game", forKey: "contentDescription")
        content.setValue(URL(string: "https://s3.amazonaws.com/krazykoala/KrazyKoala180x180_2.png"), forKey: "imageURL")
        FBSDKShareDialog.show(from: view, with: content, delegate: nil)
    }

    func postNewHighScore(view: UIViewController, score: Int, difficulty: String) -> Void {
        let description = String(format: "%i in %@ mode!", arguments: [score, difficulty])
        post(view: view, og_type: "high_score", og_action: "new", title: "New High Score", description: description)
    }

    func postNewClearStreak(view: UIViewController, score: Int, difficulty: String) -> Void {
        let description = String(format: "%i in %@ mode!", arguments: [score, difficulty])
        post(view: view, og_type: "clear_streak", og_action: "new", title: "New Clear Streak", description: description)
    }

    func postCompletedGame(view: UIViewController, score: Int, clearStreak: Int, difficulty: String) -> Void {
        let description = String(format: "Score: %i, clear streak: %i in %@ mode!", arguments: [score, clearStreak, difficulty])
        post(view: view, og_type: "new_game", og_action: "completed", title: "Completed Game", description: description)
    }

    func post(view: UIViewController, og_type: String, og_action: String, title: String, description: String) -> Void {
        let imageURL = NSURL(string: "https://s3.amazonaws.com/krazykoala/KrazyKoala180x180_2.png")
        
        let properties: [NSObject : AnyObject]! = [
            "og:type" as NSObject: "aschools_test:"+og_type as AnyObject,
            "og:title" as NSObject: title as AnyObject,
            "og:description" as NSObject: description as AnyObject,
            "og:url" as NSObject: "https://www.facebook.com/pages/Krazy-Koala/1553928058198425" as AnyObject,
            "og:image" as NSObject: imageURL!
        ]
        
        let object = FBSDKShareOpenGraphObject(properties: properties)
        
        let action = FBSDKShareOpenGraphAction()
        action.actionType = "aschools_test:" + og_action
        action.setObject(object, forKey: og_type)
        
        let content = FBSDKShareOpenGraphContent()
        content.action = action
        content.previewPropertyName = og_type
        
        FBSDKShareDialog.show(from: view, with: content, delegate: nil)
    }
}
*/
