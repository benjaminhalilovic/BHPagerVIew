//
//  testvcViewController.swift
//  BHPagerView
//
//  Created by mac on 20/05/17.
//  Copyright © 2017 Benjamin Halilovic. All rights reserved.
//

import UIKit

class testvcViewController: UIViewController {

    @IBOutlet weak var tap: UIButton!
    var currentAnimation = 0
    var imageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView = UIImageView(image: UIImage(named: "1"))
        imageView.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(imageView)
    }
    
    
    @IBAction func button_tapped(_ sender: Any) {
        tap.isHidden = true
        UIView.animate(withDuration: 1, animations: {
            print("Animation in progress...")
            switch self.currentAnimation {
            case 0:
                self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
                break
            default:
                break
            }
        }, completion:{
            (finished: Bool) in
            self.tap.isHidden = false
        })
        currentAnimation += 1
    }

}
