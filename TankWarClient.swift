//
//  TankWarClient.swift
//  Tank War Redux
//
//  Created by Keith Davis on 11/2/17.
//  Copyright © 2017 Keith Davis. All rights reserved.
//

import Foundation

class TankWarClient {
    var myTank:Tank!
    var tanks:[Tank]
    var shells:[Shell]
    var walls:Wall
    var explodes:[Explode]
    var badTankInterval1:Int=0
    var badTankInterval2:Int=0
    
    init() {
        shells=[]
        walls=Wall()
        explodes=[]
        tanks=[]
        myTank=Tank(x: 0,y: (Tank.paintHeight/2)-64,attribute:true,client:self,toward: .right)
    }
    
    func paint()->UIView? {
        var view: UIView?
        var widthScale: CGFloat
        var heightScale: CGFloat
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            widthScale = 1.25
            heightScale = 1.25
        } else {
            widthScale = 0.75
            heightScale = 0.75
        }
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
    
        view=UIView(frame: CGRect(x: CGFloat(screenWidth - Tank.paintWidth) / 2, y: CGFloat(screenHeight - Tank.paintHeight) / 2, width: Tank.paintWidth, height: Tank.paintHeight))
        
        view?.transform = CGAffineTransform(scaleX: widthScale, y: heightScale)
        
        view?.tag=100
        view?.backgroundColor = UIColor(patternImage: UIImage(named:"tile4")!)
        
        myTank.move()
        myTank.draw(view!)
        
        if(Tank.badTankCount < 50 ) {
            if(tanks.count < 35){
                if(badTankInterval1 > 100) {
                    if(drand48() < 0.1 && myTank.colliedsWithTanks(Tank.paintWidth-32, y: 0, tanks: tanks, badi: -1)) {
                        tanks.append(Tank(x: Tank.paintWidth-32, y: 0, attribute: false, client: self,toward: .down))
                        badTankInterval1=0
                    }
                } else {
                    badTankInterval1 += 1
                }
                
                if(badTankInterval2>100) {
                    if(drand48() < 0.1 && myTank.colliedsWithTanks(Tank.paintWidth-32, y: Tank.paintHeight-32, tanks: tanks, badi: -1)) {
                        tanks.append(Tank(x:Tank.paintWidth-32, y: Tank.paintHeight-32, attribute: false, client: self,toward: .up))
                        badTankInterval2=0
                    }
                } else {
                    badTankInterval2 += 1
                }
            }
        }
        
        for i in 0..<shells.count {
            guard let m=shells[safe: i] else { break }
            m.fly()
            m.hitEdge()
            m.hitTank(myTank)
            m.hitTanks(tanks)
            m.hitWall(walls)
            
            if(!m.isLive) {
                shells.remove(at: i)
            }
            else{
                m.draw(view!)
            }
        }
        
        for i in 0..<tanks.count {
            guard let badtank=tanks[safe: i] else { break }
            if(badtank.isLive) {
                badtank.move(i)
                badtank.badFire()
                badtank.draw(view!)
                
            }
            else{
                tanks.remove(at: i)
            }
        }
     
        for i in 0..<explodes.count {
            guard let e=explodes[safe: i] else { break }
            if(e.time>0) {
                e.draw(view!);
            }
            else{
                explodes.remove(at: i)
            }
        }
        
        walls.draw(view!)
        
        if((tanks.count == 0) || (myTank.isLive == false && tanks.count >= 1)) {
            SingleViewController.isOver = true
        }
        return view!
    }
}
