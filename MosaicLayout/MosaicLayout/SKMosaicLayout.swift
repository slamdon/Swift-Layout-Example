//
//  SKMosaicLayout.swift
//  MosaicLayout
//
//  Created by don chen on 2017/4/1.
//  Copyright © 2017年 Don Chen. All rights reserved.
//

import UIKit

@objc enum SKMosaicCellSize:Int {
    case small
    case big
}

@objc protocol SKMosaicLayoutDelegate:UICollectionViewDelegate {
    
    @objc optional func mosaicCellSizeForItemAtIndexPath(indexPath:IndexPath) -> SKMosaicCellSize
    @objc optional func numberOfColumnsInSection(section:Int) -> Int
    @objc optional func insetForSectionAtIndex(section:Int) -> UIEdgeInsets
    @objc optional func interitemSpacingAtSection(section:Int) -> CGFloat
    
    @objc optional func collectionView(_:UICollectionView, layout:SKMosaicLayout, interitemSpacingForSectionAtIndex section:Int) -> CGFloat
    
    // Header/Footer
    @objc optional func headerShouldOverlayContent() -> Bool
    @objc optional func footerShouldOverlayContent() -> Bool
    @objc optional func collectionView(_:UICollectionView, layout collectionViewLayout:SKMosaicLayout, heightForHeaderInSection section:Int) -> CGFloat
    @objc optional func collectionView(_:UICollectionView, layout collectionViewLayout:SKMosaicLayout, heightForFooterInSection section:Int) -> CGFloat
    
}

class SKMosaicLayout: UICollectionViewFlowLayout {
    let kSKDefaultNumberOfColumnsInSection = 2
    let kSKDefaultHeaderFooterHeight:CGFloat = 0.0
    let kSKDefaultHeaderShouldOverlayContent = false
    let kSKDefaultFooterShouldOverlayContent = false
    
    let kSKDefaultCellSize:SKMosaicCellSize = .small
    weak var delegate:SKMosaicLayoutDelegate?
    
    // Array of cached layout attributes for each cell
    fileprivate var cellLayoutAttributes = [IndexPath:UICollectionViewLayoutAttributes]()
    
    // array of cached layout attributes for each supplementary view (header and footer)
    fileprivate var supplementaryLayoutAttributes = [IndexPath:UICollectionViewLayoutAttributes]()
    
    // A 2D array holding an array of columns heights for each section
    fileprivate var columnHeightsPerSection = [[CGFloat]]()
    
    fileprivate var collectionViewContentWidth:CGFloat {
        return self.collectionView!.bounds.size.width
    }
    
