//
//  HomeCell.swift
//  ParallaxGallery
//
//  Created by don chen on 2017/3/18.
//  Copyright © 2017年 Don Chen. All rights reserved.
//

import UIKit

class HomeCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }
    
    func cellOnTableView(collectionView:UICollectionView, didScrollOnView view:UIView) {

        // 取得cell在collectionView中，相對view座標系統的frame
        let rectInSuperview = collectionView.convert(self.frame, to: view)
        
        // 位移相對中心點的距離
        let distanceFromCenter = view.frame.height/2 - rectInSuperview.minY
        
        // 圖片大於cell高度的部分，也就是視差的高度
        let parallaxHeight = imageView.frame.height - frame.height
        
        // 以cell相對view中心點移動的距離，來計算視差的移動距離
        let move = (distanceFromCenter / view.frame.height) * parallaxHeight
        
        // 先將imageView向上移動一半的視差高度(difference/2)，然後根據move程度變化y的位置
        var imageRect = imageView.frame
        imageRect.origin.y = -(parallaxHeight/2) + move
        
        // 給予imageView一個新的frame，達到視差效果。
        imageView.frame = imageRect
    }

}
