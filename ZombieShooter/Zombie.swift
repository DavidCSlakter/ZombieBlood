//
//  Zombie.swift
//  Zombie Blood
//
//  Created by David Slakter on 5/15/18.
//  Copyright © 2018 Swap. All rights reserved.
//

import Foundation
import SpriteKit


class Zombie: SKSpriteNode {
    private let TextureAtlas = SKTextureAtlas(named: "zombie.atlas")
    private let FightAtlas = SKTextureAtlas(named: "zombieFight.atlas")
    private let deathAtlas = SKTextureAtlas(named: "zombieDie.atlas")
    var moveAnimations = Array<SKTexture>();
    var attackAnimations = Array<SKTexture>();
    var deathAnimations = Array<SKTexture>();
    var healthNode = healthBar()
    var health = 100
    var xPosition: CGFloat!
    
    
    func addAnimations(){
        moveAnimations.append(TextureAtlas.textureNamed("zombie.png"))
        moveAnimations.append(TextureAtlas.textureNamed("zombieWalk1.png"))
        moveAnimations.append(TextureAtlas.textureNamed("zombie.png"))
        moveAnimations.append(TextureAtlas.textureNamed("zombieWalk2.png"))
        
        attackAnimations.append(FightAtlas.textureNamed("zombie.png"))
        attackAnimations.append(FightAtlas.textureNamed("zombieAttack1.png"))
        attackAnimations.append(FightAtlas.textureNamed("zombieAttack2.png"))
        
        deathAnimations.append(deathAtlas.textureNamed("splatter1.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter2.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter3.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter4.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter5.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter6.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter7.png"))
    }
    func setupNode(){
        position = CGPoint(x: xPosition, y: GameInstance!.frame.size.height*0.9+100)
        zPosition = 2
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 25))
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = physicsCategory.Zombie
        physicsBody?.collisionBitMask = physicsCategory.None
        physicsBody?.contactTestBitMask = physicsCategory.Bullet | physicsCategory.melee
    }

    public init(xPos: CGFloat) {
        let texture = TextureAtlas.textureNamed("zombie.png")
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 94, height: 94))
        healthNode.zombie = self
        xPosition = xPos;
        addAnimations()
        setupNode()
        healthNode.position = CGPoint(x: position.x, y: position.y+50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func walkDownTo(Ypos: CGFloat) {
        let zombieWalk = SKAction.animate(with: moveAnimations, timePerFrame: 0.3)
        let moveDown = SKAction.move(to: CGPoint(x: position.x, y: CGFloat(Ypos)), duration: 6)
        let repeatWalk = SKAction.repeat(zombieWalk, count: 5)
        
        let moveHealthBarDown = SKAction.move(to: CGPoint(x: position.x, y: Ypos+50.0), duration: 6)
        
        healthNode.run(moveHealthBarDown)
        
        self.run(repeatWalk)
        self.run(moveDown, completion: {() in
            self.attack()
        })
    }
    func attack(){
        
        let attack = SKAction.animate(with: attackAnimations, timePerFrame: 0.3)
        //let waitForNextAttack = SKAction.waitForDuration(3)
        //let attackSequence = SKAction.sequence([attack])
        let repeatAttack = SKAction.repeatForever(attack)
        
        self.run(repeatAttack)
    }
    
    func reduceHealth(){
        health -= 20
        healthNode.bumpHealthLower()
    }
    
    func die(){
        let zombieDie = SKAction.animate(with: deathAnimations, timePerFrame: 0.06)
        let waitAction = SKAction.wait(forDuration: 8)
        let fadeAction = SKAction.fadeOut(withDuration: 1)
        let removeAction = SKAction.removeFromParent()
        let dieSequence = SKAction.sequence([zombieDie, waitAction, fadeAction, removeAction])
        let zombieDeathSound = SKAction.playSoundFileNamed("zombieDeath.mp3", waitForCompletion: false)
        self.removeAllActions()
        healthNode.removeFromParent()
        physicsBody = nil
        self.run(dieSequence)
        self.run(zombieDeathSound)
    }
    
    
    class healthBar: SKSpriteNode{
        private var healthBars = Array<SKTexture>();
        weak var zombie: Zombie! = nil
        var textureIndex = 0
        
        func addHealthBars(){
            healthBars.append(SKTexture(imageNamed: "healthBar1.png"))
            healthBars.append(SKTexture(imageNamed: "healthBar2.png"))
            healthBars.append(SKTexture(imageNamed: "healthBar3.png"))
            healthBars.append(SKTexture(imageNamed: "healthBar4.png"))
            healthBars.append(SKTexture(imageNamed: "healthBar5.png"))
            healthBars.append(SKTexture(imageNamed: "healthBar6.png"))
            healthBars.append(SKTexture(imageNamed: "healthBar7.png"))
            healthBars.append(SKTexture(imageNamed: "healthBar8.png"))
            healthBars.append(SKTexture(imageNamed: "healthBar9.png"))
            healthBars.append(SKTexture(imageNamed: "healthBar10.png"))
            healthBars.append(SKTexture(imageNamed: "healthBar11.png"))
            healthBars.append(SKTexture(imageNamed: "healthBar12.png"))
        }
        init() {
            let texture = SKTexture(imageNamed: "healthBar1.png")
            super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 83, height: 9))
            addHealthBars()
            zPosition = 2
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func bumpHealthLower(){
            textureIndex += 2
            self.texture = healthBars[textureIndex]
        }
    }
}

