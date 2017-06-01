//
//  BHPageView.swift
//  BHPagerView
//
//  Created by mac on 18/05/17.
//  Copyright © 2017 Benjamin Halilovic. All rights reserved.
//

import UIKit
@objc
public protocol BHPagerDataSource: NSObjectProtocol {
    
    /// Asks your data source object for the number of items in the pager view.
    @objc(numberOfItemsInPagerView:)
    func numberOfItems(in pagerView: BHPagerView) -> Int
    
    /// Asks your data source object for the cell that corresponds to the specified item in the pager view.
    @objc(pagerView:cellForItemAtIndex:)
    func pagerView(_ pagerView: BHPagerView, cellForItemAt index: Int) -> BHPagerViewCell
    
    
}

@objc
public protocol BHPagerDelegate: NSObjectProtocol {
    
    /// Asks the delegate if the item should be highlighted during tracking.
    @objc(pagerView:shouldHighlightItemAtIndex:)
    optional func pagerView(_ pagerView: BHPagerView, shouldHighlightItemAt index: Int) -> Bool
    
    /// Tells the delegate that the item at the specified index was highlighted.
    @objc(pagerView:didHighlightItemAtIndex:)
    optional func pagerView(_ pagerView: BHPagerView, didHighlightItemAt index: Int)
    
    /// Asks the delegate if the specified item should be selected.
    @objc(pagerView:shouldSelectItemAtIndex:)
    optional func pagerView(_ pagerView: BHPagerView, shouldSelectItemAt index: Int) -> Bool
    
    /// Tells the delegate that the item at the specified index was selected.
    @objc(pagerView:didSelectItemAtIndex:)
    optional func pagerView(_ pagerView: BHPagerView, didSelectItemAt index: Int)
    
    /// Tells the delegate that the specified cell is about to be displayed in the pager view.
    @objc(pagerView:willDisplayCell:forItemAtIndex:)
    optional func pagerView(_ pagerView: BHPagerView, willDisplay cell: BHPagerViewCell, forItemAt index: Int)
    
    /// Tells the delegate that the specified cell was removed from the pager view.
    @objc(pagerView:didEndDisplayingCell:forItemAtIndex:)
    optional func pagerView(_ pagerView: BHPagerView, didEndDisplaying cell: BHPagerViewCell, forItemAt index: Int)
    
    /// Tells the delegate when the pager view is about to start scrolling the content.
    @objc(pagerViewWillBeginDragging:)
    optional func pagerViewWillBeginDragging(_ pagerView: BHPagerView)
    
    /// Tells the delegate when the user finishes scrolling the content.
    @objc(pagerViewWillEndDragging:targetIndex:)
    optional func pagerViewWillEndDragging(_ pagerView: BHPagerView, targetIndex: Int)
    
    /// Tells the delegate when the user scrolls the content view within the receiver.
    @objc(pagerViewDidScroll:)
    optional func pagerViewDidScroll(_ pagerView: BHPagerView)
    
    /// Tells the delegate when a scrolling animation in the pager view concludes.
    @objc(pagerViewDidEndScrollAnimation:)
    optional func pagerViewDidEndScrollAnimation(_ pagerView: BHPagerView)
    
    /// Tells the delegate that the pager view has ended decelerating the scrolling movement.
    @objc(pagerViewDidEndDecelerating:)
    optional func pagerViewDidEndDecelerating(_ pagerView: BHPagerView)
    


}

@objc
public enum BHPagerViewScrollDirection: Int {
    case horizontal
    case vertical
}

