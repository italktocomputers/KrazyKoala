/*

Copyright (c) 2021 Andrew Schools

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
    
    override func didMove(to view: SKView) {
        /*
        if self.controller!.iAdError == true {
            if self.controller!.isLoadingiAd == false {
                // There was an error loading iAd so let's try again
                self.controller!.loadAds()
            }
        }
        else {
            // We already have loaded iAd so let's just show it
            self.controller!.adBannerView?.isHidden = false
        }
        */
        var background = SKSpriteNode()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            background = SKSpriteNode(imageNamed:"BG_Jungle_hor_rpt_1280x800")
        }
        else {
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
        panel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        panel.zPosition = 1
        self.addChild(panel)
        
        let banner = SKSpriteNode(imageNamed:"KrazyKoalaRibbon")
        banner.position = CGPoint(x: self.frame.midX, y: self.frame.height-175)
        banner.zPosition = 2
        banner.xScale = 1
        banner.yScale = 1
        self.addChild(banner)
        
        self.addBackButton()
        
        self.addChild(
            self.helpers.createLabel(
                text: "are you sure",
                fontSize: 24,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY+30),
                color: SKColor.black
            )
        )
        
        self.addChild(
            self.helpers.createLabel(
                text: "you want to clear your local stats?",
                fontSize: 18,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY),
                color: SKColor.black
            )
        )
        
        
        let accept = SKSpriteNode(imageNamed:"Accept")
        accept.position = CGPoint(x: self.frame.midX-75, y: self.frame.midY-50)
        accept.zPosition = 2
        accept.name = "Okay"
        self.addChild(accept)
        
        let warning = SKSpriteNode(imageNamed:"Warning")
        warning.position = CGPoint(x: self.frame.midX+75, y: self.frame.midY-50)
        warning.zPosition = 2
        warning.name = "Cancel"
        self.addChild(warning)
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
    
    func showCompleteMessage() {
        self.helpers.removeNodeByName(scene: self, name: "Okay")
        self.helpers.removeNodeByName(scene: self, name: "Cancel")
        self.helpers.removeNodeByName(scene: self, name: "Are you sure?")
        self.helpers.removeNodeByName(scene: self, name: "You want to clear your local stats?")
        
        self.addChild(
            self.helpers.createLabel(
                text: "Your stats have been cleared!",
                fontSize: 36,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY+50),
                color: SKColor.black
            )
        )
        self.addChild(
            self.helpers.createLabel(
                text: "You better get to work...",
                fontSize: 24,
                position: CGPoint(x: self.frame.midX, y: self.frame.midY),
                color: SKColor.black
            )
        )
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var nodeName = ""
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name != nil {
                nodeName = node.name!
            }
            
            if nodeName == "Back" || nodeName == "Cancel" {
                // Go back to start menu
                let settingsScene = SettingsScene(size: self.size, gameViewController: self.controller!)
                settingsScene.scaleMode = .aspectFill
                self.view?.presentScene(settingsScene)
            }
            else if nodeName == "Okay" {
                self.helpers.clearStats()
                self.showCompleteMessage()
            }
        }
    }
}
