//
//  HomeViewController.swift
//  DynamicGridLayout
//
//  Created by don chen on 2017/3/13.
//  Copyright © 2017年 Don Chen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet var aCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: HomeFlowLayout!
    @IBOutlet weak var layoutSegment: UISegmentedControl!
    
    var items = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    // 切換UISectionControl來更換Layout
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            flowLayout.layoutType = .twoColumn
            
        case 1:
            flowLayout.layoutType = .threeColumn
            
        case 2:
            flowLayout.layoutType = .sixColumn
        
        case 3:
            flowLayout.layoutType = .twelve
        default:
            break
        }
        
        // 更換layout動畫
        UIView.animate(withDuration: 1, animations: { [unowned self] in
            self.aCollectionView.collectionViewLayout.invalidateLayout()
            
            self.aCollectionView.performBatchUpdates({ [unowned self] in
                self.aCollectionView.setCollectionViewLayout(self.flowLayout, animated: true)
            }, completion: nil)
        })
        
    }
    
    
    func setupView() {
        // 設定UICollectionView背景顏色
        aCollectionView.backgroundColor = UIColor(red: 56/255, green: 54/255, blue: 57/255, alpha: 1)
        
        // UICollectionView註冊HomeImageCell
        let imageNib = UINib(nibName: "HomeImageCell", bundle: nil)
        aCollectionView.register(imageNib, forCellWithReuseIdentifier: "imageCell")
        
        // 產生1000個圖片，圖片檔案從bg-0到bg-57
        var pos = 0
        for _ in 1...1000 {
            if let image = UIImage(named: "bg-\(pos)") {
                items.append(image)
            }
            
            pos += 1
            if pos == 58 {
                pos = 0
            }
            
        }
        
        flowLayout.items = items
        aCollectionView.collectionViewLayout = flowLayout
        
    }

}

// MARK: UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let aCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! HomeImageCell
        aCell.aImageView.image = items[indexPath.row]
        return aCell
        
    }
    
}
