//
//  Main_Scene.swift
//  ZombieShooter
//
//  Created by David Slakter on 6/6/15.
//  Copyright (c) 2015 AmericanSwiss. All rights reserved.
//  Last Edited on 5/22/16
//

import Foundation
import SpriteKit
import UIKit
import AVFoundation

var GameInstance: Main_Scene?

class Main_Scene: SKScene, SKPhysicsContactDelegate  {
    
    var buttonLeft = SKSpriteNode(imageNamed: "buttonLeft.png")
    var player = SKSpriteNode(imageNamed: "player.png")
    var buttonRight = SKSpriteNode(imageNamed: "buttonRight.png")
    var shootButton = SKSpriteNode(imageNamed: "shootButton.png")
    var meleeButton = SKSpriteNode(imageNamed: "meleeReady.png")
    var pauseButton = SKSpriteNode(imageNamed: "pausedButton")
    var healthBarFill = SKSpriteNode(imageNamed: "healthBarfill.png")
    let healthBarFrame = SKSpriteNode(imageNamed: "healthBarFrame.png")
    var ammoBox = SKSpriteNode(imageNamed: "ammobox.png")
    var wall = SKSpriteNode(imageNamed: "wall3.png")
    var reloadButton = SKSpriteNode(imageNamed: "reload_button.png")
    var goldCoinIcon = SKSpriteNode(imageNamed: "goldCoin.png")
    
    var Darken = SKShapeNode(rectOf: CGSize(width:10000, height:10000))

    let pauseLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
    let resumeLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
    var totalAmmoLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var activeAmmoLabel = SKLabelNode(fontNamed: "Menlo-bold")
    var scoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var ShopLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
    var restartLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
    var hordeLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
    let reloadingLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var highScoreLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
    var roundLabel = SKLabelNode(fontNamed: "Superclarendon Black")
    var coinLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    
    var SpawnTimer = Timer()
    var shootDelay = Timer()
    var attackTimer = Timer()
    var pickupTimer = Timer()
    var meleeTimer = Timer()
    var hordeTimer = Timer()
    var reloadTimer = Timer()

    var playerLeft = false
    var playerRight = false
    var shooting = false
    var gameover = false
    var gamePaused = false
    var healthGone = false
    var allClear = false
    var meleeAvailable = true
    var reloading = false

    var scoreNumber = 0
    var highScore = 0
    var totalAmmoNumber = 1000
    var activeAmmoNumber = 60
    var playerHealth = 100
    var hitNumber = 0
    var RandomZombieSpawnTime = TimeInterval(arc4random_uniform(5)+2)
    var RandomPickup = 0
    var wallInt = 0
    var vomitPosInt = 0
    var RoundNumber = 1
    var roundTracker = 0
    var spawnInterval = 5.0
    var coinNumber = 0
    var currentCoins = 0

    var pickUps = Array<SKSpriteNode>()
    var zombies = Array<Zombie>()
    var vomits = Array<Vomit>()
    
override func didMove(to view: SKView) {
    //set up loading screen
        GameInstance = self
        physicsWorld.contactDelegate = self
        
        let loadingLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
        loadingLabel.text = "Loading..."
        loadingLabel.fontColor = SKColor.white
        loadingLabel.fontSize = 50
        loadingLabel.zPosition = 1
        loadingLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        self.addChild(loadingLabel)
        
        let background = SKSpriteNode(imageNamed: "background.png")
        background.size = CGSize(width:self.frame.size.width, height:self.frame.size.height)
        background.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
   let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
       
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
        //present view after it loads
        loadingLabel.removeFromParent()
       
        let DarkenScene = SKShapeNode(rectOf: CGSize(width:10000, height:10000))
        DarkenScene.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        DarkenScene.zPosition = 5
        DarkenScene.alpha = 1
        DarkenScene.fillColor = SKColor.black
        self.addChild(DarkenScene)
        
        let removeDarken = SKAction.fadeOut(withDuration: 1.2)
        DarkenScene.run(removeDarken)
       
            
            self.SpawnTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.spawnInterval), target:self, selector: #selector(Main_Scene.spawnZombie), userInfo: nil, repeats: true)
            
            //used for automatic weapons shootDelay = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("shootGun"), userInfo: nil, repeats: true)
            
            self.attackTimer = Timer.scheduledTimer(timeInterval: 0.9, target:self, selector: #selector(Main_Scene.attack), userInfo: nil, repeats: true)
            
            self.pickupTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(Main_Scene.spawnPickup), userInfo: nil, repeats: true)
            
