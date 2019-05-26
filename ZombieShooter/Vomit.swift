//
//  Vomit.swift
//  Zombie Blood
//
//  Created by David Slakter on 5/31/18.
//  Copyright © 2018 GoLock. All rights reserved.
//

import Foundation
import SpriteKit

class Vomit: SKSpriteNode{
    private let vomitAtlas = SKTextureAtlas(named: "vomitAnimation.atlas")
    var moveAnimation = Array<SKTexture>();
    var hitAnimation = Array<SKTexture>();
    
    func addAnimations(){
        moveAnimation.append(vomitAtlas.textureNamed("fireball_0001.png"))
        moveAnimation.append(vomitAtlas.textureNamed("fireball_0002.png"))
        moveAnimation.append(vomitAtlas.textureNamed("fireball_0003.png"))
        moveAnimation.append(vomitAtlas.textureNamed("fireball_0004.png"))
        moveAnimation.append(vomitAtlas.textureNamed("fireball_0005.png"))
        moveAnimation.append(vomitAtlas.textureNamed("fireball_0006.png"))
        
        hitAnimation.append(vomitAtlas.textureNamed("fireball_hit_0001.png"))
        hitAnimation.append(vomitAtlas.textureNamed("fireball_hit_0002.png"))
        hitAnimation.append(vomitAtlas.textureNamed("fireball_hit_0003.png"))
        hitAnimation.append(vomitAtlas.textureNamed("fireball_hit_0004.png"))
        hitAnimation.append(vomitAtlas.textureNamed("fireball_hit_0005.png"))
        hitAnimation.append(vomitAtlas.textureNamed("fireball_hit_0006.png"))
        hitAnimation.append(vomitAtlas.textureNamed("fireball_hit_0007.png"))
        hitAnimation.append(vomitAtlas.textureNamed("fireball_hit_0008.png"))
        hitAnimation.append(vomitAtlas.textureNamed("fireball_hit_0009.png"))
    }
    
    init() {
        let texture = SKTexture(imageNamed: "fireball_0001.png")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        addAnimations()
        let moveAction = SKAction.repeatForever(SKAction.animate(with: moveAnimation, timePerFrame: 0.1))
        let moveDown = SKAction.move(by: CGVector(dx: 0, dy: 1), duration: 2)
        self.run(moveAction)
        self.run(moveDown)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func explode(){
        let explodeAction = SKAction.animate(with: hitAnimation, timePerFrame: 0.1)
        self.run(explodeAction)
    }
}
