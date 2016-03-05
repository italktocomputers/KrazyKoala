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

import SpriteKit
import iAd

class ConfirmClearStatsScene: SKScene {
    var controller: GameViewController?
    var gameCenterController = GameCenterController()
    var helpers = Helpers()
    
    init(size: CGSize, gameViewController: GameViewController) {
        self.controller = gameViewController
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        if self.controller!.iAdError == true {
            if self.controller!.isLoadingiAd == false {
                // There was an error loading iAd so let's try again
                self.controller!.loadAds()
            }
        } else {
            // We already have loaded iAd so let's just show it
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
        
        let panel = SKSpriteNode(imageNamed:"Panel")
        panel.xScale = 1.1
        panel.yScale = 1.1
        panel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        panel.zPosition = 1
        self.addChild(panel)
        
        let banner = SKSpriteNode(imageNamed:"KrazyKoalaRibbon")
        banner.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height-200)
        banner.zPosition = 2
        banner.xScale = 1.5
        banner.yScale = 1.5
        self.addChild(banner)
        
        self.addBackButton()
        
        self.addChild(self.helpers.createLabel("Are you sure?", fontSize: 36, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+50), color: SKColor.blackColor()))
        
        self.addChild(self.helpers.createLabel("You want to clear your local stats?", fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)), color: SKColor.blackColor()))
        
        
        let accept = SKSpriteNode(imageNamed:"Accept")
        accept.position = CGPointMake(CGRectGetMidX(self.frame)-100, CGRectGetMidY(self.frame)-100)
        accept.zPosition = 2
        accept.name = "Okay"
        self.addChild(accept)
        
        let warning = SKSpriteNode(imageNamed:"Warning")
        warning.position = CGPointMake(CGRectGetMidX(self.frame)+100, CGRectGetMidY(self.frame)-100)
        warning.zPosition = 2
        warning.name = "Cancel"
        self.addChild(warning)
    }
    
    func addBackButton() {
        let node = SKSpriteNode(imageNamed:"Backbtn")
        node.xScale = 1.5
        node.yScale = 1.5
        node.position = CGPointMake(175, CGRectGetMidY(self.frame))
        node.zPosition = 2
        node.name = "Back"
        self.addChild(node)
    }
    
    func showCompleteMessage() {
        self.helpers.removeNodeByName(self, name: "Okay")
        self.helpers.removeNodeByName(self, name: "Cancel")
        self.helpers.removeNodeByName(self, name: "Are you sure?")
        self.helpers.removeNodeByName(self, name: "You want to clear your local stats?")
        
        self.addChild(self.helpers.createLabel("Your stats have been cleared!", fontSize: 36, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+50), color: SKColor.blackColor()))
        self.addChild(self.helpers.createLabel("You better get to work...", fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)), color: SKColor.blackColor()))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var nodeName = ""
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if node.name != nil {
                nodeName = node.name!
            }
            
            if nodeName == "Back" || nodeName == "Cancel" {
                // Go back to start menu
                let settingsScene = SettingsScene(size: self.size, gameViewController: self.controller!)
                settingsScene.scaleMode = .AspectFill
                self.view?.presentScene(settingsScene)
            } else if nodeName == "Okay" {
                self.helpers.clearStats()
                self.showCompleteMessage()
            }
        }
    }
}