//
//  HomeViewController.swift
//  MosaicLayout
//
//  Created by don chen on 2017/4/1.
//  Copyright © 2017年 Don Chen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var aCollectionView: UICollectionView!
    var imageNames = SeaStore.shared.getList()
    
    let mosaicLayout = SKMosaicLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerNib = UINib(nibName: "HomeHeaderView", bundle: nil)
        aCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView")
        
        let footerNib = UINib(nibName: "HomeFooterView", bundle: nil)
        aCollectionView.register(footerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView")
        
        let cellNib = UINib(nibName: "HomeImageCell", bundle: nil)
        aCollectionView.register(cellNib, forCellWithReuseIdentifier: "aCell")
        
        aCollectionView.collectionViewLayout = mosaicLayout
        mosaicLayout.delegate = self
        
        adjustContentInsets()
    }
    
    func adjustContentInsets() {
        let insets = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.size.height, left: 0, bottom: 0, right: 0)
        aCollectionView.contentInset = insets
        aCollectionView.scrollIndicatorInsets = insets
    }
}

// MARK: UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch (section) {
            case 0: return 22
            case 1: return 44
            default: return 123
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "aCell", for: indexPath) as! HomeImageCell
        let imageName = imageNames[indexPath.row % imageNames.count]
        cell.imageView.image = UIImage(named: imageName)
        cell.label.text = "\(indexPath.row)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath) as! HomeHeaderView
            headerView.titleLabel.text = "SECTION \((indexPath.section))"
            return headerView
        } else {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerView", for: indexPath) as! HomeFooterView
            let assetCount = collectionView.numberOfItems(inSection: indexPath.section)
            footerView.titleLabel.text = "\(assetCount) 張圖片"
            return footerView
        }
    }
}

// MARK: SKMosaicLayoutDelegate
extension HomeViewController: SKMosaicLayoutDelegate {
    
    func mosaicCellSizeForItemAtIndexPath(indexPath:IndexPath) -> SKMosaicCellSize {
        let size = (indexPath.item % 12 == 0) ? SKMosaicCellSize.big : SKMosaicCellSize.small;
        return size
    }
    
    func numberOfColumnsInSection(section:Int) -> Int {
        return 2
    }
    
    func insetForSectionAtIndex(section:Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0);
    }
    
    func collectionView(_:UICollectionView, layout:SKMosaicLayout, interitemSpacingForSectionAtIndex section:Int) -> CGFloat {
        return 2.0
    }
    
    // Header/Footer
    func collectionView(_:UICollectionView, layout collectionViewLayout:SKMosaicLayout, heightForHeaderInSection section:Int) -> CGFloat {
        return 44.0
    }
    
    func collectionView(_:UICollectionView, layout collectionViewLayout:SKMosaicLayout, heightForFooterInSection section:Int) -> CGFloat {
        return 44.0
    }
    
    func headerShouldOverlayContent() -> Bool {
        return false
    }
    
    func footerShouldOverlayContent() -> Bool {
        return false
    }
}

