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
    
    open override class var layoutAttributesClass: AnyClass {
        get {
            return BHPagerViewLayoutAttributes.self
        }
    }
    
    fileprivate var pagerView: BHPagerView? {
        return self.collectionView?.superview?.superview as? BHPagerView
    }
    fileprivate var layoutAttributesQueue: [BHPagerViewScrollDirection] = []
    
    fileprivate var isInfinite: Bool = true
    fileprivate var collectionViewSize: CGSize = .zero
    fileprivate var numberOfSections = 1
    fileprivate var numberOfItems = 0
    fileprivate var actualInteritemSpacing: CGFloat = 0
    fileprivate var actualItemSize: CGSize = .zero
    
    override open var collectionViewContentSize: CGSize {
       
        return self.contentSize
    }
    
    override func prepare() {
        
        guard let collectionView = self.collectionView, let pagerView = self.pagerView else {
            return
        }
        guard self.needsReprepare || self.collectionViewSize != collectionView.frame.size else {
            return
        }
        self.needsReprepare = false
        
        self.collectionViewSize = collectionView.frame.size
        
        // Calculate basic parameters/variables
        self.numberOfSections = pagerView.numberOfSections(in: collectionView)
        self.numberOfItems = pagerView.collectionView(collectionView, numberOfItemsInSection: 0)
        guard self.numberOfItems > 0 && self.numberOfSections > 0 else {
            return
        }
        
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
        self.leadingSpacing = self.scrollDirection == .horizontal ? (collectionView.frame.width-self.actualItemSize.width)*0.5 : (collectionView.frame.height-self.actualItemSize.height)*0.5
        
        self.itemSpacing = (self.scrollDirection == .horizontal ? self.actualItemSize.width : self.actualItemSize.height) + self.actualInteritemSpacing
        
        // Calculate and cache contentSize, rather than calculating each time
        self.contentSize = {
            let numberOfItems = self.numberOfItems*self.numberOfSections
            switch self.scrollDirection {
            case .horizontal:
                var contentSizeWidth: CGFloat = self.leadingSpacing*2 // Leading & trailing spacing
                contentSizeWidth += CGFloat(numberOfItems-1)*self.actualInteritemSpacing // Interitem spacing
                contentSizeWidth += CGFloat(numberOfItems)*self.actualItemSize.width // Item sizes
                let contentSize = CGSize(width: contentSizeWidth, height: collectionView.frame.height)
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
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        guard self.numberOfItems > 0 else {
            return layoutAttributes
        }
        guard self.itemSpacing > 0, !rect.isEmpty else {
            return layoutAttributes
        }
        let rect = rect.intersection(CGRect(origin: .zero, size: self.contentSize))
        //print("self.contentSize\(self.contentSize)")
     
        guard !rect.isEmpty else {
            return layoutAttributes
        }
        
        let numberOfItemsBefore = self.scrollDirection == .horizontal ? max(Int((rect.minX-self.leadingSpacing)/self.itemSpacing),0) : max(Int((rect.minY-self.leadingSpacing)/self.itemSpacing),0)
        let startPosition = self.leadingSpacing + CGFloat(numberOfItemsBefore)*self.itemSpacing
        let startIndex = numberOfItemsBefore
        // Create layout attributes
        var itemIndex = startIndex
        var origin = startPosition
        let maxPosition = self.scrollDirection == .horizontal ? min(rect.maxX,self.contentSize.width-self.actualItemSize.width-self.leadingSpacing) : min(rect.maxY,self.contentSize.height-self.actualItemSize.height-self.leadingSpacing)
        while origin <= maxPosition {
            let indexPath = IndexPath(item: itemIndex%self.numberOfItems, section: itemIndex/self.numberOfItems)
            let attributes = self.layoutAttributesForItem(at: indexPath) as! BHPagerViewLayoutAttributes
            self.applyTransform(to: attributes, with: self.pagerView?.transformer)
            
            layoutAttributes.append(attributes)
            itemIndex += 1
            origin += self.itemSpacing
        }
        return layoutAttributes
        
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = BHPagerViewLayoutAttributes(forCellWith: indexPath)
        let frame = self.frame(for: indexPath)
        //print("indexPath\(indexPath)")
        //print("frame\(frame)")
        let center = CGPoint(x: frame.midX, y: frame.midY)
        attributes.center = center
        attributes.size = self.actualItemSize
        return attributes
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
    
    internal func forceInvalidate() {
        self.needsReprepare = true
        self.invalidateLayout()
    }
    
    //MARK: -Private
    
    fileprivate func applyTransform(to attributes: BHPagerViewLayoutAttributes, with transformer: BHPagerViewTransformer?) {
        print("Apply transform to atributes \(attributes.indexPath)")
        guard let collectionView = self.collectionView else {
            return
        }
        guard let transformer = transformer else {
            return
        }
        switch  self.scrollDirection {
        case .horizontal:
            let ruler = collectionView.bounds.midX
            print("Ruler\(ruler)")
            attributes.position = (attributes.center.x - ruler)/self.itemSpacing
            print("Att position \(attributes.position)")
        case .vertical:
            let ruler = collectionView.bounds.midY
            attributes.position = (attributes.center.y-ruler)/self.itemSpacing
        }
        attributes.zIndex = Int(self.numberOfItems)-Int(attributes.position)
        transformer.applyTransform(to: attributes)
    }


    
    
}
