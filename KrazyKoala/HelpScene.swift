/*

Copyright (c) 2021 Andrew Schools

*/
import SpriteKit
import iAd

class HelpScene: SKScene {
    var helpFilePos = 0
    var controller: GameViewController
    var helpers = Helpers()
    var panel = SKSpriteNode()
    var currentPage = 1
    var totalPages = 7
    
    init(size: CGSize, gameViewController: GameViewController) {
        self.controller = gameViewController
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        /*
        if self.controller.iAdError == true {
            if self.controller.isLoadingiAd == false {
                // there was an error loading iAd so let's try again
                self.controller.loadAds()
            }
        }
        else {
            // we already have loaded iAd so let's just show it
            self.controller.adBannerView?.isHidden = false
        }
        */
        
        var background = SKSpriteNode()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            background = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1280x800")
        }
        else {
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
        panel.xScale = 1.1
        panel.yScale = 1.1
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        panel.zPosition = 1
        
        self.panel = panel
        self.addChild(self.panel)
        
        let banner = SKSpriteNode(imageNamed:"KrazyKoalaRibbon")
        banner.position = CGPoint(x: self.frame.midX, y: self.frame.height-175)
        banner.zPosition = 2
        banner.name = name
        banner.xScale = 1
        banner.yScale = 1
        self.addChild(banner)
        
        self.showFirstHelpFile()
        self.addForwardButton()
        self.addBackButton()
        self.showPageNum()
    }
    
    func showPageNum() {
        self.enumerateChildNodes(
            withName: "pageNums",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                node.removeFromParent()
            }
        )
        
