//
//  ViewController.swift
//  Tank War Redux
//
//  Created by Keith Davis on 11/3/17.
//  Copyright © 2017 Keith Davis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func blueButtonPressed(_ sender: UIButton) {
        let blueView=storyboard?.instantiateViewController(withIdentifier: "BluetoothView") as! BluetoothViewController
        blueView.modalTransitionStyle = .flipHorizontal
        self.present(blueView, animated: true, completion: nil)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        let subVc=storyboard?.instantiateViewController(withIdentifier: "SingleView")
            as! SingleViewController
        subVc.modalTransitionStyle = .flipHorizontal
        self.present(subVc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
