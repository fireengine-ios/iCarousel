//
//  ActivityTimelineSectionsBuider.swift
//  Depo_LifeTech
//
//  Created by user on 9/18/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ActivityTimelineSectionsBuider {
    
    let heightForHeaderInSection: CGFloat = 44
    var numberOfBigSections: Int = 0
    
    private var timelineActivities: [ActivitiesByDay] = []

    private var minutesSectionsIndexPaths: [[Int]] = []
    
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
    
    func numberOfRows(in section: Int) -> Int {
        return timelineActivities[section].count
    }
    
    func setup(with activities: [ActivityTimelineServiceResponse]) {
        setupActivityByDays(with: activities)
        setupMinutesIndexPaths()
        numberOfBigSections = timelineActivities.count
    }
    
    func clear() {
        timelineActivities = []
        numberOfBigSections = timelineActivities.count
    }
    
    private func setupActivityByDays(with activities: [ActivityTimelineServiceResponse]) {
        
        for activity in activities {
            guard let date = activity.createdDate,
                let activityType = activity.activityType,
                activityType != .welcome /// activity is empty
                else { continue }
            let daysInDate = Calendar.current.component(.day, from: date)
            
            /// found existing activityByDays
            if let activityByDays = timelineActivities.first(where: { $0.days == daysInDate }) {
                
                if let activityByMinutesAndType = activityByDays.list.first(where: {
                    return ($0.date == date) && ($0.type == activityType)
                }) {
                    activityByMinutesAndType.list.append(activity)
                } else {
                    let activityByMinutesAndTypeNew = ActivitiesByMinutesAndType(date: date,
                                                                                 type: activityType)
                    activityByMinutesAndTypeNew.list.append(activity)
                    activityByDays.list.append(activityByMinutesAndTypeNew)
                }
                
            /// create new days section
            } else {
                
                let activityByDaysNew = ActivitiesByDay(date: date, days: daysInDate)
                timelineActivities.append(activityByDaysNew)
                
                /// https://wiki.life.com.by/display/LTFizy/Timeline+actions
                let activityTypeNew: ActivityType
                if activityType == .added, (activity.activityFileType == .directory) || (activity.activityFileType == .dir) {
                    activityTypeNew = .welcome
                } else {
                    activityTypeNew = activityType
                }
                
                let activityByMinutesAndTypeNew = ActivitiesByMinutesAndType(date: date,
                                                                             type: activityTypeNew)
                activityByMinutesAndTypeNew.list.append(activity)
                activityByDaysNew.list.append(activityByMinutesAndTypeNew)
            }
        }
    }
    
    private func setupMinutesIndexPaths() {
        minutesSectionsIndexPaths.removeAll()
        for activity in timelineActivities {
            var minutesIndexPathsNew = activity.list.map { $0.list.count }
            minutesIndexPathsNew.removeLast()
            minutesIndexPathsNew.insert(0, at: 0)
            for i in 1..<minutesIndexPathsNew.count {
                minutesIndexPathsNew[i] += minutesIndexPathsNew[i - 1] + 1
            }
            minutesSectionsIndexPaths.append(minutesIndexPathsNew)
        }
    }
    
    private func isMinutesSection(for indexPath: IndexPath) -> Int? {
        return minutesSectionsIndexPaths[indexPath.section].firstIndex(of: indexPath.row)
    }
    
    private func activityForRow(at indexPath: IndexPath) -> ActivityTimelineServiceResponse? {
        var objectIndex = indexPath.row
        for i in minutesSectionsIndexPaths[indexPath.section] {
            if i < indexPath.row {
                objectIndex -= 1
            } else {
                break
            }
        }
        guard let activitiesItemsSection = timelineActivities[safe: indexPath.section] else {
            return  nil
        }
        return activitiesItemsSection.object(at: objectIndex)
    }
    
    func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        
        if let minutesSectionIndex = isMinutesSection(for: indexPath) {
            let cell = tableView.dequeue(reusable: ActivityTimelineTimeCell.self, for: indexPath)
            if let activitySection = timelineActivities[safe: indexPath.section], let activity = activitySection.list[safe: minutesSectionIndex] {
                cell.timeLabel.text = timeDateFormater.string(from: activity.date)
                cell.fileTypeLabel.text = "\(timelineActivities[indexPath.section].list[minutesSectionIndex].list.count) \(TextConstants.activityTimelineFiles) \(activity.type.displayString)"
            }
            setupCell(cell)
            return cell
            
        } else {
            let cell = tableView.dequeue(reusable: ActivityTimelineFileCell.self, for: indexPath)
            if let activity = activityForRow(at: indexPath) {
                cell.fill(with: activity)
            }
            setupCell(cell)
            return cell
        }
    }
    
    private func setupCell(_ cell: UITableViewCell) {
        /// iPad, iOS 9
        /// https://stackoverflow.com/a/30561575/5893286
        cell.backgroundColor = cell.contentView.backgroundColor
    }
    
    func header(for tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let header = tableView.dequeue(reusableHeaderFooterView: ActivityTimelineHeader.self)
        guard let datesSection = timelineActivities[safe: section] else { return header }
        header.dayLabel.text = dayDateFormater.string(from: datesSection.date)
        return header
    }
}