        self.addChild(
            self.helpers.createLabel(
                text: String(format:"Page %i of %i", self.currentPage, self.totalPages),
                fontSize: 10,
                position: CGPoint(x: self.panel.frame.midY+450, y: self.panel.frame.midY-200),
                name:"pageNums"
            )
        )
    }
    
    func addForwardButton() {
        let node = SKSpriteNode(imageNamed:"Forwardbtn")
        node.xScale = 1.5
        node.yScale = 1.5
        node.position = CGPoint(x: self.frame.width-175, y: self.frame.midY)
        node.zPosition = 2
        node.name = "Forward"
        self.addChild(node)
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
    
    func showFirstHelpFile() {
        let text: [String] = [
            "The premise is simple. Destroy as many flies and ants as you can by throwing",
            "rocks at them while making your way through the jungle. Along the way you",
            "can collect items (blue rocks, red rocks and bombs) that can help you stay",
            "alive.  How to play: Click to jump. While in the air click again to throw a",
            "rock at a fly or ant to remove it from the scene and gain a point. You are only",
            "allowed to throw a rock every half second.  If hit by a fly you will loose a",
            "life.  Walking into an ant will do the same.  As well as throwing rocks, you",
            "can jump on ants to clear them from the scene and gain a point.  As you progress",
            "more flies will enter the scene but don't fret as you will also receive",
            "additional lives.  Good luck and don't forget to have fun!!!"
        ]
        
        var i = 0
        for line in text {
            self.addChild(
                self.helpers.createLabel(
                    text: String(format: line),
                    fontSize: 14,
                    position: CGPoint(x: self.frame.midX, y: CGFloat((Int(self.frame.height-250))-(i*30))),
                    name: "help_text",
                    color: SKColor.black
                )
            )
            i+=1
        }
    }
    
    func removeHelpFileNodes() {
        // we need to hide our first set of nodes
        self.enumerateChildNodes(
            withName: "help_text",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                node.removeFromParent()
            }
        )
        
        self.enumerateChildNodes(
            withName: "LittleSpaceExplorer",
            using: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                node.removeFromParent()
            }
        )
    }
    
    func showBombInfo() {
        let node = SKSpriteNode(imageNamed:"bomb_red")
        node.position = CGPoint(x: 225, y: 427)
        node.name = "help_text"
        node.zPosition = 99
        
        let blink1 = SKTexture(imageNamed: "bomb_red")
        let blink2 = SKTexture(imageNamed: "bomb_red_dark")
        let moves = SKAction.animate(with: [blink1, blink2], timePerFrame: 0.4)
        
        node.run(SKAction.repeatForever(moves), withKey:"move")
        
        self.addChild(node)
        
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "Collecting a bomb will immediatly clear every fly and ant from the scene."),
                fontSize: 14,
                position: CGPoint(x: 500, y: 420),
                name: "help_text",
                color: SKColor.black
            )
        )
    }
    
    func showBlueRocksInfo() {
        let node = SKSpriteNode(imageNamed:"bluerocks")
        node.position = CGPoint(x: 270, y: 375)
        node.name = "help_text"
        node.zPosition = 99
        
        let blink1 = SKTexture(imageNamed: "bluerocks")
        let blink2 = SKTexture(imageNamed: "rocks")
        let moves = SKAction.animate(with: [blink1, blink2], timePerFrame: 0.4)
        
        node.run(SKAction.repeatForever(moves), withKey:"move")
        
        self.addChild(node)
        
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "Blue rocks are thrown in groups of five and in consecutive order."),
                fontSize: 14,
                position: CGPoint(x: 525, y: 375),
                name: "help_text",
                color: SKColor.black
            )
        )
    }
    
    func showRedRocksInfo() {
        let node = SKSpriteNode(imageNamed:"redrocks")
        node.position = CGPoint(x: 280, y: 330)
        node.name = "help_text"
        node.zPosition = 99
        
        let blink1 = SKTexture(imageNamed: "redrocks")
        let blink2 = SKTexture(imageNamed: "rocks")
        let moves = SKAction.animate(with: [blink1, blink2], timePerFrame: 0.4)
        
        node.run(SKAction.repeatForever(moves), withKey:"move")
        
        self.addChild(node)
        
        self.addChild(
            self.helpers.createLabel(
                text: String(format: "Red rocks are thrown in groups of five and in a spray pattern."),
                fontSize: 14,
                position: CGPoint(x: 535, y: 330),
                name: "help_text",
                color: SKColor.black
            )
        )
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
            self.addChild(
                self.helpers.createLabel(
                    text: String(format: line),
                    fontSize: 14,
                    position: CGPoint(x: 300, y: y),
                    name: "help_text",
                    color: SKColor.black
                )
            )
            i+=1
        }
        
        let node = SKSpriteNode(imageNamed:"ant_stand_black")
        node.position = CGPoint(x: 300, y: y-50)
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
            self.addChild(
                self.helpers.createLabel(
                    text: String(format: line),
                    fontSize: 14,
                    position: CGPoint(x: self.frame.midX, y: y),
                    name: "help_text",
                    color: SKColor.black
                )
            )
            i+=1
        }
        
        let node = SKSpriteNode(imageNamed:"ant_stand")
        node.position = CGPoint(x: self.frame.midX, y: y-50)
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
            self.addChild(
                self.helpers.createLabel(
                    text: String(format: line),
                    fontSize: 14,
                    position: CGPoint(x: self.frame.width-300, y: y),
                    name: "help_text",
                    color: SKColor.black
                )
            )
            i+=1
        }
        
        let node = SKSpriteNode(imageNamed:"fly_1")
        node.position = CGPoint(x: self.frame.width-300, y: y-50)
        node.name = "help_text"
        node.zPosition = 99
        
        self.addChild(node)
    }
    
    func showSecondHelpFile() {
        self.showBombInfo()
        self.showBlueRocksInfo()
        self.showRedRocksInfo()
        
        self.addChild(
            self.helpers.createLabel(
                text: "Note: When throwing blue and red rocks you are not restricted by the half second rule.",
                fontSize: 14,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY-125),
                name: "help_text",
                color: SKColor.black
            )
        )
        
        self.addChild(
            self.helpers.createLabel(
                text: "Also note that if you have both red and blue rocks, red rocks are thrown first.",
                fontSize: 14,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY-150),
                name: "help_text",
                color: SKColor.black
            )
        )
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
            "Copyright 2021, Andrew Schools."
        ]
        
        var i = 0
        
        for line in text {
            self.addChild(
                self.helpers.createLabel(
                    text: String(format: line),
                    fontSize: 14,
                    position: CGPoint(x: self.frame.midX, y: CGFloat((Int(self.frame.height-200))-(i*30))),
                    name: "help_text",
                    color: SKColor.black
                )
            )
            i+=1
        }

    }
    
    func showEasyDifficultyInfo() {
         self.addChild(
            self.helpers.createLabel(
                text: "Easy Mode",
                fontSize: 18,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY+150),
                name: "help_text"
            )
        )
        
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
            self.addChild(
                self.helpers.createLabel(
                    text: String(format: line),
                    fontSize: 14,
                    position: CGPoint(x: self.frame.midX, y: CGFloat((Int(self.frame.height-250))-(i*30))),
                    name: "help_text",
                    color: SKColor.black
                )
            )
            i+=1
        }
    }

    func showHardDifficultyInfo() {
        self.addChild(
            self.helpers.createLabel(
                text: "Hard Mode",
                fontSize: 18,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY+150),
                name: "help_text"
            )
        )
        
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
            self.addChild(
                self.helpers.createLabel(
                    text: String(format: line),
                    fontSize: 14,
                    position: CGPoint(x: self.frame.midX, y: CGFloat((Int(self.frame.height-250))-(i*30))),
                    name: "help_text",
                    color: SKColor.black
                )
            )
            i+=1
        }
    }
    
    func showKrazyDifficultyInfo() {
        self.addChild(
            self.helpers.createLabel(
                text: "Krazy Mode",
                fontSize: 18,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY+150),
                name: "help_text"
            )
        )
        
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
            self.addChild(
                self.helpers.createLabel(
                    text: String(format: line),
                    fontSize: 14,
                    position: CGPoint(x: self.frame.midX, y: CGFloat((Int(self.frame.height-250))-(i*30))),
                    name: "help_text",
                    color: SKColor.black
                )
            )
            i+=1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            var nodeName = ""
            var moveButtonPressed = false
            
            if node.name != nil {
                nodeName = node.name!
            }
            
            if nodeName == "Forward" {
                self.helpFilePos+=1
                moveButtonPressed = true
                self.currentPage+=1
                self.showPageNum()
            }
            else if nodeName == "Back" {
                self.helpFilePos-=1
                moveButtonPressed = true
                self.currentPage-=1
                self.showPageNum()
            }
            
            if moveButtonPressed == true {
                if self.helpFilePos == 0 {
                    self.removeHelpFileNodes()
                    self.showFirstHelpFile()
                }
                else if self.helpFilePos == 1 {
                    self.removeHelpFileNodes()
                    self.showSecondHelpFile()
                }
                else if self.helpFilePos == 2 {
                    self.removeHelpFileNodes()
                    self.showEnemyInfoFile()
                }
                else if self.helpFilePos == 3 {
                    self.removeHelpFileNodes()
                    self.showEasyDifficultyInfo()
                }
                else if self.helpFilePos == 4 {
                    self.removeHelpFileNodes()
                    self.showHardDifficultyInfo()
                }
                else if self.helpFilePos == 5 {
                    self.removeHelpFileNodes()
                    self.showKrazyDifficultyInfo()
                }
                else if self.helpFilePos == 6 {
                    self.removeHelpFileNodes()
                    self.showThirdHelpFile()
                }
                else {
                    // Go back to start menu
                    let startScene = StartScene(size: self.size, gameViewController: self.controller)
                    startScene.scaleMode = .aspectFill
                    self.view?.presentScene(startScene)
                }
            }
        }
    }
}