class vomitZombie: Zombie {
    
    private let TextureAtlas = SKTextureAtlas(named: "vomitZombieMove.atlas")
    private let FightAtlas = SKTextureAtlas(named: "vomitZombieAttack.atlas")
    private let deathAtlas = SKTextureAtlas(named: "zombieDie.atlas")
   
   
    override func addAnimations(){
        moveAnimations.append(TextureAtlas.textureNamed("vomit_move_0001.png"))
        moveAnimations.append(TextureAtlas.textureNamed("vomit_move_0002.png"))
        moveAnimations.append(TextureAtlas.textureNamed("vomit_move_0003.png"))
        moveAnimations.append(TextureAtlas.textureNamed("vomit_move_0004.png"))
        
        attackAnimations.append(FightAtlas.textureNamed("vomitAttack1.png"))
        attackAnimations.append(FightAtlas.textureNamed("vomitAttack2.png"))
        attackAnimations.append(FightAtlas.textureNamed("vomitAttack1.png"))
        
        deathAnimations.append(deathAtlas.textureNamed("splatter1.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter2.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter3.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter4.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter5.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter6.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter7.png"))
    }
    

    override func setupNode(){
        texture = moveAnimations[1]
        size = CGSize(width: 94, height: 94)
        position = CGPoint(x: xPosition, y: GameInstance!.frame.size.height*0.9+100)
        zPosition = 2
        
        
        //adding physics body
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 25))
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = physicsCategory.Zombie
        physicsBody?.collisionBitMask = physicsCategory.None
        physicsBody?.contactTestBitMask = physicsCategory.Bullet | physicsCategory.melee
    }
    
    
    public override init (xPos: CGFloat){
        super.init(xPos: xPos)
//        addAnimations()
//        setupNode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack() {
        let attack = SKAction.animate(with: attackAnimations, timePerFrame: 0.3)
        let shootVomitAction = SKAction.run {
            self.shootVomit()
        }
        let attackSequence = SKAction.sequence([attack, shootVomitAction])
        let repeatAttack = SKAction.repeatForever(attackSequence)
        self.run(repeatAttack)
    }
    
    
    func shootVomit(){
        let vomit = Vomit()
        GameInstance?.addChild(vomit)
    }
}

class fatZombie: Zombie {
    private let TextureAtlas = SKTextureAtlas(named:"FatZombie.atlas")
    private let deathAtlas = SKTextureAtlas(named: "zombieDie.atlas")
    
    
    override func addAnimations(){
        moveAnimations.append(TextureAtlas.textureNamed("fasto_move_0001.png"))
        moveAnimations.append(TextureAtlas.textureNamed("fasto_move_0002.png"))
        moveAnimations.append(TextureAtlas.textureNamed("fasto_move_0003.png"))
        moveAnimations.append(TextureAtlas.textureNamed("fasto_move_0004.png"))
        
        deathAnimations.append(deathAtlas.textureNamed("splatter1.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter2.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter3.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter4.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter5.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter6.png"))
        deathAnimations.append(deathAtlas.textureNamed("splatter7.png"))
        
        attackAnimations.append(TextureAtlas.textureNamed("fasto_attack_0001"))
        attackAnimations.append(TextureAtlas.textureNamed("fasto_attack_0002"))
        attackAnimations.append(TextureAtlas.textureNamed("fasto_attack_0001"))
    }
    
    override func setupNode(){
        texture = moveAnimations[1]
        size = CGSize(width: 94, height: 94)
        position = CGPoint(x: xPosition, y: GameInstance!.frame.size.height*0.9+100)
        zPosition = 2
        
        //PB
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 25))
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = physicsCategory.Zombie
        physicsBody?.collisionBitMask = physicsCategory.None
        physicsBody?.contactTestBitMask = physicsCategory.Bullet | physicsCategory.melee
    }
    public override init (xPos: CGFloat){
        super.init(xPos: xPos)
       // addAnimations()
        //setupNode()
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



