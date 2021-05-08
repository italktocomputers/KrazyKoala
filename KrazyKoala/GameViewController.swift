/*

Copyright (c) 2021 Andrew Schools

*/

import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController, ADBannerViewDelegate/*, FBLoginViewDelegate, FBWebDialogsDelegate*/ {
    var currentSceneName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        //skView.showsPhysics = true
        
        skView.ignoresSiblingOrder = true
        
        let size = CGSize(width: 1024, height: 700)
        let scene = StartScene(size: size, gameViewController: self)
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
    }
    
    /*
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
 */
}
