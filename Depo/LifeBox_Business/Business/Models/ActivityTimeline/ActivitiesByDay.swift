//
//  ActivitiesByDay.swift
//  Depo_LifeTech
//
//  Created by user on 9/18/17.
//  Copyright © 2017 LifeTech All rights reserved.
//

class ActivitiesByDay {
    let date: Date
    let days: Int
    var list: [ActivitiesByMinutesAndType] = []
    
    init(date: Date, days: Int) {
        self.date = date
        self.days = days
    }
    
    var count: Int {
        return list.reduce(list.count) { result, activity in
            return result + activity.list.count
        }
    }
    
    func object(at index: Int) -> ActivityTimelineServiceResponse? {
        if list.count < 1 {
            return nil
        }
        var totalCount = list[0].list.count
        if index < totalCount {
            return list[0].list[index]
        }
        var newIndex = index
        for i in 1 ..< list.count {
            totalCount += list[i].list.count
            newIndex -= list[i - 1].list.count
            if index < totalCount {
                return list[i].list[newIndex]
            }
        }
        return nil
    }
}
