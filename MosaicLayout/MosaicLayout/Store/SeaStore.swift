//
//  SeaStore.swift
//  MosaicLayout
//
//  Created by don chen on 2017/4/1.
//  Copyright © 2017年 Don Chen. All rights reserved.
//

import Foundation

class SeaStore {
    static let shared = SeaStore()
    private init(){}
    
    func getList() -> [String] {
        var imageNames = [String]()
        for i in 0...31 {
            imageNames.append("img-sea-\(i)")
        }
        
        return imageNames
        
    }
    
}
