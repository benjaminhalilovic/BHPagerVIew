//
//  ViewController.swift
//  BHPagerView
//
//  Created by mac on 18/05/17.
//  Copyright © 2017 Benjamin Halilovic. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BHPagerDataSource {
    
    @IBOutlet weak var pagerView: BHPagerView! {
        didSet {
            self.pagerView.register(BHPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.itemSize = .zero
        }
    }
    fileprivate let sectionTitles = ["Configurations", "Item Size", "Interitem Spacing"]
    fileprivate let configurationTitles = ["Automatic sliding","Infinite"]
    fileprivate let imageNames = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg"]
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // MARK:- FSPagerView DataSource
    
    public func numberOfItems(in pagerView: BHPagerView) -> Int {
        return self.imageNames.count
    }
    
    public func pagerView(_ pagerView: BHPagerView, cellForItemAt index: Int) -> BHPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        print(cell)
        cell.imageView?.image = UIImage(named: self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = index.description+index.description
        return cell
    }
    



}

