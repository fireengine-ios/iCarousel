//
//  SectionsBuider.swift
//  Depo_LifeTech
//
//  Created by user on 9/18/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SectionsBuider {
    
    var numberOfBigSections: Int = 0
    //    var numberOfSmallSections: Int = 0
    func numberOfRows(in section: Int) -> Int {
        return timelineActivities[section].count
    }
    
    private var timelineActivities: [ActivitiesByDay] = []

    private var minutesIndexPaths: [[Int]] = []
    
    private lazy var dayDateFormater: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd MMMM"
        df.locale = Locale.current
        return df
    }()
    private lazy var timeDateFormater: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        df.locale = Locale.current
        return df
    }()
    
    func isSmallSection(for indexPath: IndexPath) -> Bool {
        return minutesIndexPaths[indexPath.section].contains(indexPath.row)
    }
    
    func setup(with activities: [ActivityTimelineServiceResponse]) {
        setupActivityByDays(with: activities)
        setupMinutesIndexPaths()
        numberOfBigSections = timelineActivities.count
    }
    
    private func setupActivityByDays(with activities: [ActivityTimelineServiceResponse]) {
        
        for activity in activities {
            
            guard let date = activity.createdDate,
                let activityType = activity.activityType
                else { continue }
            let daysInDate = Calendar.current.component(.day, from: date)
            
            
            /// found
            if let activityByDays = timelineActivities.first(where: { $0.days == daysInDate }) {
                
                if let activityByMinutesAndType = activityByDays.list.first(where: {
                    return ($0.date == date) && ($0.type == activityType)
                }) {
                    activityByMinutesAndType.list.append(activity)
                } else {
                    let activityByMinutesAndTypeNew = ActivitiesByMinutesAndType(date: date,
                                                                                 minutes: 0,
                                                                                 type: activityType)
                    activityByMinutesAndTypeNew.list.append(activity)
                    activityByDays.list.append(activityByMinutesAndTypeNew)
                }
                
                /// create new days section
            } else {
                let activityByDaysNew = ActivitiesByDay(date: date, days: daysInDate)
                timelineActivities.append(activityByDaysNew)
                
                let activityByMinutesAndTypeNew = ActivitiesByMinutesAndType(date: date,
                                                                             minutes: 0,
                                                                             type: activityType)
                activityByMinutesAndTypeNew.list.append(activity)
                activityByDaysNew.list.append(activityByMinutesAndTypeNew)
            }
        }
    }
    
    private func setupMinutesIndexPaths() {
        minutesIndexPaths.removeAll()
        for activity in timelineActivities {
            var minutesIndexPathsNew = activity.list.map { $0.list.count }
            minutesIndexPathsNew.removeLast()
            minutesIndexPathsNew.insert(0, at: 0)
            for i in 1..<minutesIndexPathsNew.count {
                minutesIndexPathsNew[i] += minutesIndexPathsNew[i-1] + 1
            }
            minutesIndexPaths.append(minutesIndexPathsNew)
        }
    }
    
    func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        
//        if isSmallSection(for: indexPath) {
//            let activity = timelineActivities[indexPath.section]
//            let cell = tableView.dequeue(reusable: ActivityTimelineTimeCell.self, for: indexPath)
//            //            cell.timeLabel.text = timeDateFormater.string(from: activity.createdDate!)
//            //            cell.fileTypeLabel.text = activity.activityType!.rawValue
//            return cell
//        } else {
//
//        }
//
//        return UITableViewCell()
        
        guard let activity = timelineActivities[indexPath.section].object(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        if minutesIndexPaths[indexPath.section].contains(indexPath.row) {
            
            let cell = tableView.dequeue(reusable: ActivityTimelineTimeCell.self, for: indexPath)
            cell.timeLabel.text = timeDateFormater.string(from: activity.createdDate!)
            cell.fileTypeLabel.text = activity.activityType!.rawValue
            return cell
        }
        
        //        let activity = timelineActivities[indexPath.section].list[indexPath.row]
        let cell = tableView.dequeue(reusable: ActivityTimelineFileCell.self, for: indexPath)
        cell.fileNameLabel.text = activity.name
        
        return cell
    }
    
    func header(for tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let header = tableView.dequeue(reusableHeaderFooterView: ActivityTimelineHeader.self)
        header.dayLabel.text = dayDateFormater.string(from: timelineActivities[section].date)
        return header
    }
}
