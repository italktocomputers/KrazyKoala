//
//  Helpers.swift
//  KrazyKoala
//
//  Created by Andrew Schools on 1/30/15.
//  Copyright (c) 2015 Andrew Schools. All rights reserved.
//

import Foundation
import SpriteKit

class Helpers {
    func createLabel(text: String, fontSize: CGFloat, position: CGPoint, name:String="", color:SKColor=SKColor.blackColor(), font:String="Thonburi-Bold", zPos:CGFloat=100) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: font)
        label.text = text
        label.fontColor = color
        label.fontSize = fontSize
        label.position = position
        label.zPosition = zPos
        
        if (name == "") {
            label.name = text
        } else {
            label.name = name
        }
        
        return label
    }
    
    func createButton(name: String, position: CGPoint) -> SKSpriteNode {
        let button = SKSpriteNode(imageNamed:"EasyButton")
        button.position = position
        button.zPosition = 99
        button.name = name
        button.xScale = 1.5
        button.yScale = 1.5
        
        return button
    }
    
    func removeNodeByName(scene: SKScene, name: String) {
        scene.enumerateChildNodesWithName(name, usingBlock: {(node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            node.removeFromParent()
        })
    }
    
    func saveHighScore(score: Int, difficulty: String) {
        var key = "highScore_"+difficulty
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(score, forKey: key)
        defaults.synchronize()
    }
    
    func saveHighClearStreak(score: Int, difficulty: String) {
        var key = "highClearStreak_"+difficulty
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(score, forKey: key)
        defaults.synchronize()
    }
    
    func saveHighLevel(level: Int, difficulty: String) {
        var key = "highLevel_"+difficulty
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(level, forKey: key)
        defaults.synchronize()
    }
    
    func saveLastScore(score: Int, difficulty: String) {
        var key = "lastScore_"+difficulty
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(score, forKey: key)
        defaults.synchronize()
    }
    
    func saveLastClearStreak(score: Int, difficulty: String) {
        var key = "lastClearStreak_"+difficulty
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(score, forKey: key)
        defaults.synchronize()
    }
    
    func saveLastLevel(level: Int, difficulty: String) {
        var key = "lastLevel_"+difficulty
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(level, forKey: key)
        defaults.synchronize()
    }
    
    func getHighScore(difficulty: String) -> Int {
        var key = "highScore_"+difficulty
        var defaults = NSUserDefaults.standardUserDefaults()
        return defaults.integerForKey(key)
    }
    
    func getHighClearStreak(difficulty: String) -> Int {
        var key = "highClearStreak_"+difficulty
        var defaults = NSUserDefaults.standardUserDefaults()
        return defaults.integerForKey(key)
    }
    
    func getHighLevel(difficulty: String) -> Int {
        var key = "highLevel_"+difficulty
        var defaults = NSUserDefaults.standardUserDefaults()
        return defaults.integerForKey(key)
    }
    
    func getLastScore(difficulty: String) -> Int {
        var key = "lastScore_"+difficulty
        var defaults = NSUserDefaults.standardUserDefaults()
        return defaults.integerForKey(key)
    }
    
    func getLastClearStreak(difficulty: String) -> Int {
        var key = "lastClearStreak_"+difficulty
        var defaults = NSUserDefaults.standardUserDefaults()
        return defaults.integerForKey(key)
    }
    
    func getLastLevel(difficulty: String) -> Int {
        var key = "lastLevel_"+difficulty
        var defaults = NSUserDefaults.standardUserDefaults()
        return defaults.integerForKey(key)
    }
    
    func saveMusicSetting(option: Bool) {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(option, forKey: "musicOn")
        defaults.synchronize()
    }
    
    func getMusicSetting() -> Bool {
        var defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey("musicOn")
    }
    
    func saveVibrationSetting(option: Bool) {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(option, forKey: "vibrationOn")
        defaults.synchronize()
    }
    
    func getVibrationSetting() -> Bool {
        var defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey("vibrationOn")
    }
    
    func saveGameCenterSetting(option: Bool) {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(option, forKey: "gameCenterOn")
        defaults.synchronize()
    }
    
    func getGameCenterSetting() -> Bool {
        var defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey("gameCenterOn")
    }
    
    func clearStats() {
        var defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setInteger(0, forKey: "lastScore_Easy")
        defaults.setInteger(0, forKey: "lastScore_Hard")
        defaults.setInteger(0, forKey: "lastScore_Krazy")
        
        defaults.setInteger(0, forKey: "highScore_Easy")
        defaults.setInteger(0, forKey: "highScore_Hard")
        defaults.setInteger(0, forKey: "highScore_Krazy")
        
        defaults.setInteger(0, forKey: "lastClearStreak_Easy")
        defaults.setInteger(0, forKey: "lastClearStreak_Hard")
        defaults.setInteger(0, forKey: "lastClearStreak_Krazy")
        
        defaults.setInteger(0, forKey: "highClearStreak_Easy")
        defaults.setInteger(0, forKey: "highClearStreak_Hard")
        defaults.setInteger(0, forKey: "highClearStreak_Krazy")
        
        defaults.setInteger(1, forKey: "lastLevel_Easy")
        defaults.setInteger(1, forKey: "lastLevel_Hard")
        defaults.setInteger(1, forKey: "lastLevel_Krazy")
        
        defaults.setInteger(1, forKey: "highLevel_Easy")
        defaults.setInteger(1, forKey: "highLevel_Hard")
        defaults.setInteger(1, forKey: "highLevel_Krazy")
        
        defaults.synchronize()
    }
}