    override var collectionViewContentSize: CGSize {
        let width = collectionViewContentWidth
        var height:CGFloat = 0
        for sectionIndex in 0..<columnHeightsPerSection.count {
            let indexOfTallestColumn = indexOfTallestColumnInSection(section: sectionIndex)
            height += columnHeightsPerSection[sectionIndex][indexOfTallestColumn]
        }
        
        return CGSize(width: width, height: height)
    }
    
    
    override func prepare() {
        super.prepare()
        
        resetLayoutState()
        
        resetColumnHeightsPerSection()
        
        // Calculate layout attritbutes in each section
        for sectionIndex in 0..<collectionView!.numberOfSections {
            let interitemSpacing = interitemSpacingAtSection(section: sectionIndex)
            
            // Add top section insets
            growColumnHeightsBy(increase: insetForSectionAtIndex(section: sectionIndex).top, section: sectionIndex)
            
            // Add header view
            let headerLayoutAttribute = addLayoutAttributesForSupplementaryViewOfKind(kind: UICollectionElementKindSectionHeader,
                                                                                      indexPath: IndexPath(item: 0, section: sectionIndex))
            
            if !headerShouldOverlayContent() {
                growColumnHeightsBy(increase: headerLayoutAttribute.frame.size.height + interitemSpacing, section: sectionIndex)
            }
            
            // Calculate cell attributes in each section
            var smallMosaicCellIndexPathsBuffer = [IndexPath]()
            for cellIndex in 0..<collectionView!.numberOfItems(inSection: sectionIndex) {
                let cellIndexPath = IndexPath(item: cellIndex, section: sectionIndex)
                
                // Big or small
                let mosaicCellSize = mosaicCellSizeForItemAtIndexPath(indexPath: cellIndexPath)
                
                let indexOfShortestColumn = indexOfShortestColumnInSection(section: sectionIndex)
                
                if mosaicCellSize == .big {
                    // calculate big cell attributes, and add to cellLayoutAttributes
                    let layoutAttributes = addBigMosaicLayoutAttrbutesForIndexPath(cellIndexPath: cellIndexPath, inColumn: indexOfShortestColumn)
                    
                    let columnHeight = columnHeightsPerSection[sectionIndex][indexOfShortestColumn]
                    columnHeightsPerSection[sectionIndex][indexOfShortestColumn] = columnHeight + layoutAttributes.frame.size.height + interitemSpacing
                    
                } else if mosaicCellSize == .small {
                    smallMosaicCellIndexPathsBuffer.append(cellIndexPath)
                    
                    // Wait until small cell buffer is full (widths add up to one big cell), then add small cells to column heights array and layout attributes
                    if smallMosaicCellIndexPathsBuffer.count >= 2 {
                        let layoutAttributes = addSmallMosaicLayoutAttributesForIndexPath(cellIndexPath: smallMosaicCellIndexPathsBuffer[0],
                                                                                          inColumn: indexOfShortestColumn, bufferIndex: 0)
                        
                        _ = addSmallMosaicLayoutAttributesForIndexPath(cellIndexPath: smallMosaicCellIndexPathsBuffer[1],
                                                                       inColumn: indexOfShortestColumn, bufferIndex: 1)
                        
                        // Add to small cells to shortest column, and recalculate column height now that they've been added
                        let columnHeight = columnHeightsPerSection[sectionIndex][indexOfShortestColumn]
                        columnHeightsPerSection[sectionIndex][indexOfShortestColumn] = columnHeight + layoutAttributes.frame.size.height + interitemSpacing
                        smallMosaicCellIndexPathsBuffer.removeAll()
                    }
                }
                
            }
            
            // Handle remaining cells that didn't fill the buffer
            if smallMosaicCellIndexPathsBuffer.count > 0 {
                print("remain \(smallMosaicCellIndexPathsBuffer.count)")
                let indexOfShortestColumn = indexOfShortestColumnInSection(section: sectionIndex)
                let layoutAttributes = addSmallMosaicLayoutAttributesForIndexPath(cellIndexPath: smallMosaicCellIndexPathsBuffer[0],
                                                                                  inColumn: indexOfShortestColumn, bufferIndex: 0)
                
                // Add to small cells to shortest column, and recalculate column height now that they've been added
                let columnHeight = columnHeightsPerSection[sectionIndex][indexOfShortestColumn]
                columnHeightsPerSection[sectionIndex][indexOfShortestColumn] = columnHeight + layoutAttributes.frame.size.height + interitemSpacing
                smallMosaicCellIndexPathsBuffer.removeAll()
            }
            
            // Adds footer view
            let footerLayoutAttribute = addLayoutAttributesForSupplementaryViewOfKind(kind: UICollectionElementKindSectionFooter,
                                                                                      indexPath: IndexPath(item: 1, section: sectionIndex))
            
            if !footerShouldOverlayContent() {
                growColumnHeightsBy(increase: footerLayoutAttribute.frame.size.height, section: sectionIndex)
            }
            
            // Add bottom section insets, and remove extra added inset
            growColumnHeightsBy(increase: insetForSectionAtIndex(section: sectionIndex).bottom, section: sectionIndex)

        }
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        
        var attributesInRect = [UICollectionViewLayoutAttributes]()
        
        // cells
        for(_, attributes) in cellLayoutAttributes {
            if rect.intersects(attributes.frame) {
                attributesInRect.append(attributes)
            }
        }
        
        // supplementary views
        for(_, attributes) in supplementaryLayoutAttributes {
            if rect.intersects(attributes.frame) {
                attributesInRect.append(attributes)
            }
        }
        
        return attributesInRect
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        return cellLayoutAttributes[indexPath]!
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return supplementaryLayoutAttributes[indexPath]
    }
    
    fileprivate func resetColumnHeightsPerSection() {
        let sectionCount = self.collectionView!.numberOfSections
        
        for sectionIndex in 0..<sectionCount {
            let numberOfColumnsInSection = self.numberOfColumnsInSection(section: sectionIndex)
            var columnHeights = [CGFloat]()
            
            for _ in 0..<numberOfColumnsInSection {
                columnHeights.append(0)
            }
            columnHeightsPerSection.append(columnHeights)
        }
        
    }
    
    
}

// MARK: Orientation
extension SKMosaicLayout {
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView!.bounds
        
        // Invalidate if the bounds has changed
        if oldBounds.size != newBounds.size {
            prepare()
            return true
        }
        return false
    }
    
    fileprivate func resetLayoutState() {
        columnHeightsPerSection.removeAll()
        cellLayoutAttributes.removeAll()
        supplementaryLayoutAttributes.removeAll()
        
    }
    
}

// MARK: Helpers
// MARK: Layout Attributes Helper
extension SKMosaicLayout {
    
