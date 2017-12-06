//
//  Explode.swift
//  Tank War Redux
//
//  Created by Keith Davis on 11/3/17.
//  Copyright © 2017 Keith Davis. All rights reserved.
//

import Foundation

class Explode{
    var x:CGFloat
    var y:CGFloat
    var time:Int
    static let image1=UIImage(named: "explode1.png")!
    static let image2=UIImage(named: "explode2.png")!
    static let image3=UIImage(named: "explode3.png")!

    init(x:CGFloat,y:CGFloat) {
        self.x=x-5
        self.y=y-5
        time=4
    }
    
    func draw(_ view:UIView) {
        Sound.play(file: "explosion.wav")
        
        time-=1
        
        var explode=UIImageView(image: Explode.image1)
        explode.frame = CGRect(x: x, y: y, width: 25, height: 25)
        view.addSubview(explode)
        
        explode=UIImageView(image: Explode.image2)
        explode.frame = CGRect(x: x, y: y, width: 25, height: 25)
        view.addSubview(explode)
        
        explode=UIImageView(image: Explode.image3)
        explode.frame = CGRect(x: x, y: y, width: 25, height: 25)
        view.addSubview(explode)
    }
}
