//
//  GameViewController.swift
//  KrazyKoala
//
//  Created by Andrew Schools on 1/3/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController, ADBannerViewDelegate, FBLoginViewDelegate, FBWebDialogsDelegate {
    var iAdError = false
    var adBannerView: ADBannerView?
    var isLoadingiAd = false
    var currentSceneName: String = ""
    
    func loadAds() {
        self.isLoadingiAd = true
        
        let adBannerView = ADBannerView()
        adBannerView.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height - adBannerView.frame.size.height / 2)
        adBannerView.delegate = self
        adBannerView.hidden = true
        view.addSubview(adBannerView)
        
        self.adBannerView = adBannerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadAds()
        self.adBannerView?.hidden = true
        
        let skView = self.view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        //skView.showsPhysics = true
        
        skView.ignoresSiblingOrder = true
        
        let size = CGSizeMake(1024, 768)
        let scene = StartScene(size: size, gameViewController: self)
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
    }
    
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
    
    //iAd
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        //println("bannerViewWillLoadAd")
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        //println("bannerViewDidLoadAd")
        
        self.iAdError = false
        self.isLoadingiAd = false
        
        if (currentSceneName != "GameScene") {
            banner.hidden = false
        } else {
            banner.hidden = true // no iAds during game play
        }
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        //println("bannerViewActionDidFinish")
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        //println("bannerViewActionShouldBegin")
        return true 
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        //println("iAd error")
        
        banner.hidden = true
        banner.removeFromSuperview()
        self.iAdError = true
        self.isLoadingiAd = false
    }
}
