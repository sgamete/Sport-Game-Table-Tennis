//
//  Tank.swift
//  Tank War Redux
//
//  Created by Keith Davis on 11/3/17.
//  Copyright © 2017 Keith Davis. All rights reserved.
//

import Foundation

class Tank {
    var x:CGFloat
    var y:CGFloat
    var playerTankToward:Toward
    var myClient:TankWarClient
    static let speed:CGFloat = 4
    var isWalk=false
    var isLive=true
    var isGood:Bool
    var tankview:UIView
    var dirTime:Int = 0
    var walkTime:Int = 0
    
    static let paintWidth:CGFloat = 600
    static let paintHeight:CGFloat = 414
    static let image1=UIImage(named: "p1-cell1.png")!
    static let image2=UIImage(named: "p1-cell2.png")!
    static let image3=UIImage(named: "p1-cell3.png")!
    static let image4=UIImage(named: "p1-cell4.png")!
    static let badimage1=UIImage(named: "badtank1.png")!
    static let badimage2=UIImage(named: "badtank2.png")!
    static let badimage3=UIImage(named: "badtank3.png")!
    static let badimage4=UIImage(named: "badtank4.png")!
    static var badTankCount=0

    init(x:CGFloat,y:CGFloat,attribute:Bool,client:TankWarClient,toward:Toward) {
        self.myClient=client
        self.x=x
        self.y=y
        isGood=attribute
        if(!isGood) {
            Tank.badTankCount += 1
            isWalk=true
        }
        
        playerTankToward = toward
        tankview=UIView(frame: CGRect(x: x, y: y, width: 32, height: 32))
        tankview.backgroundColor=UIColor(patternImage: UIImage(named: "p1-cell1.png")!)
    }
    
    func colliedsWithTanks(_ x:CGFloat,y:CGFloat,tanks:[Tank]) -> Bool {
        for i in 0..<tanks.count {
            if(intersects(getRect(x,y: y), r2: tanks[i].getRect())) {
                return false
            }
        }
        return true
    }
    
    func colliedsWithTanks(_ x:CGFloat,y:CGFloat,tanks:[Tank],badi:Int) -> Bool {
        if(intersects(getRect(x,y: y), r2: myClient.myTank.getRect())) {
            return false
        }
        
        for i in 0..<tanks.count {
            if((badi != i )&&intersects(getRect(x,y: y), r2: tanks[i].getRect())) {
                return false
            }
        }
        return true
    }
    
    func colliedsWithWalls(_ x:CGFloat,y:CGFloat,walls:Wall) -> Bool {
        for i in 0..<walls.ws.count {
            if(intersects(getRect(x,y: y), r2: walls.ws[i])) {
                return false
            }
        }
        return true
    }
    
    func colliedsWithBornArea(_ x:CGFloat,y:CGFloat)->Bool {
        return true
    }
    
    func move(_ badi:Int) {
        randombadp()
        if playerTankToward == .up && isWalk==true {
            if(self.y-Tank.speed >= 0 && colliedsWithWalls(self.x,y:(self.y-Tank.speed),walls:self.myClient.walls) && colliedsWithTanks(self.x,y:(self.y-Tank.speed),tanks:self.myClient.tanks,badi:badi)) {
                self.y -= Tank.speed
            }
        } else if playerTankToward == .down && isWalk==true {
            if(self.y+Tank.speed <= Tank.paintHeight-32 && colliedsWithWalls(self.x,y:(self.y+Tank.speed),walls:self.myClient.walls) && colliedsWithTanks(self.x,y:(self.y+Tank.speed),tanks:self.myClient.tanks,badi:badi)) {
                self.y += Tank.speed
            }
        } else if playerTankToward == .left && isWalk==true{
            if(self.x-Tank.speed >= 0 && colliedsWithWalls(self.x-Tank.speed,y:self.y,walls:self.myClient.walls) && colliedsWithTanks(self.x-Tank.speed,y:self.y,tanks:self.myClient.tanks,badi:badi)){
                self.x -= Tank.speed
            }
        } else if playerTankToward == .right && isWalk==true {
            if(self.x+Tank.speed <= Tank.paintWidth-32 && colliedsWithWalls(self.x+Tank.speed,y:self.y,walls:self.myClient.walls) && colliedsWithTanks(self.x+Tank.speed,y:self.y,tanks:self.myClient.tanks,badi:badi)) {
                self.x += Tank.speed
            }
        }
    }
    