open class BHPagerView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: Public properties
    
    #if TARGET_INTERFACE_BUILDER
    @IBOutlet open weak var dataSource: AnyObject?
    @IBOutlet open weak var delegate: AnyObject?
    #else
    open weak var dataSource:BHPagerDataSource?
    open weak var delegate:BHPagerDelegate?
    #endif
    
    /// The scroll direction of the pager view. Default is horizontal.
    open var scrollDirection: BHPagerViewScrollDirection = .horizontal {
        didSet {
            
        }
    }
    
    /// The time interval of automatic sliding. 0 means disabling automatic sliding. Default is 0.
    @IBInspectable
    open var automaticSlidingInterval: CGFloat = 0.0 {
        didSet {
         
        }
    }
    
    /// The spacing to use between items in the pager view. Default is 0.
    @IBInspectable
    open var interitemSpacing: CGFloat = 0 {
        didSet {
            
        }
    }
    
    /// The item size of the pager view. .zero means always fill the bounds of the pager view. Default is .zero.
    @IBInspectable
    open var itemSize: CGSize = .zero {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    /// A Boolean value indicates that whether the pager view has infinite items. Default is false.
    @IBInspectable
    open var isInfinite: Bool = false {
        didSet {
            self.collectionViewLayout.needsReprepare = true
            self.collectionView.reloadData()
        }
    }
    
    
    /// The background view of the pager view.
    @IBInspectable
    open var backgroundView: UIView? {
        didSet {
            if let backgroundView = self.backgroundView {
                if backgroundView.superview != nil {
                    backgroundView.removeFromSuperview()
                }
                self.insertSubview(backgroundView, at: 0)
                self.setNeedsLayout()
            }
        }
    }
    
    /// The transformer of the pager view.
    open var transformer: BHPagerViewTransformer? {
        didSet {
                self.transformer?.pagerView = self
                self.collectionViewLayout.forceInvalidate()
        }
    }
    
    // MARK: - Public readonly-properties
    
    /// Returns whether the user has touched the content to initiate scrolling.
    open var isTracking: Bool {
        return self.collectionView.isTracking
    }

    /// The percentage of x position at which the origin of the content view is offset from the origin of the pagerView view.
    open var scrollOffset: CGFloat {
        let contentOffset = max(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y)
        let scrollOffset = Double(contentOffset.divided(by: self.collectionViewLayout.itemSpacing))
        return fmod(CGFloat(scrollOffset), CGFloat(Double(self.numberOfItems)))
    }


    open fileprivate(set) dynamic var currentIndex: Int = 0
    
    
    // MARK: - Private properties
    
    internal weak var collectionViewLayout: BHPagerViewLayout!
    internal weak var collectionView: BHPagerCollectionView!
    internal weak var contentView: UIView!
    
    internal var timer: Timer?
    internal var numberOfItems: Int = 0
    internal var numberOfSections: Int = 0
    
    fileprivate var dequeingSection = 0
    
    
    // MARK: - Overriden functions
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView?.frame = self.bounds
        self.contentView.frame = self.bounds
        self.collectionView.frame = self.contentView.bounds
        
       
    }
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource = self.dataSource else {
            return 1
        }
        self.numberOfItems = dataSource.numberOfItems(in: self)
        guard self.numberOfItems > 0 else {
            return 0;
        }
        self.numberOfSections = self.isInfinite ? Int(Int16.max)/self.numberOfItems : 1
        return self.numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        
        self.dequeingSection = indexPath.section
        let cell = self.dataSource!.pagerView(self, cellForItemAt: index)
        return cell
    }
    
    
     // MARK: - UICollectionViewDelegate
  

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.numberOfItems > 0 {
            // In case someone is using KVO
            let currentIndex = lround(Double(self.scrollOffset)) % self.numberOfItems
            if (currentIndex != self.currentIndex) {
                self.currentIndex = currentIndex
            }
        }
        guard let function = self.delegate?.pagerViewDidScroll else {
           return
        }
        function(self)
    }
    
   

    
    
    //MARK: Public functions
    /// Register a class for use in creating new pager view cells.
    ///
    /// - Parameters:
    ///   - cellClass: The class of a cell that you want to use in the pager view.
    ///   - identifier: The reuse identifier to associate with the specified class. This parameter must not be nil and must not be an empty string.
    @objc(registerClass:forCellWithReuseIdentifier:)
    open func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    /// Register a nib file for use in creating new pager view cells.
    ///
    /// - Parameters:
    ///   - nib: The nib object containing the cell object. The nib file must contain only one top-level object and that object must be of the type FSPagerViewCell.
    ///   - identifier: The reuse identifier to associate with the specified nib file. This parameter must not be nil and must not be an empty string.
    @objc(registerNib:forCellWithReuseIdentifier:)
    open func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }

    
    /// Returns a reusable cell object located by its identifier
    ///
    /// - Parameters:
    ///   - identifier: The reuse identifier for the specified cell. This parameter must not be nil.
    ///   - index: The index specifying the location of the cell.
    /// - Returns: A valid FSPagerViewCell object.
    @objc(dequeueReusableCellWithReuseIdentifier:atIndex:)
    open func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> BHPagerViewCell {
        let indexPath = IndexPath(item: index, section: self.dequeingSection)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        guard cell.isKind(of: BHPagerViewCell.self) else {
            fatalError("Cell class must be subclass of FSPagerViewCell")
        }
        return cell as! BHPagerViewCell
    }
    
    /// Reloads all of the data for the collection view.
    @objc(reloadData)
    open func reloadData() {
        //self.collectionViewLayout.needsReprepare = true;
        self.collectionView.reloadData()
    }
    
    /// Selects the item at the specified index and optionally scrolls it into view.
    ///
    /// - Parameters:
    ///   - index: The index path of the item to select.
    ///   - animated: Specify true to animate the change in the selection or false to make the change without animating it.
    @objc(selectItemAtIndex:animated:)
    open func selectItem(at index: Int, animated: Bool) {
        print("Select item \(index)")
       
    }

    
    

    
    
    //MARK: - Private functions
    
    fileprivate func commonInit() {
        //Content View
        let contentView = UIView(frame: CGRect.zero)
        contentView.backgroundColor = UIColor.red
        self.addSubview(contentView)
        self.contentView = contentView
        
        //Collection View
        let collectionViewLayout = BHPagerViewLayout()
        let collectionView = BHPagerCollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        self.contentView.addSubview(collectionView)
        self.collectionView = collectionView
        self.collectionViewLayout = collectionViewLayout
    }
    
}
