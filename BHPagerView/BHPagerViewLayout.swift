//
//  BHPagerViewLayout.swift
//  BHPagerView
//
//  Created by mac on 18/05/17.
//  Copyright © 2017 Benjamin Halilovic. All rights reserved.
//

import UIKit

class BHPagerViewLayout: UICollectionViewLayout {
    
    internal var contentSize: CGSize = .zero
    internal var leadingSpacing: CGFloat = 0
    internal var itemSpacing: CGFloat = 0
    internal var needsReprepare = true
    internal var scrollDirection: BHPagerViewScrollDirection = .horizontal
    
    fileprivate var pagerView: BHPagerView? {
        return self.collectionView?.superview?.superview as? BHPagerView
    }
    fileprivate var layoutAttributesQueue: [BHPagerViewLayoutAttributes] = []
    fileprivate var isInfinite: Bool = true
    fileprivate var collectionViewSize: CGSize = .zero
    fileprivate var numberOfSections = 1
    fileprivate var numberOfItems = 0
    fileprivate var actualInteritemSpacing: CGFloat = 0
    fileprivate var actualItemSize: CGSize = .zero
    
    override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override open func prepare() {
        guard let collectionView = self.collectionView, let pagerView = self.pagerView else {
            return
        }
        
        guard self.needsReprepare || self.collectionViewSize != collectionView.frame.size else {
            return
        }
        
        self.needsReprepare = false
        self.collectionViewSize = collectionView.frame.size
        
        //Calculate basic parameters/variables
        //Find number of item and number of section in Collection view
        self.numberOfItems = pagerView.numberOfSections(in: collectionView)
        self.numberOfItems = pagerView.collectionView(collectionView, numberOfItemsInSection: 0)
        guard self.numberOfItems > 0 && self.numberOfSections > 0 else {
            return
        }
        
        //Set actual item size (from @insp)
        self.actualItemSize = {
            var size = pagerView.itemSize
            if size == .zero {
                size = collectionView.frame.size
            }
            return size
        }()
        
        self.actualInteritemSpacing = {
            return pagerView.interitemSpacing
        }()
        
        self.scrollDirection = pagerView.scrollDirection
        self.leadingSpacing = self.scrollDirection == .horizontal ? (collectionView.frame.width - self.actualItemSize.width) * 0.5 : (collectionView.frame.height-self.actualItemSize.height)*0.5
        
         self.itemSpacing = (self.scrollDirection == .horizontal ? self.actualItemSize.width : self.actualItemSize.height) + self.actualInteritemSpacing
        
        self.contentSize = {
           let numberOfItems = self.numberOfItems*self.numberOfSections
            switch self.scrollDirection {
            case .horizontal:
                var contentSizeWidth: CGFloat = self.leadingSpacing * 2 // Leading & trailing spacing
                contentSizeWidth += CGFloat(numberOfItems-1)*self.actualInteritemSpacing //Interitem spacing
                contentSizeWidth += CGFloat(numberOfItems)*self.actualItemSize.width //Item size
                let contentSize = CGSize(width: contentSizeWidth, height: collectionView.frame.height)
                print("content size \(contentSize)")
                return contentSize
            case .vertical:
                var contentSizeHeight: CGFloat = self.leadingSpacing*2 // Leading & trailing spacing
                contentSizeHeight += CGFloat(numberOfItems-1)*self.actualInteritemSpacing // Interitem spacing
                contentSizeHeight += CGFloat(numberOfItems)*self.actualItemSize.height // Item sizes
                let contentSize = CGSize(width: collectionView.frame.width, height: contentSizeHeight)
                return contentSize
            }
        }()
    }
    
    override open var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
       
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        guard self.numberOfItems > 0 else {
            return layoutAttributes
        }
        /*guard self.itemSpacing > 0, !rect.isEmpty else {

            return layoutAttributes
        }*/
        //Visible rect??
        let rect = rect.intersection(CGRect(origin: .zero, size: self.contentSize))

        guard !rect.isEmpty else {
            return layoutAttributes
        }
        print("rect.minX\(rect.minX)")
        print("self.leadingSpacing\(self.leadingSpacing)")
        print("self.itemSpacing\(self.itemSpacing)")
        
        // Calculate start position and index of certain rects
        let numberOfItemsBefore = self.scrollDirection == .horizontal ? max(Int((rect.minX-self.leadingSpacing)/self.itemSpacing),0) : max(Int((rect.minY-self.leadingSpacing)/self.itemSpacing),0)
        


        return layoutAttributes
    }
    
    //MARK: Internal function
    internal func contentOffset(for indexPath: IndexPath) -> CGPoint {
        let origin = self.frame(for: indexPath).origin
        guard let collectionView = self.collectionView else {
            return origin
        }
        let contentOffsetX: CGFloat = {
            if self.scrollDirection == .vertical {
                return 0
            }
            let contentOffsetX = origin.x - (collectionView.frame.width*0.5-self.actualItemSize.width*0.5)
            return contentOffsetX
        }()
        let contentOffsetY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return 0
            }
            let contentOffsetY = origin.y - (collectionView.frame.height*0.5-self.actualItemSize.height*0.5)
            return contentOffsetY
        }()
        let contentOffset = CGPoint(x: contentOffsetX, y: contentOffsetY)
        return contentOffset
    }
    
    internal func frame(for indexPath: IndexPath) -> CGRect {
        let numberOfItems = self.numberOfItems*indexPath.section + indexPath.item
        let originX: CGFloat = {
            if self.scrollDirection == .vertical {
                return (self.collectionView!.frame.width-self.actualItemSize.width)*0.5
            }
            return self.leadingSpacing + CGFloat(numberOfItems)*self.itemSpacing
        }()
        let originY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return (self.collectionView!.frame.height-self.actualItemSize.height)*0.5
            }
            return self.leadingSpacing + CGFloat(numberOfItems)*self.itemSpacing
        }()
        let origin = CGPoint(x: originX, y: originY)
        let frame = CGRect(origin: origin, size: self.actualItemSize)
        return frame
    }

    
    //MARK : Private function
    
    fileprivate func adjustCollectionViewBounds() {
        guard let collectionView = self.collectionView, let pagerView = self.pagerView else {
            return
        }
        let currentIndex = pagerView.currentIndex
        let newIndexPath = IndexPath(item: currentIndex, section: self.isInfinite ? self.numberOfSections/2 : 0)
        let contentOffset = self.contentOffset(for: newIndexPath)
        let newBounds = CGRect(origin: contentOffset, size: collectionView.frame.size)
        collectionView.bounds = newBounds
    }
}
