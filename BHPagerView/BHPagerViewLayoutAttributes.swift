//
//  BHPagerViewLayoutAttributes.swift
//  BHPagerView
//
//  Created by mac on 19/05/17.
//  Copyright © 2017 Benjamin Halilovic. All rights reserved.
//

import UIKit

open class BHPagerViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    open var position: CGFloat = 0
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? BHPagerViewLayoutAttributes else {
            return false
        }
        var isEqual = super.isEqual(object)
        isEqual = isEqual && (self.position == object.position)
        return isEqual
    }
    
    open override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! BHPagerViewLayoutAttributes
        copy.position = self.position
        return copy
    }
}