            self.hordeTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(Main_Scene.spawnZombieHorde), userInfo: nil, repeats: true)
        
            
       self.highScore =  UserDefaults.standard.integer(forKey: "highScoreSaved")
       self.currentCoins = UserDefaults.standard.integer(forKey: "totalCoinsSaved")
     
        NotificationCenter.default.addObserver(self, selector:#selector(Main_Scene.setStayPaused), name: NSNotification.Name(rawValue: "PauseNotification"), object: nil)
        
        self.vomitPosInt = Int(self.frame.size.height*0.7)
        
        //set up all objects in scene
        self.healthBarFrame.size = CGSize(width: 113, height: 74)
        self.healthBarFrame.position = CGPoint(x: self.frame.size.width*0.949, y: self.frame.height*0.835)
        self.healthBarFrame.zPosition = 4
        self.addChild(self.healthBarFrame)
       
        self.healthBarFill.size = CGSize(width: 112, height: 72)
        self.healthBarFill.position = CGPoint(x: self.frame.size.width*0.949, y:self.frame.size.height*0.835)
        self.healthBarFill.zPosition = 3
        self.addChild(self.healthBarFill)
     
        self.wall.size = CGSize(width: 1050, height: 35)
        self.wall.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.3+100)
        self.wall.zPosition = 1
        self.wall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1050, height: 35))
        self.wall.physicsBody?.affectedByGravity = false
        self.wall.physicsBody?.categoryBitMask = physicsCategory.wall
        self.wall.physicsBody?.contactTestBitMask = physicsCategory.vomit
        self.wall.physicsBody?.collisionBitMask = physicsCategory.None
  
        self.player.size = CGSize(width: 100, height: 134)
        self.player.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.17+120)
        self.player.zPosition = 3

        self.totalAmmoLabel.text = "\(self.totalAmmoNumber)"
        self.totalAmmoLabel.fontSize = 30
        self.totalAmmoLabel.fontColor = SKColor.gray
        self.totalAmmoLabel.position = CGPoint(x: self.frame.size.width*0.855, y: self.frame.size.height*0.82)
        self.totalAmmoLabel.zPosition = 4
        self.totalAmmoLabel.alpha = 0.8
   
        self.activeAmmoLabel.text = "\(self.activeAmmoNumber)"
        self.activeAmmoLabel.fontSize = 30
        self.activeAmmoLabel.position = CGPoint(x: self.frame.size.width*0.795, y: self.frame.size.height*0.82)
        self.activeAmmoLabel.zPosition = 4
            
        self.reloadingLabel.text = "Reloading"
        self.reloadingLabel.fontSize = 30
        self.reloadingLabel.position = CGPoint(x: self.frame.size.width*0.8, y: self.frame.size.height*0.783)
        self.reloadingLabel.fontColor = SKColor.white
        self.reloadingLabel.zPosition = 4
       
        self.scoreLabel.text = "Score: \(self.scoreNumber)"
        self.scoreLabel.fontSize = 30
        self.scoreLabel.fontColor = SKColor.white
        self.scoreLabel.position = CGPoint(x: self.frame.size.width*0.18, y: self.frame.size.height*0.82)
        self.scoreLabel.zPosition = 4
            
        self.coinLabel.text = "\(self.coinNumber)"
        self.coinLabel.fontSize = 30
        self.coinLabel.fontColor = SKColor.white
        self.coinLabel.position = CGPoint(x: self.frame.size.width*0.35, y: self.frame.size.height*0.82)
        self.coinLabel.zPosition = 4
            
        self.goldCoinIcon.size = CGSize(width: 30, height: 30)
        self.goldCoinIcon.position = CGPoint(x: self.coinLabel.position.x - 40, y: self.coinLabel.position.y + 12)
        self.goldCoinIcon.zPosition = 4
        
        self.buttonLeft.size =  CGSize(width: 130, height: 100)
        self.buttonLeft.position = CGPoint(x: self.frame.size.width*0.1, y: self.frame.size.height*0.20)
        self.buttonLeft.zPosition = 4
    
        self.buttonRight.size =  CGSize(width: 130, height: 100)
        self.buttonRight.position = CGPoint(x: self.frame.size.width*0.25, y: self.frame.size.height*0.20)
        self.buttonRight.zPosition = 4
            
        self.roundLabel.text = "\(self.RoundNumber)"
        self.roundLabel.fontColor = SKColor.init(red: 0.5, green: 0, blue: 0, alpha: 1.0)
        self.roundLabel.fontSize = 70
        self.roundLabel.position = CGPoint(x: self.frame.size.width*0.06, y: self.frame.size.height*0.3)
        self.roundLabel.zPosition = 4
        self.addChild(self.roundLabel)
        
        self.shootButton.size = CGSize(width: 110, height: 120)
        self.shootButton.position = CGPoint(x: self.frame.size.width*0.93, y: self.frame.size.height*0.21)
        self.shootButton.zPosition = 4
      
        self.meleeButton.size = CGSize(width: 110, height: 120)
        self.meleeButton.position = CGPoint(x: self.frame.width*0.8, y: self.frame.size.height*0.21)
        self.meleeButton.zPosition = 4
       
        self.pauseButton.size = CGSize(width: 54, height: 60)
        self.pauseButton.position = CGPoint(x: self.frame.size.width*0.05, y: self.frame.size.height*0.82)
        self.pauseButton.zPosition = 4
        
        self.reloadButton.size = CGSize(width: 70, height: 70)
        self.reloadButton.position = CGPoint(x: self.shootButton.position.x, y: self.shootButton.position.y+110)
        self.reloadButton.zPosition = 4
       
           
            //add all objects to the scene
            self.addChild(self.pauseButton)
            self.addChild(self.meleeButton)
            self.addChild(self.shootButton)
            self.addChild(self.buttonRight)
            self.addChild(self.buttonLeft)
            self.addChild(self.scoreLabel)
            self.addChild(self.coinLabel)
            self.addChild(self.goldCoinIcon)
            self.addChild(self.activeAmmoLabel)
            self.addChild(self.totalAmmoLabel)
            self.addChild(self.player)
            self.addChild(self.wall)
            self.addChild(self.reloadButton)
        
       
       }
     
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var contactBody1: SKPhysicsBody
        var contactBody2: SKPhysicsBody
       
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            contactBody1 = contact.bodyA
            contactBody2 = contact.bodyB
        }
        else {
            contactBody1 = contact.bodyB
            contactBody2 = contact.bodyA
        }
        
        if ((contactBody1.categoryBitMask == 2) && (contactBody2.categoryBitMask == 7)){
             //zombie and melee
             if let zombieNode = contactBody1.node! as? Zombie {
                zombieNode.die()
            }
        }

        
        if ((contactBody1.categoryBitMask == 1) && (contactBody2.categoryBitMask == 2)){
            //bullet and zombie
            contactBody1.node!.removeFromParent()
            if let zombieNode = contactBody2.node! as? Zombie {
                if (zombieNode.health == 0){
                    zombieNode.die()
                }
                else{
                    zombieNode.reduceHealth()
                }
            }
        }

