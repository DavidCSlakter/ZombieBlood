//
//  Physics.swift
//  Zombie Blood
//
//  Created by David Slakter on 5/16/18.
//  Copyright © 2018 GoLock. All rights reserved.
//

import Foundation


struct physicsCategory{
    static let None: UInt32 = 0 //0
    static let Bullet: UInt32 = 0b1 //1
    static let Zombie: UInt32 = 0b10 //2
    static let HealthBar: UInt32 = 0b100 //4
    static let melee: UInt32 = 0b111 //7
    static let healthPack: UInt32 = 0b1010 //10
    static let vomit: UInt32 = 0b1101 //13
    static let wall: UInt32 = 0b10000 //16
    static let All: UInt32 = UInt32.max
}