    // Calculates layout attributes for a small cell, adds to layout attributes array and returns it
    fileprivate func addSmallMosaicLayoutAttributesForIndexPath(cellIndexPath:IndexPath, inColumn column:Int, bufferIndex:Int) -> UICollectionViewLayoutAttributes {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: cellIndexPath)
        var frame = mosaicCellRectWithSize(mosaicCellSize: SKMosaicCellSize.small, atIndexPath: cellIndexPath, inColumn: column)
        
        // Account for first or second small mosaic cell
        let interitemSpacing = interitemSpacingAtSection(section: cellIndexPath.section)
        let cellWidth = cellHeightsForMosaicSize(mosaicCellSize: SKMosaicCellSize.small, section: cellIndexPath.section)
        frame.origin.x += (cellWidth + interitemSpacing) * CGFloat(bufferIndex)
        layoutAttributes.frame = frame
        
        cellLayoutAttributes[cellIndexPath] = layoutAttributes
        return layoutAttributes
    }
    
    // Calculates layout attributes for a big cell, adds to layout attributes array and returns it
    fileprivate func addBigMosaicLayoutAttrbutesForIndexPath(cellIndexPath:IndexPath, inColumn column:Int) -> UICollectionViewLayoutAttributes {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: cellIndexPath)
        
        let frame = mosaicCellRectWithSize(mosaicCellSize: SKMosaicCellSize.big, atIndexPath: cellIndexPath, inColumn: column)
        layoutAttributes.frame = frame
        
        cellLayoutAttributes[cellIndexPath] = layoutAttributes
        
        return layoutAttributes
    }
    
    fileprivate func mosaicCellRectWithSize(mosaicCellSize:SKMosaicCellSize, atIndexPath cellIndexPath:IndexPath, inColumn column:Int) -> CGRect {
        let sectionIndex = cellIndexPath.section
        
        let cellHeight = cellHeightsForMosaicSize(mosaicCellSize: mosaicCellSize, section: sectionIndex)
        let cellWidth = cellHeight
        let columnHeight = columnHeightsPerSection[sectionIndex][column]
        
        var originX = CGFloat(column) * columnWidthInSection(section: sectionIndex)
        let originY = verticalOffsetForSection(section: sectionIndex) + columnHeight
        
        // Factor in interitem spacing and insets
        let sectionInset:UIEdgeInsets = insetForSectionAtIndex(section: sectionIndex)
        let interitemSpacing = interitemSpacingAtSection(section: sectionIndex)
        originX += sectionInset.left
        originX += CGFloat(column) * interitemSpacing
        
        return CGRect(x: originX, y: originY, width: cellWidth, height: cellHeight)
    }
    
    fileprivate func addLayoutAttributesForSupplementaryViewOfKind(kind:String, indexPath:IndexPath) -> UICollectionViewLayoutAttributes {
        let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kind, with: indexPath)
        
        let sectionInset:UIEdgeInsets = insetForSectionAtIndex(section: indexPath.section)
        let originX = sectionInset.left
        var originY = verticalOffsetForSection(section: indexPath.section)
        let width = collectionViewContentWidth - sectionInset.left - sectionInset.right
        var height:CGFloat = 0.0
        
        if kind == UICollectionElementKindSectionHeader {
            height = heightsForHeaderAtSection(section: indexPath.section)
            
        } else if kind == UICollectionElementKindSectionFooter {
            height = heightsForFooterAtSection(section: indexPath.section)
            
            if footerShouldOverlayContent() {
                originY -= height
            }
        }
        
        let tallestColumnIndex = indexOfTallestColumnInSection(section: indexPath.section)
        let sectionColumnHeight = columnHeightsPerSection[indexPath.section][tallestColumnIndex]
        
        layoutAttributes.frame = CGRect(x: originX, y: sectionColumnHeight + originY, width: width, height: height)
        layoutAttributes.zIndex = 1
        
        supplementaryLayoutAttributes[indexPath] = layoutAttributes
        
        return layoutAttributes
        
    }
}


// MARK: Sizing Helpers
extension SKMosaicLayout {
    
   fileprivate func cellHeightsForMosaicSize(mosaicCellSize:SKMosaicCellSize, section:Int) -> CGFloat{
        let bigCellSize:CGFloat = columnWidthInSection(section: section)
        let interitemSpacing = interitemSpacingAtSection(section: section)
        return mosaicCellSize == SKMosaicCellSize.big ? bigCellSize : (bigCellSize - interitemSpacing) / 2.0
    }

