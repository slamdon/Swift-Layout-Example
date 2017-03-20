//
//  WorldHeritageStore.swift
//  ParallaxGallery
//
//  Created by don chen on 2017/3/18.
//  Copyright © 2017年 Don Chen. All rights reserved.
//

import Foundation

class WorldHeritageStore {
    static let shared = WorldHeritageStore()
    
    fileprivate let places = ["富冈制丝厂及产业遗产群","小笠原群岛","石见银山","知床半岛","纪伊山地的灵场和参拜道","日光的神社与寺院","古都奈良的文化财","严岛神社","白神山地","屋久岛","姬路城","法隆寺地域的佛教建筑物","波斯坎儿井","卢特沙漠","苏萨","梅满德文化景观","被焚之城","古列斯坦宫","贡巴德·卡武斯高塔","伊斯法罕的聚礼清真寺","波斯花园","大不里士历史巴扎建筑群","舒希达历史水力系统","贝希斯敦","苏丹尼耶","巴姆及其文化景观","帕萨尔加德","塔赫特苏莱曼","伊斯法罕的伊玛目广场","波斯波利斯","恰高·占比尔","洛伦茨国家公园","桑吉兰早期人类地点","巴兰班南寺院群","科莫多国家公园","乌戎库隆国家公园","那烂陀寺考古遗址","干城章嘉国家公园","拉贾斯坦邦的山地要塞","西高止山脉","斋浦尔的简塔·曼塔","红堡建筑群","比莫贝特卡岩荫群","顾特卜塔","德里的胡马雍陵","桑吉的佛教古迹","孙德尔本斯国家公园","象岛石窟","帕塔达卡尔古迹组群","法塔赫布尔西格里","亨比古迹组群","克久拉霍古迹组群","果阿的教堂和会院","凯奥拉德奥国家公园","玛纳斯野生生物禁猎区","加济兰加国家公园","默哈伯利布勒姆古迹组群","科纳克的太阳神庙","泰姬陵","阿格拉堡","埃洛拉石窟","阿旖陀石窟"]
    
    private init(){}
    
    func getList() -> [WorldHeritageModel] {
        // 圖片有57張
        let itemsCount = min(places.count - 1, 57)
        
        var items = [WorldHeritageModel]()
        for pos in 0..<itemsCount {
            // 1900 - 2017
            let year = 1900 + arc4random()%117
            
            // 1 - 12
            let month = 1 + arc4random()%12
            
            // 1 - 31
            let day = 1 + arc4random()%30
            
            // YYYY-MM-dd
            let date = "\(year)-\(month)-\(day)"
            
            let item = WorldHeritageModel(placeName: places[pos], imageName: "bg-\(pos)", date: date)
            items.append(item)
        }
        return items
        
    }
    
}
