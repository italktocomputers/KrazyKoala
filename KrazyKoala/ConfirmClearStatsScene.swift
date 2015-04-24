//
//  ConfirmClearStatsScene.swift
//  KrazyKoala
//
//  Created by Andrew Schools on 1/4/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

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
        if (self.controller!.iAdError == true) {
            if (self.controller!.isLoadingiAd == false) {
                // there was an error loading iAd so let's try again
                self.controller!.loadAds()
            }
        } else {
            // we already have loaded iAd so let's just show it
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
        
        var panel = SKSpriteNode(imageNamed:"Panel")
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
        var node = SKSpriteNode(imageNamed:"Backbtn")
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
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var difficulty = ""
        var nodeName = ""
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = self.nodeAtPoint(location)
            
            if (node.name != nil) {
                nodeName = node.name!
            }
            
            if (nodeName == "Back" || nodeName == "Cancel") {
                // go back to start menu
                let settingsScene = SettingsScene(size: self.size, gameViewController: self.controller!)
                settingsScene.scaleMode = .AspectFill
                self.view?.presentScene(settingsScene)
            } else if (nodeName == "Okay") {
                self.helpers.clearStats()
                self.showCompleteMessage()
            }
        }
    }
}