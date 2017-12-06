//
//  BluetoothTankWarClient.swift
//  Tank War Redux
//
//  Created by Keith Davis on 11/2/17.
//  Copyright © 2017 Keith Davis. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class BluetoothTankWarClient:TankWarClient{
    var mytank: BlueTank!
    var isOver = false
    var isYouWin = true
    var identifier = "1"
    var enemyTank: [BlueTank]!
    var viewController: BluetoothViewController!
    
    override init() {
        super.init()
        enemyTank = []
    }
    
    func beginGame(_ viewController: BluetoothViewController) {
        Sound.play(file: "tank", fileExtension: "wav", numberOfLoops: -1)
        
        viewController.view.backgroundColor = UIColor(patternImage: UIImage(named:"tile5")!)
        viewController.connect.isHidden=true
        viewController.beginGame.isHidden=true
        viewController.mainMenu.isHidden = true
        viewController.help.isHidden = true
        viewController.analogueStick.isHidden=false
        viewController.fireButton.isHidden=false
        viewController.bluetoothTextView.isHidden=true
        
        self.viewController = viewController
        
        mytank = BlueTank(attribute: false, client: self, peerID: viewController.session.myPeerID, identifier: identifier)
        
        var running: Bool = true
        
        let queue=DispatchQueue.global(qos: .default)
        queue.async {
            while(running) {
                DispatchQueue.main.async {
                    let view1=viewController.player.paint()
                    
                    if (self.isOver == true) {
                        running = false
                    }
                    
                    let view=viewController.view.viewWithTag(100)
                    
                    if(view != nil) {
                        view?.removeFromSuperview()
                    }
                    
                    viewController.view.insertSubview(view1, at: 0)
                }
                Thread.sleep(forTimeInterval: 0.06)
            }
            
            DispatchQueue.main.async {
                Sound.stopAll()
                
                let view=viewController.view.viewWithTag(100)
                if(view != nil) {
                    view?.removeFromSuperview()
                }
                
                viewController.analogueStick.isHidden=true
                viewController.fireButton.isHidden=true
                viewController.gameStatus.isHidden = false
                
                if(self.isYouWin) {
                    viewController.gameStatus.text = "You Win !!"
                }
                else{
                    viewController.gameStatus.text = "You Lose !!"
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                viewController.assistant.stop()
                
                let view=viewController.storyboard?.instantiateViewController(withIdentifier: "View")
                    as! ViewController
                view.modalTransitionStyle = .flipHorizontal
            
                viewController.present(view, animated: true, completion: nil)
            }
        }
    }
    
    func updateEnemyLocation(_ str:String) {
        print(str)
        for i in 0 ... enemyTank.count - 1 {
            if(str.contains(enemyTank[i].peerID.displayName)) {
                var range1 = (str as NSString).range(of: "x:")
                var range2 = (str as NSString).range(of: "y:")
                var index1 = range1.location+range1.length
                var index2 = range2.location
                var x = (str as NSString).substring( with: NSMakeRange(index1, index2-index1))
                
                enemyTank[i].x = CGFloat((x as NSString).integerValue)
                range1 = (str as NSString).range(of: "y:")
                range2 = (str as NSString).range(of: "toward:")
                index1 = range1.location+range1.length
                index2 = range2.location
                x = (str as NSString).substring( with: NSMakeRange(index1, index2-index1))
                enemyTank[i].y = CGFloat((x as NSString).integerValue)
                x = (str as NSString).substring(from: range2.location+range2.length)
                
                switch x {
                case "up":
                    enemyTank[i].playerTankToward = .up
                case "down":
                    enemyTank[i].playerTankToward = .down
                case "left":
                    enemyTank[i].playerTankToward = .left
                case "right":
                    enemyTank[i].playerTankToward = .right
                default:
                    enemyTank[i].playerTankToward = Toward.up;
                }
            }
        }
    }
    
    func updateShell(_ str:String) {
        print(str)
        var range1 = (str as NSString).range(of: "x:")
        var range2 = (str as NSString).range(of: "y:")
        var index1 = range1.location+range1.length
        var index2 = range2.location
        let strX = (str as NSString).substring( with: NSMakeRange(index1, index2-index1))
        let shellX = CGFloat((strX as NSString).integerValue)
        
        range1 = (str as NSString).range(of: "y:")
        range2 = (str as NSString).range(of: "toward:")
        index1 = range1.location+range1.length
        index2 = range2.location
        
        let strY = (str as NSString).substring( with: NSMakeRange(index1, index2-index1))
        let shellY = CGFloat((strY as NSString).integerValue)
        let strToward = (str as NSString).substring(from: range2.location+range2.length)
        let shellToward:Toward
        
        switch strToward {
        case "up":
            shellToward = Toward.up
        case "down":
            shellToward = Toward.down
        case "left":
            shellToward = Toward.left
        case "right":
            shellToward = Toward.right
        default:
            shellToward = Toward.up;
        }
        
        range1 = (str as NSString).range(of: "shellIdentifier:")
        range2 = (str as NSString).range(of: "x:")
        index1 = range1.location+range1.length
        index2 = range2.location
        
        let id = ((str as NSString).substring( with: NSMakeRange(index1, index2-index1)) as NSString).intValue
        shells.append(Shell(x:shellX,y:shellY,toward:shellToward,client:self,attribute:true,id:id))
    }
    
    func updateExplode(_ str:String) {
        print(str)
        
        var range1 = (str as NSString).range(of: "explode")
        let range2 = (str as NSString).range(of: "shellIdentifier:")
        var index1 = range1.location+range1.length
        let index2 = range2.location
        let peerIDName = (str as NSString).substring( with: NSMakeRange(index1, index2-index1))
        
        print(peerIDName)
        
        range1 = (str as NSString).range(of: "shellIdentifier:")
        index1 = range1.location+range1.length
        let shellID = (str as NSString).substring(from: index1)
        let id = (shellID as NSString).intValue
        
        for i in 0..<shells.count {
            guard let m=shells[safe: i] else { break }
            print(m.shellID)
            if(id==m.shellID){
                explodes.append(Explode(x:m.x,y:m.y))
                m.isLive=false
                break
            }
        }
        
        for i in 0..<enemyTank.count {
            guard let t=enemyTank[safe: i] else { break }
            if(peerIDName == t.peerID.displayName){
                t.isLive = false
                break
            }
        }

    }
    
    override func paint()->UIView{
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
        
        let view=UIView(frame: CGRect(x: CGFloat(screenWidth - Tank.paintWidth) / 2, y: CGFloat(screenHeight - Tank.paintHeight) / 2, width: Tank.paintWidth, height: Tank.paintHeight))
        
        view.transform = CGAffineTransform(scaleX: widthScale, y: heightScale)
        view.tag=100
        view.backgroundColor = UIColor(patternImage: UIImage(named:"tile4")!)

        if(mytank.isLive) {
            let xx=mytank.x
            let yy=mytank.y
            
            mytank.move()
            if((xx != mytank.x)||(yy != mytank.y)) {
                do{
                    try viewController.session.send(("location"+mytank.peerID.displayName+"identifier:"+mytank.identifier+"x:\(mytank.x)y:\(mytank.y)toward:\(mytank.playerTankToward)").data(using: String.Encoding.utf16,
                        allowLossyConversion: false)!, toPeers: viewController.session.connectedPeers,
                        with: MCSessionSendDataMode.unreliable)
                    print("send location success")
                }
                catch let error as NSError {
                print("Error sending data: \(error.localizedDescription)")
                }
            }
            mytank.draw(view)
        }

        for i in 0..<shells.count {
            guard let m=shells[safe: i] else { break }
            m.fly()
            m.hitEdge()
            m.hitTank(mytank)
            m.hitWall(walls)
            if(!m.isLive){
                shells.remove(at: i)
            }
            else{
                m.draw(view)
            }
        }
        
        for i in 0..<enemyTank.count {
            guard let badtank=enemyTank[safe: i] else { break }

            if(badtank.isLive){
                badtank.draw(view)
            }
            else{
                enemyTank.remove(at: i)
            }
        }

        for i in 0..<explodes.count {
            guard let e=explodes[safe: i] else { break }
            if(e.time>0){
                e.draw(view);
            }
            else{
                explodes.remove(at: i)
            }
        }
        
        if((enemyTank.count==0)||(mytank.isLive==false&&enemyTank.count==1)) {
            isOver = true
        }
        
        walls.draw(view)
        
        return view
    }
}
