//
//  Game_Shop.swift
//  ZombieShooter
//
//  Created by David Slakter on 1/23/16.
//  Copyright © 2016 GoLock. All rights reserved.
//

import Foundation
import SpriteKit


class Game_Shop: SKScene {

        var totalSavedCoins = UserDefaults.standard.integer(forKey: "totalCoinsSaved")
    
       let returnToGame = SKLabelNode(fontNamed:"Futura-CondensedExtraBold")

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        let fireflies = SKEmitterNode(fileNamed: "fireflies.sks")
        fireflies!.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.width/2)
        fireflies!.zPosition = 0
        self.addChild(fireflies!)
        
      /*  let Title = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
        Title.text = "Shop"
        Title.fontSize = 50
        Title.fontColor = UIColor.whiteColor()
        Title.position = CGPoint(x: self.frame.width/2, y: self.frame.height*0.8)
        Title.zPosition = 2
        self.addChild(Title)*/
        
        let ComingSoon = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
        ComingSoon.text = "Coming Soon!"
        ComingSoon.fontSize = 100
        ComingSoon.fontColor = UIColor.white
        ComingSoon.position = CGPoint(x: self.frame.width/2, y: self.frame.height*0.45)
        ComingSoon.zPosition = 2
        self.addChild(ComingSoon)
        
        let totalCoinsLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        totalCoinsLabel.text = "Coins: \(totalSavedCoins)"
        totalCoinsLabel.fontSize = 50
        totalCoinsLabel.fontColor = UIColor.white
        totalCoinsLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.8)
        totalCoinsLabel.zPosition = 2
        self.addChild(totalCoinsLabel)
     
        returnToGame.text = "Play"
        returnToGame.fontSize = 70
        returnToGame.fontColor = UIColor.white
        returnToGame.position = CGPoint(x: self.frame.width*0.1, y: self.frame.height*0.8)
        returnToGame.zPosition = 2
        self.addChild(returnToGame)
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            
            let location = touch.location(in: self)
            
            if (returnToGame.contains(location)){
                let reveal = SKTransition.fade(withDuration: 1)
                let scene2 = Main_Scene(size: self.size)
                scene2.scaleMode = scaleMode
                self.view?.presentScene(scene2, transition: reveal)
            }
        }
    }
}
