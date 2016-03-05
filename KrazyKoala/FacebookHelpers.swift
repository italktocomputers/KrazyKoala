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

class FacebookHelpers {
    func shareKrazyKoala(view: UIViewController) -> Void {
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "https://www.facebook.com/pages/Krazy-Koala/1553928058198425")
        content.contentTitle = "Krazy Koala"
        content.contentDescription = "FREE iOS game"
        content.imageURL = NSURL(string: "https://s3.amazonaws.com/krazykoala/KrazyKoala180x180_2.png")
        
        FBSDKShareDialog.showFromViewController(view, withContent: content, delegate: nil)
    }

    func postNewHighScore(view: UIViewController, score: Int, difficulty: String) -> Void {
        let description = String(format: "%i in %@ mode!", arguments: [score, difficulty])
        post(view, og_type: "high_score", og_action: "new", title: "New High Score", description: description)
    }

    func postNewClearStreak(view: UIViewController, score: Int, difficulty: String) -> Void {
        let description = String(format: "%i in %@ mode!", arguments: [score, difficulty])
        post(view, og_type: "clear_streak", og_action: "new", title: "New Clear Streak", description: description)
    }

    func postCompletedGame(view: UIViewController, score: Int, clearStreak: Int, difficulty: String) -> Void {
        let description = String(format: "Score: %i, clear streak: %i in %@ mode!", arguments: [score, clearStreak, difficulty])
        post(view, og_type: "new_game", og_action: "completed", title: "Completed Game", description: description)
    }

    func post(view: UIViewController, og_type: String, og_action: String, title: String, description: String) -> Void {
        let imageURL = NSURL(string: "https://s3.amazonaws.com/krazykoala/KrazyKoala180x180_2.png")
        
        let properties: [NSObject : AnyObject]! = [
            "og:type": "aschools_test:"+og_type,
            "og:title": title,
            "og:description": description,
            "og:url": "https://www.facebook.com/pages/Krazy-Koala/1553928058198425",
            "og:image": imageURL!
        ]
        
        let object = FBSDKShareOpenGraphObject(properties: properties)
        
        let action = FBSDKShareOpenGraphAction()
        action.actionType = "aschools_test:" + og_action
        action.setObject(object, forKey: og_type)
        
        let content = FBSDKShareOpenGraphContent()
        content.action = action
        content.previewPropertyName = og_type
        
        FBSDKShareDialog.showFromViewController(view, withContent: content, delegate: nil)
    }
}