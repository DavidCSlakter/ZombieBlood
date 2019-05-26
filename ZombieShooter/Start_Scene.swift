//
//  GameScene.swift
//  ZombieShooter
//
//  Created by David Slakter on 6/6/15.
//  Copyright (c) 2015 GoLock. All rights reserved.
//  
// This is the first scene when the game loads up- It's the menu scene
//

import SpriteKit
import AVFoundation

var backgroundMusic: AVAudioPlayer?
let backgroundMusicURL = URL(fileURLWithPath: Bundle.main.path(forResource: "zombie_background_music", ofType: "mp3")!)

class GameScene: SKScene {
    
    var betaVersion = false
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let appBundle = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    
    
    override func didMove(to view: SKView) {
      let highScore = UserDefaults.standard.integer(forKey: "highScoreSaved")
        backgroundColor = SKColor.black
        
  
   let Title = SKSpriteNode(imageNamed: "gameTitle.png")
        Title.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.7)
        Title.size = CGSize(width: 500, height: 120)
        Title.alpha = 0.8
        Title.zPosition = 1
        self.addChild(Title)
    
    let highScoreLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.alpha = 0.7
        highScoreLabel.fontSize = 60
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.45)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)

    
    let fireflies = SKEmitterNode(fileNamed: "fireflies.sks")
        fireflies!.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.width/2)
        fireflies!.zPosition = 0
        self.addChild(fireflies!)
    
    
    let startLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
        startLabel.text = "Touch Anywhere to start"
        startLabel.fontSize = 50
        startLabel.position = CGPoint(x: self.frame.size.width/2 + 5, y: self.frame.size.height*0.25)
        startLabel.alpha = 0
        startLabel.zPosition = 1
        self.addChild(startLabel)
    
        if(betaVersion){
            let betaLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
            betaLabel.text =  "BETA V \(version)"
            betaLabel.fontSize = 40
            betaLabel.position = CGPoint(x: self.frame.size.width*0.12, y: Title.position.y+80)
            betaLabel.fontColor = SKColor.white
            betaLabel.alpha = 0.8
            betaLabel.zPosition = 1
            addChild(betaLabel)
        }
    
        
    let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 3)
    let fadeOut = SKAction.fadeAlpha(to: 0.1, duration: 3)
        let sequence = SKAction.sequence([fadeIn, fadeOut])
        startLabel.run(SKAction.repeatForever(sequence))
    
        do{
            backgroundMusic = try AVAudioPlayer(contentsOf: backgroundMusicURL)
            guard let backgroundMusic = backgroundMusic else { return }
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)

            backgroundMusic.volume = 0.5
            backgroundMusic.prepareToPlay()
            backgroundMusic.play()
            
        } catch let error as NSError {
            print(error.description)
        }
    
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        backgroundMusic?.stop()
        let scene2 = Main_Scene(size: self.size)
        scene2.scaleMode = self.scaleMode
        let reveal = SKTransition.fade(withDuration: 1)
        self.view?.presentScene(scene2, transition: reveal)
    
    }
    
}
