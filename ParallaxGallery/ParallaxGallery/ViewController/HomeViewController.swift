//
//  HomeViewController.swift
//  ParallaxGallery
//
//  Created by don chen on 2017/3/18.
//  Copyright © 2017年 Don Chen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var aCollectionView: UICollectionView!
    
    fileprivate var items = [WorldHeritageModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 畫面第一次出現時就先計算cell中的offset
        scrollViewDidScroll(aCollectionView)
    }
    
    fileprivate func setupView() {
        // 註冊 Xib
        let cellNib = UINib(nibName: "HomeCell", bundle: nil)
        aCollectionView.register(cellNib, forCellWithReuseIdentifier: "aCell")
        
        // 準備items
        let store = WorldHeritageStore.shared
        items = store.getList()
        
    }
}

// MARK: UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let aCell = aCollectionView.dequeueReusableCell(withReuseIdentifier: "aCell", for: indexPath) as? HomeCell {
            let item = items[indexPath.row]
            aCell.imageView.image = UIImage(named: item.imageName)
            aCell.titleLabel.text = item.placeName
            aCell.timeLabel.text = item.date
            return aCell
        }

        return UICollectionViewCell()
    }
    
}

// MARK: UICollectionVieDelegateFloLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 160)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: UIScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 當UICollectionView被拖動的時候，通知出現在畫面上的cell
        for cell in aCollectionView.visibleCells {
            if let homeCell = cell as? HomeCell {
                homeCell.cellOnTableView(collectionView: aCollectionView, didScrollOnView: view)
            }

        }
    }
}
