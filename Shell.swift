//
//  Shell.swift
//  Tank War Redux
//
//  Created by Keith Davis on 11/3/17.
//  Copyright © 2017 Keith Davis. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Shell{
    var x:CGFloat
    var y:CGFloat
    var toward:Toward
    var isLive=true
    var isGood=true
    var myClient:TankWarClient
    var shellID:Int32!
    
    static let speed:CGFloat = 8
    static let shellImage1 = UIImage(named: "bullet.png")
    static let shellImage2 = UIImage(named: "bullet_d.png")
    static let shellImage3 = UIImage(named: "bullet_l.png")
    static let shellImage4 = UIImage(named: "bullet_r.png")

    init(tank:Tank,client:TankWarClient,attribute:Bool) {
        myClient=client
        toward=tank.playerTankToward
        isGood=attribute
    
        switch toward {
        case .up:
            x=tank.x+11
            y=tank.y-10
        case .down:
            x=tank.x+11
            y=tank.y+32
        case .left:
            x=tank.x-10
            y=tank.y+11
        case .right:
            x=tank.x+32
            y=tank.y+11
        }
        
    }
    
    init(tank:BlueTank,client:BluetoothTankWarClient,attribute:Bool,id:Int32) {
        shellID = id
        myClient=client
        toward=tank.playerTankToward
        isGood=attribute
        
        switch toward {
        case .up:
            x=tank.x+11
            y=tank.y-10
        case .down:
            x=tank.x+11
            y=tank.y+32
        case .left:
            x=tank.x-10
            y=tank.y+11
        case .right:
            x=tank.x+32
            y=tank.y+11
        }
        do{
            try (myClient as! BluetoothTankWarClient).viewController.session.send(("sendShell"+tank.peerID.displayName+"shellIdentifier:"+"\(id)"+"x:\(x)y:\(y)toward:\(toward)").data(using: String.Encoding.utf16,
                allowLossyConversion: false)!, toPeers: (myClient as! BluetoothTankWarClient).viewController.session.connectedPeers,
                with: MCSessionSendDataMode.unreliable)
            print("send shell location success")
        }
        catch let error as NSError {
            print("Error sending data: \(error.localizedDescription)")
        }
    }
    
    init(x:CGFloat,y:CGFloat,toward:Toward,client:BluetoothTankWarClient,attribute:Bool,id:Int32) {
        shellID = id
        myClient=client
        self.toward = toward
        isGood=attribute
        self.x=x
        self.y=y
    }
    
    func hitWall(_ walls:Wall) {
        for i in 0 ..< walls.ws.count {
            if(intersects(self.getRect(), r2: walls.ws[i])) {
                myClient.explodes.append(Explode(x: self.x,y: self.y))
                self.isLive=false
                break
            }
        }
    }
    
    func hitTank(_ myTank:Tank) {
        if(intersects(self.getRect(), r2: myTank.getRect())) {
            myClient.explodes.append(Explode(x: self.x,y: self.y))
            self.isLive=false
            myTank.isLive=false
        }
    }
    
    func hitTank(_ myTank:BlueTank) {
        if(intersects(self.getRect(), r2: myTank.getRect())) {
            myClient.explodes.append(Explode(x: self.x,y: self.y))
            self.isLive=false
            myTank.isLive=false
            (myClient as! BluetoothTankWarClient).isYouWin = false
            do {
                try (myClient as! BluetoothTankWarClient).viewController.session.send(("explode"+myTank.peerID.displayName+"shellIdentifier:\(self.shellID)").data(using: String.Encoding.utf16,
                    allowLossyConversion: false)!, toPeers: (myClient as! BluetoothTankWarClient).viewController.session.connectedPeers,
                    with: MCSessionSendDataMode.unreliable)
                print("send explodes success")
            } catch let error as NSError {
                print("Error sending data: \(error.localizedDescription)")
            }
        }
    }
    
    func hitTanks(_ tanks:[BlueTank]) {
        if(intersects(self.getRect(), r2: myClient.myTank.getRect())) {
            myClient.explodes.append(Explode(x: self.x,y: self.y))
            self.isLive=false
            //myClient.myTank.isLive=False
        }
        
        for i in 0 ..< myClient.tanks.count {
            let t = tanks[i]
            if(intersects(self.getRect(), r2: t.getRect())) {
                myClient.explodes.append(Explode(x: self.x,y: self.y))
                self.isLive=false
                if(self.isGood==true){
                    t.isLive=false
                }
            }
        }
    }
    
    func hitTanks(_ tanks:[Tank]) {
        if(intersects(self.getRect(), r2: myClient.myTank.getRect())) {
            myClient.explodes.append(Explode(x: self.x,y: self.y))
            self.isLive=false
            //myClient.myTank.isLive=False
        }
        
        for i in 0 ..< myClient.tanks.count {
            let t = tanks[i]
            if(intersects(self.getRect(), r2: t.getRect())){
                myClient.explodes.append(Explode(x: self.x,y: self.y))
                self.isLive=false
                if(self.isGood==true) {
                    t.isLive=false
                }
            }
        }
    }
    
    func hitEdge() {
        if(self.x<=0||self.y<=0||self.x>=Tank.paintWidth-10||self.y>=Tank.paintHeight-10) {
            self.isLive=false
            myClient.explodes.append(Explode(x: self.x,y: self.y))
        }
    }
    
    func fly(){
        switch toward {
        case .up:
            y -= Shell.speed
        case .down:
            y += Shell.speed
        case .left:
            x -= Shell.speed
        case .right:
            x += Shell.speed
        }
    }
    
    func getRect()->Rectangle {
        return Rectangle(x: self.x,y: self.y,w: 10,h: 10)
    }
    
    func draw(_ view:UIView) {
        var shell:UIImageView
        
        switch toward{
        case .up:
            shell=UIImageView(image: Shell.shellImage1)
            shell.frame = CGRect(x: x, y: y, width: 10, height: 10)
        case .down:
            shell=UIImageView(image: Shell.shellImage2)
            shell.frame = CGRect(x: x, y: y, width: 10, height: 10)
        case .left:
            shell=UIImageView(image: Shell.shellImage3)
            shell.frame = CGRect(x: x, y: y, width: 10, height: 10)
        case .right:
            shell=UIImageView(image: Shell.shellImage4)
            shell.frame = CGRect(x: x, y: y, width: 10, height: 10)
        }
        view.addSubview(shell)
    }
}