if ((contactBody1.categoryBitMask == 13) && (contactBody2.categoryBitMask == 16)){
    //vomit and the wall
            playerHealth -= 1
            healthBarFill.position.x = healthBarFill.position.x + 1.0
            let vomitHitAtlas = SKTextureAtlas(named: "vomitAnimation.atlas")
            var vomitHitArray = Array<SKTexture>();
            
            vomitHitArray.append(vomitHitAtlas.textureNamed("fireball_hit_0001"))
            vomitHitArray.append(vomitHitAtlas.textureNamed("fireball_hit_0002"))
            vomitHitArray.append(vomitHitAtlas.textureNamed("fireball_hit_0003"))
            vomitHitArray.append(vomitHitAtlas.textureNamed("fireball_hit_0004"))
            vomitHitArray.append(vomitHitAtlas.textureNamed("fireball_hit_0005"))
            vomitHitArray.append(vomitHitAtlas.textureNamed("fireball_hit_0006"))
            vomitHitArray.append(vomitHitAtlas.textureNamed("fireball_hit_0007"))
            vomitHitArray.append(vomitHitAtlas.textureNamed("fireball_hit_0008"))
            vomitHitArray.append(vomitHitAtlas.textureNamed("fireball_hit_0009"))
            
        let animateHit = SKAction.animate(with: vomitHitArray, timePerFrame: 0.05)
            contactBody1.node!.run(animateHit, completion: {() in
                let fadeOut = SKAction.fadeOut(withDuration: 3)
                contactBody1.node!.run(fadeOut)
            })
            
            
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            
            if buttonLeft.contains(location) && gamePaused == false && gameover == false{
              playerLeft = true
            }
            if buttonRight.contains(location) && gamePaused == false && gameover == false{
                playerRight = true
            }
            if shootButton.contains(location)  && gamePaused == false && gameover == false && reloading == false{
                shooting = true
                shootGun()
            }
            if meleeButton.contains(location) && gamePaused == false && gameover == false{
                meleeAttack()
            }
            if reloadButton.contains(location) && gamePaused == false && gameover == false && activeAmmoNumber != 60 && reloading == false{
                reloading = true
                self.addChild(reloadingLabel)
                let waitForReload = SKAction.wait(forDuration: 2)
                let reloadSound = SKAction.playSoundFileNamed("reload.mp3", waitForCompletion: true)
                run(reloadSound)
                run(waitForReload, completion: {() in
                    self.activeAmmoNumber = 60
                    self.reloading = false
                    self.reloadingLabel.removeFromParent()
                })
            }
            if touchedNode.name == "healthPack"{
                
                let healthpackAnimation = SKAction.move(to: CGPoint(x: healthBarFill.position.x, y: healthBarFill.position.y), duration: 0.5)
                touchedNode.run(healthpackAnimation, completion: {() in
                
                    self.playerHealth = self.playerHealth + 25
                    touchedNode.removeFromParent()
                    self.healthBarFill.position.x = self.healthBarFill.position.x-25
                    if self.healthBarFill.position.x < self.frame.size.width*0.949{
                        self.healthBarFill.position.x = self.frame.size.width*0.949
                    }
                    if self.playerHealth > 100{
                        self.playerHealth = 100
                    }
                
                })
                
                
              
                
            }
            if touchedNode.name == "ammoBox"{
                
                let ammoAnimation = SKAction.move(to: CGPoint(x: totalAmmoLabel.position.x, y: totalAmmoLabel.position.y), duration: 0.5)
                touchedNode.run(ammoAnimation, completion: {() in
                
                self.totalAmmoNumber = self.totalAmmoNumber + 200
                touchedNode.removeFromParent()
                
                })
            }
            
            if pauseButton.contains(location) && gamePaused == false && gameover == false{
                pauseButton.removeFromParent()
                gamePaused = true
                self.isPaused = true
                SpawnTimer.invalidate()
                pickupTimer.invalidate()
                hordeTimer.invalidate()
                pauseLabel.text = "PAUSED"
                pauseLabel.fontSize = 100
                pauseLabel.fontColor = SKColor.white
                pauseLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
                pauseLabel.zPosition = 6
                self.addChild(pauseLabel)
                
                resumeLabel.text = "(touch to resume)"
                resumeLabel.fontSize = 40
                resumeLabel.fontColor = SKColor.white
                resumeLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.4)
                resumeLabel.zPosition = 6
                self.addChild(resumeLabel)
                
                Darken.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
                Darken.zPosition = 5
                Darken.alpha = 0.5
                Darken.fillColor = SKColor.black
                self.addChild(Darken)
            
                }
           if (resumeLabel.contains(location) || pauseLabel.contains(location)) && gamePaused == true{
            
               self.isPaused = false
               gamePaused = false
               SpawnTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.spawnInterval), target:self, selector: #selector(Main_Scene.spawnZombie), userInfo: nil, repeats: true)
               pickupTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(Main_Scene.spawnPickup), userInfo: nil, repeats: true)
            
                hordeTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(Main_Scene.spawnZombieHorde), userInfo: nil, repeats: true)

               resumeLabel.removeFromParent()
               pauseLabel.removeFromParent()
               Darken.removeFromParent()
                self.addChild(pauseButton)
            
            }
        
        if allClear{
            let reveal = SKTransition.fade(withDuration: 1)
            
            if restartLabel.contains(location){
            let scene2 = Main_Scene(size: self.size)
            scene2.scaleMode = scaleMode
            self.view?.presentScene(scene2, transition: reveal)
            }
            if ShopLabel.contains(location){
                let scene3 = Game_Shop(size:self.size)
                scene3.scaleMode = scaleMode
                self.view?.presentScene(scene3, transition: reveal)
            }
        }
    }
}
        override func update(_ currentTime: TimeInterval) {
     //print(roundTracker)
         
            if meleeAvailable{
          self.meleeButton.texture = SKTexture(imageNamed: "meleeReady.png")
            }
            
            if allClear{
                let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.4)
                ShopLabel.run(fadeIn)
                restartLabel.run(fadeIn)
            }
           
    
        totalAmmoLabel.text = "\(totalAmmoNumber)"
        activeAmmoLabel.text = "\(activeAmmoNumber)"
        scoreLabel.text = "Score: \(scoreNumber)"
        coinLabel.text = "\(coinNumber)"
            
            if activeAmmoNumber == 0 && reloading == false{
            
                reloading = true
                reloadTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(Main_Scene.doneReloading), userInfo: nil, repeats: false)
                self.addChild(reloadingLabel)
                let reloadingSound = SKAction.playSoundFileNamed("reload.mp3", waitForCompletion: false)
                run(reloadingSound)
                
            }
            
     //   RandomZombieSpawnTime  =  NSTimeInterval(arc4random_uniform(3)+1)
        
        if (player.position.x > self.frame.size.width - 50){
            player.position = CGPoint(x: self.frame.size.width - 50, y: player.position.y)
        }
        if (player.position.x < self.frame.size.width*0.0 + 50){
            player.position = CGPoint(x: self.frame.size.width*0.0 + 50, y: player.position.y)
        }
        
        if (playerLeft == true){
            let movePlayerLeft = SKAction.moveBy(x: -5, y: 0, duration: 0.1)
            player.run(movePlayerLeft)
            let playerLeftTexture = SKTexture(imageNamed: "playerLeftSide.png")
            player.texture = playerLeftTexture
            player.size = CGSize(width: 71, height: 115)
        }
        if (playerRight == true){
            let movePlayerRight = SKAction.moveBy(x: 5, y: 0, duration: 0.1)
            player.run(movePlayerRight)
            let playerRightTexture = SKTexture(imageNamed: "playerRightSide.png")
            player.texture = playerRightTexture
            player.size = CGSize(width: 71, height: 115)
 
        }
      
    }
    
    func shootGun(){
        if (shooting == true  && totalAmmoNumber != 0 && activeAmmoNumber != 0 && reloading == false){
            
           activeAmmoNumber -= 1
            totalAmmoNumber -= 1
          
            let muzzleFlash = SKSpriteNode(imageNamed: "muzzleFlash.png")
            muzzleFlash.position = CGPoint(x: player.position.x, y: player.position.y+60)
            muzzleFlash.size = CGSize(width: 60, height: 60)
            muzzleFlash.zPosition = 2
            self.addChild(muzzleFlash)
            let Show = SKAction.fadeIn(withDuration: 0.01)
            let wait = SKAction.wait(forDuration: 0.1)
            let hide = SKAction.fadeOut(withDuration: 0.01)
            let sequence = SKAction.sequence([Show, wait, hide])
           muzzleFlash.run(sequence, completion: {() in
            muzzleFlash.removeFromParent()
            })
          let bullet = SKSpriteNode(imageNamed: "bullet.png")
            bullet.position = CGPoint(x: muzzleFlash.position.x, y: muzzleFlash.position.y)
            bullet.size = CGSize(width: 3, height: 7)
            bullet.zPosition = 2
            bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 3, height: 7))
            bullet.physicsBody?.affectedByGravity = false
            bullet.physicsBody?.categoryBitMask = physicsCategory.Bullet
            bullet.physicsBody?.contactTestBitMask = physicsCategory.Zombie | physicsCategory.HealthBar
            bullet.physicsBody?.collisionBitMask = physicsCategory.None
            self.addChild(bullet)
            
            let moveBullet = SKAction.moveTo(y: 1000, duration: 0.7)
            let playShootSound = SKAction.playSoundFileNamed("gunshot.wav", waitForCompletion: false)
            
            run(playShootSound)
            
       /* let bullet2 = SKShapeNode(rectOfSize: bullet.size, cornerRadius: 0)
            bullet2.fillColor = SKColor.redColor()
            bullet2.strokeColor = SKColor.redColor()
            bullet2.position = CGPoint(x: muzzleFlash.position.x, y: muzzleFlash.position.y)
            bullet2.zPosition = 2
            self.addChild(bullet2) */
            
            bullet.run(moveBullet, completion: {() in
              bullet.removeFromParent()
            })
           if (totalAmmoNumber <= 0){
                totalAmmoNumber = 0
            }
            if (activeAmmoNumber <= 0){
                activeAmmoNumber = 0
            }
        }
    }
    func meleeAttack(){
       
        if meleeAvailable{
            
        meleeAvailable = false
            let MeleeAnimation = SKTextureAtlas(named: "meleeButtonAnimation.atlas")
            var MeleeButtonArray = Array<SKTexture>();
            
            MeleeButtonArray.append(MeleeAnimation.textureNamed("meleeButton"))
            MeleeButtonArray.append(MeleeAnimation.textureNamed("meleeAnimation6"))
            MeleeButtonArray.append(MeleeAnimation.textureNamed("meleeAnimation5"))
            MeleeButtonArray.append(MeleeAnimation.textureNamed("meleeAnimation4"))
            MeleeButtonArray.append(MeleeAnimation.textureNamed("meleeAnimation3"))
            MeleeButtonArray.append(MeleeAnimation.textureNamed("meleeAnimation2"))
    
        
            let animateMeleeButton = SKAction.animate(with: MeleeButtonArray, timePerFrame: 2)
            meleeButton.run(animateMeleeButton, completion: {() in
                self.meleeButton.texture = SKTexture(imageNamed: "meleeReady.png")
                self.meleeAvailable = true
            })
            
            
        let meleeSound = SKAction.playSoundFileNamed("melee.mp3", waitForCompletion: true)
        let meleeWeapon = SKSpriteNode(imageNamed: "Sword 001.png")
        meleeWeapon.position = CGPoint(x: player.position.x, y: player.position.y+15)
        meleeWeapon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        meleeWeapon.size = CGSize(width: 60, height: 60)
        meleeWeapon.zPosition = 2
        meleeWeapon.zRotation = 0.01
        meleeWeapon.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 100))
        meleeWeapon.physicsBody?.affectedByGravity = false
        meleeWeapon.physicsBody?.categoryBitMask = physicsCategory.melee
        meleeWeapon.physicsBody?.contactTestBitMask = physicsCategory.Zombie | physicsCategory.HealthBar
        meleeWeapon.physicsBody?.collisionBitMask = physicsCategory.None
        self.addChild(meleeWeapon)
        run(meleeSound)
        let rotateWeapon = SKAction.rotate(byAngle: CGFloat(-M_PI*2.0), duration: 0.5)
        let rotateForever = SKAction.repeatForever(rotateWeapon)
        let moveForward = SKAction.moveTo(y: 1000, duration: 2)
        meleeWeapon.run(rotateForever)
        meleeWeapon.run(moveForward, completion: {() in
            meleeWeapon.removeFromParent()
        })
    
        }
        
    }
    func renewMelee(){
        meleeAvailable = true
    }
    
    func spawnZombie(){
   
        let randomPosition = CGFloat(arc4random_uniform(900))+50
        let randomZombie = Int(arc4random_uniform(10))
        
        var newZombie: Zombie?
        
        wallInt = Int(wall.position.y+60)
        
        if (randomZombie == 0){
            newZombie = fatZombie(xPos: randomPosition)
            
            self.addChild(newZombie!)
        }
        else if (randomZombie == 1){
            newZombie = vomitZombie(xPos: randomPosition)
            self.addChild(newZombie!)
            self.addChild((newZombie?.healthNode)!)
            newZombie?.walkDownTo(Ypos: CGFloat(vomitPosInt))
        }
        else{
            newZombie = Zombie(xPos: randomPosition)
            self.addChild(newZombie!)
            self.addChild((newZombie?.healthNode)!)
            newZombie?.walkDownTo(Ypos: CGFloat(wallInt))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerLeft = false
        playerRight = false
        shooting = false
        
        let playerForwardTexture = SKTexture(imageNamed: "player.png")
        player.texture = playerForwardTexture
        player.size = CGSize(width: 100, height: 134)
    }
    func attack(){
       
        if self.isPaused == false && gameover == false{
        playerHealth = playerHealth - 2 * hitNumber
             healthBarFill.position = CGPoint(x: healthBarFill.position.x+CGFloat(2 * hitNumber), y: healthBarFill.position.y)
       //     let moveHealthBy = CGFloat(hitNumber)*1.44
          //  let HealthHit = SKAction.moveByX(moveHealthBy, y: 0, duration: 0.1)
          //  healthBarFill.runAction(HealthHit)
        }
        
 
        if (playerHealth <= 0){
           playerHealth = 0
        gameover = true
        gameOver()
            
        }
    }
    func gameOver(){
        
        let gameoverSound = SKAction.playSoundFileNamed("gameOver.mp3", waitForCompletion: false)
 

        let GameOverLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
        GameOverLabel.text = "Game Over"
        GameOverLabel.fontSize = 100
        GameOverLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        GameOverLabel.zPosition = 6
        GameOverLabel.fontColor = UIColor.white
        GameOverLabel.alpha = 0
        self.addChild(GameOverLabel)
        run(gameoverSound)
        
        let finalScoreLabel = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
        finalScoreLabel.text = "Score: \(scoreNumber)"
        finalScoreLabel.fontSize = 50
        finalScoreLabel.position = CGPoint(x: GameOverLabel.position.x, y: GameOverLabel.position.y-100)
        finalScoreLabel.zPosition = 6
        finalScoreLabel.fontColor = UIColor.white
        finalScoreLabel.alpha = 0
        self.addChild(finalScoreLabel)
        
        restartLabel.text = "Restart"
        restartLabel.fontColor = UIColor.white
        restartLabel.position = CGPoint(x: self.frame.width*0.88, y: self.frame.height*0.8)
        restartLabel.zPosition = 6
        restartLabel.fontSize = 60
        restartLabel.alpha = 0
        self.addChild(restartLabel)
        
        ShopLabel.text = "Shop"
        ShopLabel.fontSize = 60
        ShopLabel.position = CGPoint(x: self.frame.width*0.08, y: self.frame.height*0.8)
        ShopLabel.zPosition = 6
        ShopLabel.fontColor = UIColor.white
        ShopLabel.alpha = 0
        self.addChild(ShopLabel)
        
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.5)
        
        let fadeOut = SKAction.fadeAlpha(to: 0, duration:0.5)
        
        
        GameOverLabel.run(fadeIn)
        finalScoreLabel.run(fadeIn)
        roundLabel.run(fadeOut)
        healthBarFill.run(fadeOut)
        healthBarFrame.run(fadeOut)
        totalAmmoLabel.run(fadeOut)
        activeAmmoLabel.run(fadeOut)
        reloadingLabel.run(fadeOut)
        reloadButton.run(fadeOut)
        meleeButton.run(fadeOut)
        shootButton.run(fadeOut)
        buttonLeft.run(fadeOut)
        buttonRight.run(fadeOut)
        coinLabel.run(fadeOut)
        goldCoinIcon.run(fadeOut)
        wall.removeFromParent()
        pauseButton.removeFromParent()
        scoreLabel.removeFromParent()
        
        SpawnTimer.invalidate()
        attackTimer.invalidate()
        pickupTimer.invalidate()
        hordeTimer.invalidate()
        
        let moveZombieForward = SKAction.moveTo(y: -100, duration: 8)
        let movePlayerForward = SKAction.moveTo(y: -100, duration: 6) 
        player.run(movePlayerForward)
        for zombie in zombies{
            zombie.removeAllActions()
           zombie.run(moveZombieForward)
            if zombie.name == "zombie"{
                let zombieTextureAtlas = SKTextureAtlas(named: "zombie.atlas")
                var spriteArray = Array<SKTexture>();
                
                spriteArray.append(zombieTextureAtlas.textureNamed("zombie.png"))
                spriteArray.append(zombieTextureAtlas.textureNamed("zombieWalk1.png"))
                spriteArray.append(zombieTextureAtlas.textureNamed("zombie.png"))
                spriteArray.append(zombieTextureAtlas.textureNamed("zombieWalk2.png"))
                
                let move = SKAction.animate(with: spriteArray, timePerFrame: 0.45)
                let repeatMove = SKAction.repeatForever(move)
                zombie.run(repeatMove)
            }
            if zombie.name == "vomit zombie"{
                let vomitZombieTextureAtlas = SKTextureAtlas(named: "vomitZombieMove.atlas")
                var vomitZombieArray = Array<SKTexture>();
                
                vomitZombieArray.append(vomitZombieTextureAtlas.textureNamed("vomit_move_0001.png"))
                vomitZombieArray.append(vomitZombieTextureAtlas.textureNamed("vomit_move_0002.png"))
                vomitZombieArray.append(vomitZombieTextureAtlas.textureNamed("vomit_move_0003.png"))
                vomitZombieArray.append(vomitZombieTextureAtlas.textureNamed("vomit_move_0004.png"))
                let move = SKAction.animate(with: vomitZombieArray, timePerFrame: 0.45)
                let repeatMove = SKAction.repeatForever(move)
                zombie.run(repeatMove)
            }
            if zombie.name == "fat zombie"{
                let fatZombieTextureAtlas = SKTextureAtlas(named:"FatZombie.atlas")
                var fatZombieMoveArray = Array<SKTexture>();
                
                fatZombieMoveArray.append(fatZombieTextureAtlas.textureNamed("fasto_move_0001.png"))
                fatZombieMoveArray.append(fatZombieTextureAtlas.textureNamed("fasto_move_0002.png"))
                fatZombieMoveArray.append(fatZombieTextureAtlas.textureNamed("fasto_move_0003.png"))
                fatZombieMoveArray.append(fatZombieTextureAtlas.textureNamed("fasto_move_0004.png"))
                let move = SKAction.animate(with: fatZombieMoveArray, timePerFrame: 0.45)
                let repeatMove = SKAction.repeatForever(move)
                zombie.run(repeatMove)
            }
        }
        for pickUp in pickUps{
            pickUp.removeFromParent()
        }
        for vomit in vomits{
            vomit.removeFromParent()
        }
        if scoreNumber > highScore {
            highScore = scoreNumber
            UserDefaults.standard.set(highScore, forKey: "highScoreSaved")
            highScoreLabel.text = "New High Score: \(highScore)"
            highScoreLabel.color = SKColor.white
            highScoreLabel.fontSize = 30
            highScoreLabel.position = CGPoint(x: finalScoreLabel.position.x, y: finalScoreLabel.position.y-50)
            highScoreLabel.zPosition = finalScoreLabel.zPosition
            self.addChild(highScoreLabel)
        }
        else{
            highScoreLabel.text = "High Score: \(highScore)"
            highScoreLabel.color = SKColor.white
            highScoreLabel.fontSize = 30
            highScoreLabel.position = CGPoint(x: finalScoreLabel.position.x, y: finalScoreLabel.position.y-50)
            highScoreLabel.zPosition = finalScoreLabel.zPosition
            self.addChild(highScoreLabel)
        }
    
      UserDefaults.standard.set(coinNumber+currentCoins, forKey: "totalCoinsSaved")
    
    }

    var stayPaused = false as Bool
    
    override var isPaused: Bool {
        get {
            return super.isPaused
        }
        set {
            if (!stayPaused) {
                super.isPaused = newValue
            }
            stayPaused = false
        }
       
    }
    
    func setStayPaused() {
        if (super.isPaused) && gameover == false {
            self.stayPaused = true
            if gamePaused == false && gameover == false{
            pauseButton.removeFromParent()
            gamePaused = true
            pickupTimer.invalidate()
            SpawnTimer.invalidate()
            hordeTimer.invalidate()
            pauseLabel.text = "PAUSED"
            pauseLabel.fontSize = 100
            pauseLabel.fontColor = SKColor.white
            pauseLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
            pauseLabel.zPosition = 6
            self.addChild(pauseLabel)
            
            resumeLabel.text = "(touch to resume)"
            resumeLabel.fontSize = 40
            resumeLabel.fontColor = SKColor.white
            resumeLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.4)
            resumeLabel.zPosition = 6
            self.addChild(resumeLabel)
                
                Darken.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
                Darken.zPosition = 5
                Darken.alpha = 0.5
                Darken.fillColor = SKColor.black
                self.addChild(Darken)
                
            }

        }
    }
    func criticalHit(_ zombiePosition:CGPoint){
        let wait = SKAction.wait(forDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        
       let criticalMultiplier = SKSpriteNode(imageNamed: "bonusmultiplierx5.png")
        criticalMultiplier.position = CGPoint(x: zombiePosition.x, y: zombiePosition.y)
        criticalMultiplier.zPosition = 3
        criticalMultiplier.size = CGSize(width: 36, height: 22)
        addChild(criticalMultiplier)
        

        let criticalPoints = SKSpriteNode(imageNamed: "Points50.png")
        criticalPoints.position = CGPoint(x: zombiePosition.x, y: zombiePosition.y+30)
        criticalPoints.zPosition = 3
        criticalPoints.size = CGSize(width: 51, height: 36)
        addChild(criticalPoints)
        
        criticalPoints.run(wait, completion: {() in
            criticalMultiplier.run(fadeOut)
            criticalPoints.run(fadeOut)        })

        let animateup = SKAction.moveTo(y: zombiePosition.y + 60, duration: 0.5)
        criticalPoints.run(animateup)
        
        let animateup2 = SKAction.moveTo(y: zombiePosition.y+30, duration: 0.5)
        criticalMultiplier.run(animateup2)
       
        
    }
    func regularHit(_ zombiePosition: CGPoint){
        let Points = SKSpriteNode(imageNamed: "Points10.png")
        Points.position = zombiePosition
        Points.zPosition = 3
        Points.size = CGSize(width: 40, height: 36)
        addChild(Points)
        let animateup = SKAction.moveTo(y: zombiePosition.y + 30, duration: 0.5)
        Points.run(animateup)
        let wait = SKAction.wait(forDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        Points.run(wait, completion: {() in
           Points.run(fadeOut)        })
    }
    func spawnPickup(){
        RandomPickup = Int(arc4random_uniform(20))
        
        let randomPositionX = CGFloat(arc4random_uniform(660))+10
        let randomPositionY = CGFloat(arc4random_uniform(195))+400
        
        if RandomPickup == 1{
            //spawn healthpack
        let healthPack = SKSpriteNode(imageNamed: "HealthPack.png")
        healthPack.position = CGPoint(x: randomPositionX, y: randomPositionY)
        healthPack.zPosition = 2
        healthPack.name = "healthPack"
        healthPack.size = CGSize(width: 50, height: 50)
        addChild(healthPack)
            pickUps.append(healthPack)
       }
        if RandomPickup == 2{
            //spawn ammo
            let ammoBox = SKSpriteNode(imageNamed: "ammobox.png")
            ammoBox.position = CGPoint(x: randomPositionX, y: randomPositionY)
            ammoBox.zPosition = 2
            ammoBox.name = "ammoBox"
            ammoBox.size = CGSize(width: 64, height: 64)
            addChild(ammoBox)
            pickUps.append(ammoBox)
        }
        else{
            return
        }
        
    }
    func spawnZombieHorde(){
        
    if RoundNumber >= 5{
    
        hordeLabel.text = "Horde Approaching!"
        hordeLabel.color = SKColor.white
        hordeLabel.fontSize = 60
        hordeLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height*0.6)
        hordeLabel.zPosition = 4
        self.addChild(hordeLabel)
        
        let wait = SKAction.wait(forDuration: 2)
        
        hordeLabel.run(wait, completion: {() in
        self.hordeLabel.removeFromParent()
        })
        
        spawnZombie()
        spawnZombie()
        spawnZombie()
        spawnZombie()
        spawnZombie()
        spawnZombie()
    
        }

    }
    func doneReloading(){
    
    reloadTimer.invalidate()
    activeAmmoNumber = 60
    reloadingLabel.removeFromParent()
    reloading = false
      
    }
    func changeRound(){
        SpawnTimer.invalidate()
        
        let wait = SKAction.wait(forDuration: 3)
        
        run(wait, completion: {() in
        self.SpawnTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.spawnInterval), target:self, selector: #selector(Main_Scene.spawnZombie), userInfo: nil, repeats: true)
    
       
        let newLevelSound = SKAction.playSoundFileNamed("NewLevelSound.mp3", waitForCompletion: true)
        self.run(newLevelSound)
        
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 1)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 1)
        let fadeSequence = SKAction.sequence([fadeOut, fadeIn])
        
        self.roundLabel.run(fadeSequence)
        
        let wait2 = SKAction.wait(forDuration: 1)
        self.run(wait2, completion: {() in
            self.roundLabel.text = "\(self.RoundNumber)"
        })
        })
        
    }
    
}
