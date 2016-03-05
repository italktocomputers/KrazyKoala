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

class HelpScene: SKScene {
    var helpFilePos = 0
    var controller: GameViewController
    var helpers = Helpers()
    var panel = SKSpriteNode()
    var currentPage = 1
    var totalPages = 5
    
    init(size: CGSize, gameViewController: GameViewController) {
        self.controller = gameViewController
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        if self.controller.iAdError == true {
            if self.controller.isLoadingiAd == false {
                // there was an error loading iAd so let's try again
                self.controller.loadAds()
            }
        } else {
            // we already have loaded iAd so let's just show it
            self.controller.adBannerView?.hidden = false
        }
        
        var background = SKSpriteNode()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            background = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1280x800")
        } else {
            background = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1920x640")
        }
        
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        
        if self.view?.bounds.width == 480 {
            background.yScale = 1.1
            background.xScale = 1.1
        }
        
        self.addChild(background)
        
        let panel = SKSpriteNode(imageNamed:"Panel")
        panel.xScale = 1.5
        panel.yScale = 1.5
        panel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        panel.zPosition = 1
        
        self.panel = panel
        self.addChild(self.panel)
        
        self.showFirstHelpFile()
        self.addForwardButton()
        self.addBackButton()
        self.showPageNum()
    }
    
    func showPageNum() {
        self.enumerateChildNodesWithName("pageNums", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        self.addChild(self.helpers.createLabel(String(format:"Page %i of %i", self.currentPage, self.totalPages), fontSize: 10, position: CGPointMake(CGRectGetMidY(self.panel.frame)+500, CGRectGetMidY(self.panel.frame)-200), name:"pageNums"))
    }
    
    func addForwardButton() {
        let node = SKSpriteNode(imageNamed:"Forwardbtn")
        node.xScale = 1.5
        node.yScale = 1.5
        node.position = CGPointMake(self.frame.width-50, CGRectGetMidY(self.frame))
        node.zPosition = 2
        node.name = "Forward"
        self.addChild(node)
    }
    
    func addBackButton() {
        let node = SKSpriteNode(imageNamed:"Backbtn")
        node.xScale = 1.5
        node.yScale = 1.5
        node.position = CGPointMake(50, CGRectGetMidY(self.frame))
        node.zPosition = 2
        node.name = "Back"
        self.addChild(node)
    }
    
    func showFirstHelpFile() {
        let text: [String] = [
            "The premise is simple. Destroy as many flies and ants as you can by",
            "throwing rocks at them while making your way through the jungle. Along",
            "the way you can collect items (blue rocks, red rocks and bombs) that can",
            "help you stay alive.  How to play: Click to jump. While in the air",
            "click again to throw a rock at a fly or ant to remove it from the",
            "scene and gain a point. You are only allowed to throw a rock every",
            "half second.  If hit by a fly you will loose a life. Walking into an",
            "ant will do the same.  As well as throwing rocks, you can jump on ants",
            "to clear them from the scene and gain a point.  As you progress more",
            "flies will enter the scene but don't fret as you will also receive",
            "additional lives.  Good luck and don't forget to have fun!!!"
        ]
        
        var i = 0
        for line in text {
            self.addChild(self.helpers.createLabel(String(format: line), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGFloat((Int(self.frame.height-200))-(i*30))), name: "help_text", color: SKColor.blackColor()))
            i++
        }
    }
    
    func removeHelpFileNodes() {
        // we need to hide our first set of nodes
        self.enumerateChildNodesWithName("help_text", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
        
        self.enumerateChildNodesWithName("LittleSpaceExplorer", usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
    }
    
    func showBombInfo() {
        let text: [String] = [
            "Collecting a bomb",
            "will immediatly",
            "clear every fly",
            "and ant from the",
            "scene."
        ]
        
        var i = 0
        var y: CGFloat = 0.0
        
        for line in text {
            y = CGFloat((Int(self.frame.height-200))-(i*30))
            self.addChild(self.helpers.createLabel(String(format: line), fontSize: 24, position: CGPointMake(200, y), name: "help_text", color: SKColor.blackColor()))
            i++
        }
        
        let node = SKSpriteNode(imageNamed:"bomb_red")
        node.position = CGPointMake(200, y-30)
        node.name = "help_text"
        node.zPosition = 99
        
        // blink so user notices it
        let blink1 = SKTexture(imageNamed: "bomb_red")
        let blink2 = SKTexture(imageNamed: "bomb_red_dark")
        let moves = SKAction.animateWithTextures([blink1, blink2], timePerFrame: 0.4)
        
        node.runAction(SKAction.repeatActionForever(moves), withKey:"move")
        
        self.addChild(node)
    }
    
    func showBlueRocksInfo() {
        let text: [String] = [
            "Blue rocks are thrown",
            "in groups of five and",
            "in consecutive order."
        ]
        
        var i = 0
        var y: CGFloat = 0.0
        
        for line in text {
            y = CGFloat((Int(self.frame.height-200))-(i*30))
            self.addChild(self.helpers.createLabel(String(format: line), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), y), name: "help_text", color: SKColor.blackColor()))
            i++
        }
        
        let node = SKSpriteNode(imageNamed:"bluerocks")
        node.position = CGPointMake(CGRectGetMidX(self.frame), y-30)
        node.name = "help_text"
        node.zPosition = 99
        
        // blink so user notices it
        let blink1 = SKTexture(imageNamed: "bluerocks")
        let blink2 = SKTexture(imageNamed: "rocks")
        let moves = SKAction.animateWithTextures([blink1, blink2], timePerFrame: 0.4)
        
        node.runAction(SKAction.repeatActionForever(moves), withKey:"move")
        
        self.addChild(node)
    }
    
    func showRedRocksInfo() {
        let text: [String] = [
            "Red rocks are thrown",
            "in groups of five and",
            "in a spray pattern."
        ]
        
        var i = 0
        var y: CGFloat = 0.0
        
        for line in text {
            y = CGFloat((Int(self.frame.height-200))-(i*30))
            self.addChild(self.helpers.createLabel(String(format: line), fontSize: 24, position: CGPointMake(self.frame.width-200, y), name: "help_text", color: SKColor.blackColor()))
            i++
        }
        
        let node = SKSpriteNode(imageNamed:"redrocks")
        node.position = CGPointMake(self.frame.width-200, y-30)
        node.name = "help_text"
        node.zPosition = 99
        
        // blink so user notices it
        let blink1 = SKTexture(imageNamed: "redrocks")
        let blink2 = SKTexture(imageNamed: "rocks")
        let moves = SKAction.animateWithTextures([blink1, blink2], timePerFrame: 0.4)
        
        node.runAction(SKAction.repeatActionForever(moves), withKey:"move")
        
        self.addChild(node)
    }
    
    func showBlackAntInfo() {
        let text: [String] = [
            "Black ants move at",
            "one speed making",
            "them predictable.",
            "Stomp or throw a",
            "rock at them to",
            "clear them from",
            "scene."
        ]
        
        var i = 0
        var y: CGFloat = 0.0
        
        for line in text {
            y = CGFloat((Int(self.frame.height-200))-(i*30))
            self.addChild(self.helpers.createLabel(String(format: line), fontSize: 24, position: CGPointMake(200, y), name: "help_text", color: SKColor.blackColor()))
            i++
        }
        
        let node = SKSpriteNode(imageNamed:"ant_stand_black")
        node.position = CGPointMake(200, y-50)
        node.name = "help_text"
        node.zPosition = 99
        
        self.addChild(node)
    }
    
    func showRedAntInfo() {
        let text: [String] = [
            "Red ants move at",
            "different speeds.",
            "As they approach",
            "they move quicker.",
            "Stomp or throw a",
            "rock at them to",
            "clear them from",
            "scene."
        ]
        
        var i = 0
        var y: CGFloat = 0.0
        
        for line in text {
            y = CGFloat((Int(self.frame.height-200))-(i*30))
            self.addChild(self.helpers.createLabel(String(format: line), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), y), name: "help_text", color: SKColor.blackColor()))
            i++
        }
        
        let node = SKSpriteNode(imageNamed:"ant_stand")
        node.position = CGPointMake(CGRectGetMidX(self.frame), y-50)
        node.name = "help_text"
        node.zPosition = 99
        
        self.addChild(node)
    }
    
    func showFlyInfo() {
        let text: [String] = [
            "Flies move",
            "at any which",
            "direction.  ",
            "Throw a",
            "rock at them to",
            "clear them from",
            "scene."
        ]
        
        var i = 0
        var y: CGFloat = 0.0
        
        for line in text {
            y = CGFloat((Int(self.frame.height-200))-(i*30))
            self.addChild(self.helpers.createLabel(String(format: line), fontSize: 24, position: CGPointMake(self.frame.width-200, y), name: "help_text", color: SKColor.blackColor()))
            i++
        }
        
        let node = SKSpriteNode(imageNamed:"fly_1")
        node.position = CGPointMake(self.frame.width-200, y-50)
        node.name = "help_text"
        node.zPosition = 99
        
        self.addChild(node)
    }
    
    func showSecondHelpFile() {
        self.showBombInfo()
        self.showBlueRocksInfo()
        self.showRedRocksInfo()
        
        self.addChild(self.helpers.createLabel("Note: When throwing blue and red rocks you are not restricted by the half second rule.", fontSize: 16, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-150), name: "help_text", color: SKColor.blackColor()))
        self.addChild(self.helpers.createLabel("Also note that if you have both red and blue rocks, red rocks are thrown first.", fontSize: 16, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-175), name: "help_text", color: SKColor.blackColor()))
    }
    
    func showEnemyInfoFile() {
        self.showBlackAntInfo()
        self.showRedAntInfo()
        self.showFlyInfo()
    }
    
    func showThirdHelpFile() {
        let text: [String] = [
            "All audio was provided by http://www.freesound.org/",
            "and is licensed under the Creative Commons 0 License which",
            "can be viewed here: http://creativecommons.org/publicdomain/zero/1.0/.",
            "",
            "Most artwork was provided by Vicki Wenderlich @",
            "http://www.gameartguppy.com/ which is licensed under the Creative",
            "Commons Attribution License which can be viewed here:",
            "http://creativecommons.org/licenses/by/2.0/, and by ",
            "http://graphicburger.com which provides royalty free art.",
            "",
            "All other work was created and is owned by Andrew Schools.",
            "Copyright 2015, Andrew Schools."
        ]
        
        var i = 0
        
        for line in text {
            self.addChild(self.helpers.createLabel(String(format: line), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGFloat((Int(self.frame.height-150))-(i*30))), name: "help_text", color: SKColor.blackColor()))
            i++
        }

    }
    
    func showEasyDifficultyInfo() {
         self.addChild(self.helpers.createLabel("Easy Mode", fontSize: 36, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+200), name: "help_text"))
        
        let text: [String] = [
            "In Easy mode a fly and an ant are added to the scene",
            "every 4 to 6 seconds.  Every 60 seconds these two numbers",
            "are subtracted by one until each number is equal to one.",
            "At this point a fly and an ant are added to the scene every",
            "4 seconds.  In this mode you start off with 5 lives and",
            "get an additional life every 60 seconds."
        ]
        
        var i = 0
        for line in text {
            self.addChild(self.helpers.createLabel(String(format: line), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGFloat((Int(self.frame.height-250))-(i*30))), name: "help_text", color: SKColor.blackColor()))
            i++
        }
    }

    func showHardDifficultyInfo() {
        self.addChild(self.helpers.createLabel("Hard Mode", fontSize: 36, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+200), name: "help_text"))
        
        let text: [String] = [
            "In Hard mode a fly and an ant are added to the scene",
            "every 3 to 5 seconds.  Every 45 seconds these two numbers",
            "are subtracted by one until each number is equal to one.",
            "At this point a fly and an ant are added to the scene every",
            "3 seconds.  In this mode you start off with 3 lives and",
            "get an additional life every 45 seconds.  Note: Flies move",
            "quicker than in Easy mode so watch out."
        ]
        
        var i = 0
        for line in text {
            self.addChild(self.helpers.createLabel(String(format: line), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGFloat((Int(self.frame.height-250))-(i*30))), name: "help_text", color: SKColor.blackColor()))
            i++
        }
    }
    
    func showKrazyDifficultyInfo() {
        self.addChild(self.helpers.createLabel("Krazy Mode", fontSize: 36, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+200), name: "help_text"))
        
        let text: [String] = [
            "In Krazy mode a fly and an ant are added to the scene",
            "every 2 to 4 seconds.  Every 30 seconds these two numbers",
            "are subtracted by one until each number is equal to one.",
            "At this point a fly and an ant are added to the scene every",
            "2 seconds.  In this mode you start off with 3 lives and",
            "get an additional life every 30 seconds.  Note: Flies move",
            "quicker than in Easy mode so watch out."
        ]
        
        var i = 0
        for line in text {
            self.addChild(self.helpers.createLabel(String(format: line), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGFloat((Int(self.frame.height-250))-(i*30))), name: "help_text", color: SKColor.blackColor()))
            i++
        }
    }
    
    func showLittleSpaceExplorerAdInfo() {
        self.addChild(self.helpers.createLabel("Other Games", fontSize: 36, position: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+200), name: "help_text"))
        
        let text: [String] = [
            "Check out my other game Little Space Explorer.",
            "Like Krazy Koala, it's free and addictive!",
            "Click image below to download from the App Store."
        ]
        
        var i = 0
        for line in text {
            self.addChild(self.helpers.createLabel(String(format: line), fontSize: 24, position: CGPointMake(CGRectGetMidX(self.frame), CGFloat((Int(self.frame.height-250))-(i*30))), name: "help_text", color: SKColor.blackColor()))
            i++
        }
        
        let node = SKSpriteNode(imageNamed:"LittleSpaceExplorer640x640.jpg")
        node.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-50)
        node.name = "LittleSpaceExplorer"
        node.zPosition = 100
        node.xScale = 0.6
        node.yScale = 0.6
        
        self.addChild(node)
    }
    
    func openAppStore() {
        let iTunesLink = "https://itunes.apple.com/us/app/little-space-explorer/id961399066?mt=8"
        UIApplication.sharedApplication().openURL(NSURL(string: iTunesLink)!)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            var nodeName = ""
            var moveButtonPressed = false
            
            if node.name != nil {
                nodeName = node.name!
            }
            
            if nodeName == "Forward" {
                self.helpFilePos++
                moveButtonPressed = true
                self.currentPage++
                self.showPageNum()
            } else if nodeName == "Back" {
                self.helpFilePos--
                moveButtonPressed = true
                self.currentPage--
                self.showPageNum()
            }
            
            if moveButtonPressed == true {
                if self.helpFilePos == 0 {
                    self.removeHelpFileNodes()
                    self.showFirstHelpFile()
                } else if self.helpFilePos == 1 {
                    self.removeHelpFileNodes()
                    self.showSecondHelpFile()
                } else if self.helpFilePos == 2 {
                    self.removeHelpFileNodes()
                    self.showEnemyInfoFile()
                } else if self.helpFilePos == 3 {
                    self.removeHelpFileNodes()
                    self.showLittleSpaceExplorerAdInfo()
                } else if self.helpFilePos == 4 {
                    self.removeHelpFileNodes()
                    self.showThirdHelpFile()
                } else {
                    // Go back to start menu
                    let startScene = StartScene(size: self.size, gameViewController: self.controller)
                    startScene.scaleMode = .AspectFill
                    self.view?.presentScene(startScene)
                }
            } else {
                if nodeName == "LittleSpaceExplorer" {
                    self.openAppStore()
                }
            }
        }
    }
}