    func move() {
        if playerTankToward == .up && isWalk==true {
            if(self.y-Tank.speed >= 0 && colliedsWithWalls(self.x,y:(self.y-Tank.speed),walls:self.myClient.walls) && colliedsWithTanks(self.x,y:(self.y-Tank.speed),tanks:self.myClient.tanks)) {
                self.y -= Tank.speed
            }
        } else if playerTankToward == .down && isWalk==true {
            if(self.y+Tank.speed <= Tank.paintHeight-32 && colliedsWithWalls(self.x,y:(self.y+Tank.speed),walls:self.myClient.walls) && colliedsWithTanks(self.x,y:(self.y+Tank.speed),tanks:self.myClient.tanks)) {
                self.y += Tank.speed
            }
        } else if playerTankToward == .left && isWalk==true {
            if(self.x-Tank.speed >= 0 && colliedsWithWalls(self.x-Tank.speed,y:self.y,walls:self.myClient.walls) && colliedsWithTanks(self.x-Tank.speed,y:self.y,tanks:self.myClient.tanks)) {
                self.x -= Tank.speed
            }
        } else if playerTankToward == .right && isWalk==true {
            if(self.x+Tank.speed <= Tank.paintWidth-32 && colliedsWithWalls(self.x+Tank.speed,y:self.y,walls:self.myClient.walls) && colliedsWithTanks(self.x+Tank.speed,y:self.y,tanks:self.myClient.tanks)) {
                self.x += Tank.speed
            }
        }
    }
    
    func randombadp() {
        if(!isGood) {
            if(dirTime>50) {
                if(drand48()<0.25) {
                    playerTankToward = .up
                } else if (drand48()<0.5) {
                    playerTankToward = .down
                } else if (drand48()<0.75) {
                    playerTankToward = .left
                } else {
                    playerTankToward = .right
                }
                dirTime=0
            } else {
                dirTime += 1
            }
            
            if(walkTime>50) {
                if(drand48()<0.5) {
                    isWalk=true
                } else{
                    isWalk=false
                }
                walkTime=0
            } else {
                walkTime += 1
            }
        }
    }
    
    func colliedsWithTanks(_ tanks:[Tank]) {
    }
    
    func colliedsWithWalls(_ walls:[Wall]) {
    }
    
    func badFire() {
        if(!isGood) {
            if(drand48() < 0.01) {
                myClient.shells.append(Shell(tank: self,client: myClient,attribute:false))
            }
        }
    }
    
    func getRect(_ x:CGFloat,y:CGFloat)->Rectangle {
        return Rectangle(x: x,y: y,w: 32,h: 32)
    }
    
    func getRect()->Rectangle {
        return Rectangle(x: x,y: y,w: 32,h: 32)
    }
    
    func draw(_ view:UIView) {
        var tank:UIImageView
        if(isGood) {
            switch playerTankToward{
            case .up:
                tank=UIImageView(image: Tank.image1)
                tank.frame = CGRect(x: x, y: y, width: 32, height: 32)
            case .down:
                tank=UIImageView(image: Tank.image2)
                tank.frame = CGRect(x: x, y: y, width: 32, height: 32)
            case .left:
                tank=UIImageView(image: Tank.image3)
                tank.frame = CGRect(x: x, y: y, width: 32, height: 32)
            case .right:
                tank=UIImageView(image: Tank.image4)
                tank.frame = CGRect(x: x, y: y, width: 32, height: 32)
            }
            view.addSubview(tank)
        } else {
            switch playerTankToward{
            case .up:
                tank=UIImageView(image: Tank.badimage1)
                tank.frame = CGRect(x: x, y: y, width: 32, height: 32)
            case .down:
                tank=UIImageView(image: Tank.badimage2)
                tank.frame = CGRect(x: x, y: y, width: 32, height: 32)
            case .left:
                tank=UIImageView(image: Tank.badimage3)
                tank.frame = CGRect(x: x, y: y, width: 32, height: 32)
            case .right:
                tank=UIImageView(image: Tank.badimage4)
                tank.frame = CGRect(x: x, y: y, width: 32, height: 32)
            }
            view.addSubview(tank)
        }
    }
}
