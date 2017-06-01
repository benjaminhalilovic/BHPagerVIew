//
//  ViewController.swift
//  BHPagerView
//
//  Created by mac on 18/05/17.
//  Copyright © 2017 Benjamin Halilovic. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BHPagerDataSource, BHPagerDelegate {
    
    @IBOutlet weak var pagerView: BHPagerView! {
        didSet {
            self.pagerView.register(BHPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.itemSize = .zero

        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate let sectionTitles = ["Configurations", "Item Size", "Interitem Spacing"]
    fileprivate let configurationTitles = ["Automatic sliding","Infinite"]
    fileprivate let imageNames = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg"]
    fileprivate let transformerNames = ["cross fading", "zoom out", "depth", "linear", "overlap", "ferris wheel", "inverted ferris wheel", "coverflow", "cubic"]
    fileprivate let transformerTypes: [FSPagerViewTransformerType] = [.crossFading,
                                        .zoomOut,
                                        .depth,
                                        .linear,
                                        .overlap,
                                        .ferrisWheel,
                                        .invertedFerrisWheel,
                                        .coverFlow,
                                        .cubic]
    fileprivate var typeIndex = 0 {
        didSet {
            print("typeDid set")
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let type = self.transformerTypes[typeIndex]
        self.pagerView.transformer = BHPagerViewTransformer(type:type)
    }

    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        switch sender.tag {
        case 1:
            let newScale = 0.5+CGFloat(sender.value)*0.5 // [0.5 - 1.0]
            self.pagerView.itemSize = self.pagerView.frame.size.applying(CGAffineTransform(scaleX: newScale, y: newScale))
        case 2:
            self.pagerView.interitemSpacing = CGFloat(sender.value) * 20 // [0 - 20]
        default:
            break
        }

    }
    
    // MARK:- BHPagerView DataSource
    
    func numberOfItems(in pagerView: BHPagerView) -> Int {
        return self.imageNames.count
    }
    
    public func pagerView(_ pagerView: BHPagerView, cellForItemAt index: Int) -> BHPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = UIImage(named: self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = index.description+index.description
        return cell
    }
    
   
     // MARK:- BHPagerView Delegate
    func pagerViewDidScroll(_ pagerView: BHPagerView) {
      
    }
    
    func pagerView(_ pagerView: BHPagerView, didSelectItemAt index: Int) {
        
    }
  
    
    // MARK:- UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.configurationTitles.count
        case 1,2:
            return 1
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Configurations
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = self.configurationTitles[indexPath.row]
            if indexPath.row == 0 {
                // Automatic Sliding
                cell.accessoryType = self.pagerView.automaticSlidingInterval > 0 ? .checkmark : .none
            } else if indexPath.row == 1 {
                // IsInfinite
                cell.accessoryType = self.pagerView.isInfinite ? .checkmark : .none
            }
            return cell
        case 1:
            // Item Spacing
            let cell = tableView.dequeueReusableCell(withIdentifier: "slider_cell")!
            let slider = cell.contentView.subviews.first as! UISlider
            slider.tag = indexPath.section
            slider.value = {
                let scale: CGFloat = self.pagerView.itemSize.width/self.pagerView.frame.width
                let value: CGFloat = (0.5-scale)*2
                return Float(value)
            }()
            return cell
        case 2:
            // Interitem Spacing
            let cell = tableView.dequeueReusableCell(withIdentifier: "slider_cell")!
            let slider = cell.contentView.subviews.first as! UISlider
            slider.tag = indexPath.section
            slider.value = Float(self.pagerView.interitemSpacing.divided(by: 20.0))
            return cell
        default:
            break
        }
        return tableView.dequeueReusableCell(withIdentifier: "cell")!
    }
    
    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 { // Automatic Sliding
                self.pagerView.automaticSlidingInterval = 3.0 - self.pagerView.automaticSlidingInterval
            } else if indexPath.row == 1 { // IsInfinite
                self.pagerView.isInfinite = !self.pagerView.isInfinite
            }
            tableView.reloadSections([indexPath.section], with: .automatic)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 20
    }
    


    



}