    // The width of a column refers to the width of one SKMosaicSizeBig cell with interitem spacing
   fileprivate func columnWidthInSection(section:Int) -> CGFloat {
        let sectionInset:UIEdgeInsets = insetForSectionAtIndex(section: section)
        let combinedInterItemSpacing = CGFloat(numberOfColumnsInSection(section: section) - 1) * interitemSpacingAtSection(section: section)
        let combinedColumnWidth = collectionViewContentWidth - sectionInset.left - sectionInset.right - combinedInterItemSpacing
        
        return combinedColumnWidth / CGFloat(numberOfColumnsInSection(section: section))
    }

    fileprivate func verticalOffsetForSection(section:Int) -> CGFloat {
        var verticalOffset:CGFloat = 0.0
        
        // Add up heights of all previous sections to get vertical position of this section
        for i in 0..<section {
            let indexOfTallestColumn = indexOfTallestColumnInSection(section: i)
            let sectionHeight = columnHeightsPerSection[i][indexOfTallestColumn]
            verticalOffset += sectionHeight
        }
        
        return verticalOffset
    }
    
    fileprivate func growColumnHeightsBy(increase:CGFloat, section:Int) {
        var columnHeights = columnHeightsPerSection[section]
        for i in 0..<columnHeights.count {
            columnHeightsPerSection[section][i] = columnHeights[i] + increase
        }
        
    }

}

// MARK: Index Helpers
extension SKMosaicLayout {
    fileprivate func indexOfShortestColumnInSection(section:Int) -> Int {
        var columnHeights = columnHeightsPerSection[section]
        
        var indexOfShortestColumn = 0
        for i in 1..<columnHeights.count {
            if columnHeights[i] < columnHeights[indexOfShortestColumn] {
                indexOfShortestColumn = i
            }
        }
        return indexOfShortestColumn
    }
    
    fileprivate func indexOfTallestColumnInSection(section:Int) -> Int {
        var columnHeights = columnHeightsPerSection[section]
        
        var indexOfTallestColumn = 0
        for i in 1..<columnHeights.count {
            if columnHeights[i] > columnHeights[indexOfTallestColumn] {
                indexOfTallestColumn = i
            }
        }
        return indexOfTallestColumn
    }
}

// MARK: Delegates Wrappers
extension SKMosaicLayout {
    
    // cell size
    fileprivate func mosaicCellSizeForItemAtIndexPath(indexPath:IndexPath) -> SKMosaicCellSize {
        let cellSize = delegate?.mosaicCellSizeForItemAtIndexPath?(indexPath: indexPath)
        if cellSize != nil {
            return cellSize!
        } else {
            return kSKDefaultCellSize
        }
    }
    
    // number of column
    fileprivate func numberOfColumnsInSection(section:Int) -> Int {
        let columnCount = delegate?.numberOfColumnsInSection?(section: section)
        if columnCount != nil {
            return columnCount!
        } else {
            return kSKDefaultNumberOfColumnsInSection
        }
    }
    
    // inset for section
    fileprivate func insetForSectionAtIndex(section:Int) -> UIEdgeInsets {
        let inset = delegate?.insetForSectionAtIndex?(section: section)
        if inset != nil {
            return inset!
        } else {
            return UIEdgeInsets.zero
        }
    }
    
    fileprivate func interitemSpacingAtSection(section:Int) -> CGFloat {
        let interitemSpacing = delegate?.collectionView?(collectionView!, layout: self, interitemSpacingForSectionAtIndex: section)
        if interitemSpacing != nil {
            return interitemSpacing!
        } else {
            return 0.0
        }
        
    }
    
    fileprivate func heightsForHeaderAtSection(section:Int) -> CGFloat {
        let height = delegate?.collectionView!(collectionView!, layout: self, heightForHeaderInSection: section)
        if height != nil {
            return height!
        } else {
            return kSKDefaultHeaderFooterHeight
        }
    }
    
    fileprivate func heightsForFooterAtSection(section:Int) -> CGFloat {
        let height = delegate?.collectionView?(collectionView!, layout: self, heightForFooterInSection: section)
        if height != nil {
            return height!
        } else {
            return kSKDefaultHeaderFooterHeight
        }
        
    }
    
    fileprivate func headerShouldOverlayContent() -> Bool {
        let shouldOverlay = delegate?.headerShouldOverlayContent?()
        if shouldOverlay != nil {
            return shouldOverlay!
        } else {
            return kSKDefaultHeaderShouldOverlayContent
        }
    }
    
    
    fileprivate func footerShouldOverlayContent() -> Bool {
        let shouldOverlay = delegate?.footerShouldOverlayContent?()
        if shouldOverlay != nil {
            return shouldOverlay!
        } else {
            return kSKDefaultFooterShouldOverlayContent
        }
    }
    
}
