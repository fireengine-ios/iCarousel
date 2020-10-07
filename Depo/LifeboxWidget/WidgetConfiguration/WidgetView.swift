//
//  WidgetView.swift
//  Depo
//
//  Created by Roman Harhun on 01/09/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import SwiftUI
import WidgetKit

fileprivate enum WidgetViewContants {
    static let gradientBackgroundColors = [
        Color(red: 0 / 255, green: 72 / 255, blue: 115 / 255),
        Color(red: 68 / 255, green: 205 / 255, blue: 208 / 255)
    ]
    
    static var smallButtonHeight: CGFloat {
        !Device.isIpad && UIScreen.main.bounds.height > 700 ? 36 : 30
    }
    
    static var mediumButtonHeight: CGFloat {
        Device.isIphoneSmall ? 40 : 44
    }
    
    static var smallImageSide: CGFloat {
        Device.isIphoneSmall ? 22 : 27
    }
    
    static var smallSyncImageSize: CGSize {
        Device.isIphoneSmall ? CGSize(width: 12, height: 17) : CGSize(width: 16, height: 22)
    }
    
    static var contentOffset: EdgeInsets {
        Device.isIphoneSmall ? EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12) : EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    }
}

struct WidgetView: View {
    @Environment(\.widgetFamily) var family
    
    let entry: WidgetProvider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            WidgetSmallSizeView(entry: entry)
        default:
            WidgetMediumSizeView(entry: entry)
        }
    }
}

//MARK: - Configuration Data to Small View
struct WidgetSmallSizeView: View {
    let entry: WidgetProvider.Entry
    
    var body: some View {
        switch entry {
        case let entry as WidgetQuotaEntry:
            WidgetQuotaSmallView(entry: entry)
            
        case let entry as WidgetContactBackupEntry:
            WidgetContactBackedupSmallView(entry: entry)
            
        case let entry as WidgetDeviceQuotaEntry:
            WidgetDeviceQuotaSmallView(entry: entry)
            
        case let entry as WidgetUserInfoEntry:
            WidgetFaceRecognitionSmallView(entry: entry)

        case let entry as WidgetAutoSyncEntry:
            WidgetAutoSyncStatusSmallView(entry: entry)
            
        case let entry as WidgetSyncInProgressEntry:
            WidgetSyncInProgressSmallView(entry: entry)

        default:
            WidgetLoginRequiredSmallView()
        }
    }
}

//MARK:- Configuration Data to Medium View
struct WidgetMediumSizeView: View {
    let entry: WidgetProvider.Entry
    
    var body: some View {
        switch entry {
        case let entry as WidgetQuotaEntry:
            WidgetQuotaMediumView(entry: entry)
            
        case let entry as WidgetContactBackupEntry:
            WidgetContactBackedupMediumView(entry: entry)
            
        case let entry as WidgetDeviceQuotaEntry:
            WidgetDeviceQuotaMediumView(entry: entry)
            
        case let entry as WidgetUserInfoEntry:
            WidgetFaceRecognitionMediumView(entry: entry)
            
        case let entry as WidgetAutoSyncEntry:
            WidgetAutoSyncStatusMediumView(entry: entry)
            
        case let entry as WidgetSyncInProgressEntry:
            WidgetSyncInProgressMediumView(entry: entry)
            
        default:
            WidgetLoginRequiredMediumView()
        }
    }
}

//MARK: - Rule 0 - WidgetLoginRequiredView
struct WidgetLoginRequiredSmallView: View {
    var body: some View {
        WidgetEntrySmallView(imageName: "sign_in",
                             title: "",
                             description: TextConstants.widgetRule0SmallDetail,
                             titleButton: TextConstants.widgetRule0SmallButton,
                             action: .widgetLogout)
    }
}

struct WidgetLoginRequiredMediumView: View {
    var body: some View {
        WidgetEntryMediumView(imageName: "sign_in",
                              title: "",
                              description: TextConstants.widgetRule0MediumDetail,
                              titleButton: TextConstants.widgetRule0MediumButton,
                              action: .widgetLogout)
    }
}

//MARK:  - Rule 1 - WidgetQuotaView
struct WidgetQuotaSmallView: View {
    var entry: WidgetQuotaEntry
    
    var body: some View {
        WidgetEntrySmallView(imageName: "cloud_storage",
                             title: String(format: TextConstants.widgetRule1SmallTitle, entry.usedPercentage),
                             description: TextConstants.widgetRule1SmallDetail,
                             titleButton: TextConstants.widgetRule1SmallButton,
                             percentage: CGFloat(entry.usedPercentage)/100,
                             action: .widgetQuota)
    }
}

struct WidgetQuotaMediumView: View {
    var entry: WidgetQuotaEntry
    
    var body: some View {
        WidgetEntryMediumView(imageName: "cloud_storage",
                              title: TextConstants.widgetRule1MediumTitle,
                              description: TextConstants.widgetRule1MediumDetail,
                              titleButton: TextConstants.widgetRule1MediumButton,
                              percentage: CGFloat(entry.usedPercentage)/100,
                              action: .widgetQuota)
    }
}


//MARK: - Rule 2 - WidgetDeviceQuotaView
struct WidgetDeviceQuotaSmallView: View {
    var entry: WidgetDeviceQuotaEntry
    
    var body: some View {
        WidgetEntrySmallView(imageName: "device_storage",
                             title: String(format: TextConstants.widgetRule2SmallTitle, entry.usedPercentage),
                             description: TextConstants.widgetRule2SmallDetail,
                             titleButton: TextConstants.widgetRule2SmallButton,
                             percentage: CGFloat(entry.usedPercentage)/100,
                             action: .widgetFreeUpSpace)
    }
}

struct WidgetDeviceQuotaMediumView: View {
    var entry: WidgetDeviceQuotaEntry
    
    var body: some View {
        WidgetEntryMediumView(imageName: "device_storage",
                              title: TextConstants.widgetRule2MediumTitle,
                              description: TextConstants.widgetRule2MediumDetail,
                              titleButton: TextConstants.widgetRule2MediumButton,
                              percentage: CGFloat(entry.usedPercentage)/100,
                              action: .widgetFreeUpSpace)
    }
}

// MARK: - Rule 3 - Sync in progress
// 3-1 - sync in progress
// 3-2 - sync is complete

struct WidgetSyncInProgressSmallView: View {
    let entry: WidgetSyncInProgressEntry

    var body: some View {
        if entry.state == .syncComplete {
            WidgetSyncSmallView(detail: TextConstants.widgetRule32SmallDetail,
                                titleButton: TextConstants.widgetRule32SmallButton,
                                action: .widgetSyncInProgress)
        } else {
            WidgetSyncSmallView(detail: String(format: TextConstants.widgetRule31SmallDetail, entry.uploadCount, entry.totalCount, entry.currentFileName),
                                titleButton: TextConstants.widgetRule31SmallButton,
                                action: .widgetSyncInProgress)
        }
    }
}

struct WidgetSyncInProgressMediumView: View {
    let entry: WidgetSyncInProgressEntry
    
    var body: some View {
        if entry.state == .syncComplete {
            WidgetSyncMediumView(imageName: "widget_medium_sync",
                                 detail: TextConstants.widgetRule32MediumDetail,
                                 titleButton: TextConstants.widgetRule32MediumButton,
                                 action: .widgetSyncInProgress)
        } else {
            WidgetSyncMediumView(imageName: "widget_medium_sync",
                                 detail: String(format: TextConstants.widgetRule31MediumDetail, entry.uploadCount, entry.totalCount, entry.currentFileName),
                                 titleButton: TextConstants.widgetRule31MediumButton,
                                 action: .widgetSyncInProgress)
        }
    }
}

// MARK: - Rule 4 AutoSync status
// 4-1 - waiting for enable autosync
// 4-2 - waiting for launch app

struct WidgetAutoSyncStatusSmallView: View {
    let entry: WidgetAutoSyncEntry
    var body: some View {
        if entry.state == .autosyncDisable {
            WidgetSyncSmallView(detail: TextConstants.widgetRule41SmallDetail,
                                titleButton: TextConstants.widgetRule41SmallButton,
                                action: .widgetAutoSyncDisabled)
        } else {
            WidgetSyncSmallView(detail: TextConstants.widgetRule42SmallDetail,
                                titleButton: TextConstants.widgetRule42SmallButton,
                                action: .widgetUnsyncedFiles)
        }
    }
}

struct WidgetAutoSyncStatusMediumView: View {
    let entry: WidgetAutoSyncEntry
    var body: some View {
        if entry.state == .autosyncDisable {
            WidgetSyncMediumView(imageName: "widget_medium_synced",
                                 detail: TextConstants.widgetRule41MediumDetail,
                                 titleButton: TextConstants.widgetRule41MediumButton,
                                 action: .widgetAutoSyncDisabled)
        } else {
            WidgetSyncMediumView(imageName: "widget_medium_synced",
                                 detail: TextConstants.widgetRule42MediumDetail,
                                 titleButton: TextConstants.widgetRule42MediumButton,
                                 action: .widgetUnsyncedFiles)
        }
    }
}

struct WidgetSyncSmallView: View {
    let imageName = "widget_small_sync"
    let detail: String
    let titleButton: String
    let action: PushNotificationAction
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: WidgetViewContants.smallSyncImageSize.width,
                           height: WidgetViewContants.smallSyncImageSize.height,
                           alignment: .center)
                
                VStack(alignment: .leading, content: {
                    Text(detail)
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .lineSpacing(3)
                    Spacer(minLength: 0)
                })
                
                WidgetButton(title: titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: WidgetViewContants.smallButtonHeight, alignment: .leading)
            }
            .padding(WidgetViewContants.contentOffset)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: WidgetViewContants.gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
            .widgetURL(URL(string: SharedConstants.applicationQueriesScheme + action.rawValue))
        }
    }
}

struct WidgetSyncMediumView: View {
    let imageName: String
    let detail: String
    let titleButton: String
    let action: PushNotificationAction
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                HStack(spacing: 14) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(minWidth: 0, maxWidth: 60, minHeight: 0, maxHeight: 90, alignment: .top)
                    WidgetMediumInfoView(title: "", description: detail, spacing: 4)
                }
                
                Spacer(minLength: 0)
                WidgetButton(title: titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: WidgetViewContants.mediumButtonHeight, alignment: .leading)
            }
            .padding(WidgetViewContants.contentOffset)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: WidgetViewContants.gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
            .widgetURL(URL(string: SharedConstants.applicationQueriesScheme + action.rawValue))
        }
    }
}

//MARK: - Rule 5/6 - WidgetBackedupContactsView

struct WidgetContactBackedupSmallView: View {
    var entry: WidgetContactBackupEntry
    
    var body: some View {
        if entry.state == .contactsOldBackup {
            let format = entry.monthSinceLastBackup == 1 ? TextConstants.widgetRule6SmallDetail : TextConstants.widgetRule6SmallDetailPlural
            WidgetEntrySmallView(imageName: "back_up_small",
                                 title: "",
                                 description: String(format: format, entry.monthSinceLastBackup),
                                 titleButton: TextConstants.widgetRule6SmallButton,
                                 action: .widgetOldBackup)
        } else {
            WidgetEntrySmallView(imageName: "back_up_small",
                                 title: "",
                                 description: TextConstants.widgetRule5SmallDetail,
                                 titleButton: TextConstants.widgetRule5SmallButton,
                                 action: .widgetNoBackup)
        }
    }
}

struct WidgetContactBackedupMediumView: View {
    var entry: WidgetContactBackupEntry
    
    var body: some View {
        let imageName = "back_up_medium"
        let data = entryData()
        
        GeometryReader { geo in
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(minWidth: 0, maxWidth: 48, minHeight: 0, maxHeight: 90, alignment: .top)
                        .padding(.top, 8)
                    WidgetMediumInfoView(title: data.title, description: data.description)
                }
                .padding(.leading, 8)
                
                WidgetButton(title: data.titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: WidgetViewContants.mediumButtonHeight, alignment: .leading)
            }
            .padding(WidgetViewContants.contentOffset)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: WidgetViewContants.gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
            .widgetURL(URL(string: SharedConstants.applicationQueriesScheme + data.action.rawValue))
        }
    }
    
    func entryData() -> (title: String, description: String, titleButton: String, action: PushNotificationAction) {
        if entry.state == .contactsOldBackup {
            let format = entry.monthSinceLastBackup == 1 ? TextConstants.widgetRule6MediumDetail : TextConstants.widgetRule6SmallDetailPlural
            return (title: "",
                    description: String(format: format, entry.monthSinceLastBackup),
                    titleButton: TextConstants.widgetRule6MediumButton,
                    action: .widgetOldBackup)
        } else {
            return (title: TextConstants.widgetRule5MediumTitle,
                    description: TextConstants.widgetRule5MediumDetail,
                    titleButton: TextConstants.widgetRule5MediumButton,
                    action: .widgetNoBackup)
        }
    }
}

//MARK: - Rule 7 - Face Image Recognition

struct WidgetFaceRecognitionSmallView: View {
    let entry: WidgetUserInfoEntry
    var body: some View {
        let data = entryData()
        let imageSide: CGFloat = 24
        
        GeometryReader { geo in
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: -10) {
                    ForEach(entry.images.indices, id: \.self) { index in
                        if index == 2 && entry.state == .firLess3People {
                            Image(uiImage: entry.images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: imageSide, height: imageSide, alignment: .center)
                        } else {
                            Image(uiImage: entry.images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                .frame(width: imageSide, height: imageSide, alignment: .center)
                        }
                    }
                }

                VStack(alignment: .leading) {
                    Text(data.title)
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .semibold, design: .default)) +
                    Text(data.description)
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .regular, design: .default))
                    Spacer(minLength: 0)
                }
                WidgetButton(title: data.titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: WidgetViewContants.smallButtonHeight, alignment: .center)
            }
            .padding(WidgetViewContants.contentOffset)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: WidgetViewContants.gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
            .widgetURL(URL(string: SharedConstants.applicationQueriesScheme + data.action.rawValue))
        }
    }
    
    func entryData() -> (title: String, description: String, titleButton: String, action: PushNotificationAction) {
        switch entry.state {
        case .fir:
            return (title: TextConstants.widgetRule71SmallTitle,
                    description: TextConstants.widgetRule71SmallDetail,
                    titleButton: TextConstants.widgetRule71SmallButton,
                    action: .widgetFIR)
        case .firLess3People:
            return (title: TextConstants.widgetRule72SmallTitle,
                    description: TextConstants.widgetRule72SmallDetail,
                    titleButton: TextConstants.widgetRule72SmallButton,
                    action: .widgetFIRLess3People)
        case .firDisabled:
            return (title: "",
                    description: TextConstants.widgetRule73SmallDetail,
                    titleButton: TextConstants.widgetRule73SmallButton,
                    action: .widgetFIRDisabled)
        default:
            return (title: "",
                    description: TextConstants.widgetRule74SmallDetail,
                    titleButton: TextConstants.widgetRule74SmallButton,
                    action: .widgetFIRStandart)
        }
    }
}

struct WidgetFaceRecognitionMediumView: View {
    let entry: WidgetUserInfoEntry
    var body: some View {
        let data = entryData()
        let imageSide: CGFloat = 57
        
        GeometryReader { geo in
            VStack(alignment: .center) {
                HStack(alignment: .top, spacing: 10) {
                    HStack(spacing: -25) {
                        ForEach(entry.images.indices, id: \.self) { index in
                            if index == 2 && entry.state == .firLess3People {
                                Image(uiImage: entry.images[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: imageSide, height: imageSide, alignment: .center)
                            } else {
                                Image(uiImage: entry.images[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .frame(width: imageSide, height: imageSide, alignment: .center)
                            }
                        }
                    }
                    .frame(width: .infinity, height: imageSide, alignment: .top)

                    WidgetMediumInfoView(title: data.title, description: data.description, inOneText: true)
                }
                Spacer()
                WidgetButton(title: data.titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: WidgetViewContants.mediumButtonHeight, alignment: .leading)
            }
            .padding(WidgetViewContants.contentOffset)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: WidgetViewContants.gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
            .widgetURL(URL(string: SharedConstants.applicationQueriesScheme + data.action.rawValue))
        }
    }
    
    func entryData() -> (title: String, description: String, titleButton: String, action: PushNotificationAction) {
        switch entry.state {
        case .fir:
            return (title: TextConstants.widgetRule71MediumTitle,
                    description: TextConstants.widgetRule71MediumDetail,
                    titleButton: TextConstants.widgetRule71MediumButton,
                    action: .widgetFIR)
        case .firLess3People:
            return (title: TextConstants.widgetRule72MediumTitle,
                    description: TextConstants.widgetRule72MediumDetail,
                    titleButton: TextConstants.widgetRule72MediumButton,
                    action: .widgetFIRLess3People)
        case .firDisabled:
            return (title: "",
                    description: TextConstants.widgetRule73MediumDetail,
                    titleButton: TextConstants.widgetRule73MediumButton,
                    action: .widgetFIRDisabled)
        default:
            return (title: "",
                    description: TextConstants.widgetRule74MediumDetail,
                    titleButton: TextConstants.widgetRule74MediumButton,
                    action: .widgetFIRStandart)
        }
    }
}

// MARK: - Common Views
// MARK: - WidgetEntrySmallView

struct WidgetEntrySmallView : View {
    var imageName: String
    var title: String
    var description: String
    var titleButton: String
    var percentage: CGFloat?
    let action: PushNotificationAction
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                if let percentage = percentage {
                    ProgressBarSmall(imageName: imageName, progress: percentage)
                        .frame(height: 12, alignment: .center)
                    Spacer(minLength: 16)
                } else {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: WidgetViewContants.smallImageSide, height: WidgetViewContants.smallImageSide, alignment: .center)
                }
                
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .semibold, design: .default)) +
                    Text(description)
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .regular, design: .default))
                    Spacer(minLength: 0)
                }

                WidgetButton(title: titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: WidgetViewContants.smallButtonHeight, alignment: .center)
            }
            .padding(WidgetViewContants.contentOffset)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: WidgetViewContants.gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
            .widgetURL(URL(string: SharedConstants.applicationQueriesScheme + action.rawValue))
        }
    }
}

//MARK: - WidgetEntryMediumView

struct WidgetEntryMediumView : View {
    var imageName: String
    var title: String
    var description: String
    var titleButton: String
    var percentage: CGFloat?
    var countSyncFiles: Int?
    let action: PushNotificationAction
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center) {
                HStack(spacing: 16) {
                    if let percentage = percentage {
                        ProgressBarMedium(imageName: imageName, progress: percentage)
                            .frame(width: 57, height: 57, alignment: .leading)
                    } else {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(minWidth: 0, maxWidth: 54, minHeight: 0, maxHeight: 90, alignment: .top)
                    }

                    WidgetMediumInfoView(title: title, description: description)
                }
                
                Spacer()
                WidgetButton(title: titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: WidgetViewContants.mediumButtonHeight, alignment: .leading)
            }
            .padding(WidgetViewContants.contentOffset)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: WidgetViewContants.gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
            .widgetURL(URL(string: SharedConstants.applicationQueriesScheme + action.rawValue))
        }
    }
}

// MARK: - Custom Button

struct WidgetButton: View {
    var title: String
    var cornerRadius: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white)
                .opacity(0.2)
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .bold, design: .default))
        }
    }
}

//MARK: - Text View

struct CirclePercentageViewSmall: View {
    var percentage: Int

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var startAnimation = -500
    var body: some View {
        ZStack{
            Circle()
                .fill()
                .foregroundColor(Color(red: 60 / 255, green: 190 / 255, blue: 191 / 255))
                .frame(width: 600, height: 600, alignment: .center)
                .offset(x: -300, y: 0)
                .animation(.linear)
                .onReceive(timer) { _ in
                    self.offset(x: -200, y: 0)
                }

        }
        .background(LinearGradient(gradient: Gradient(colors: WidgetViewContants.gradientBackgroundColors), startPoint: UnitPoint(x: 0.1, y: 0.1), endPoint: UnitPoint(x: 1.2, y: 1.2)))
        .frame(width: .infinity, height: .infinity, alignment: .center)
    }
}

// MARK: - ProgressBarSmall

struct ProgressBarSmall: View {
    let imageName: String
    let progress: CGFloat
    var body: some View {
        let imageSide: CGFloat = 25
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: 6)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.black))
                    .cornerRadius(3)
                Rectangle().frame(width: min(CGFloat(progress)*geometry.size.width, geometry.size.width), height: 6)
                    .foregroundColor(Color(UIColor.white))
                    .animation(.linear)
                    .cornerRadius(3)
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageSide, height: imageSide, alignment: .center)
                    .offset(x: min(CGFloat(progress)*geometry.size.width - imageSide * 0.5, geometry.size.width), y: 0)
            }
        }
    }
}

// MARK: - ProgressBarMedium

struct ProgressBarMedium: View {
    let imageName: String
    let progress: CGFloat
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(lineWidth: 6)
                    .opacity(0.3)
                    .foregroundColor(Color.black)
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.white)
                    .rotationEffect(Angle(degrees: 270.0))
                    .rotation3DEffect(
                        .degrees(180),
                        axis: /*@START_MENU_TOKEN@*/(x: 0.0, y: 1.0, z: 0.0)/*@END_MENU_TOKEN@*/
                    )
                    .animation(.linear)
                Text(String(format: "%.0f", min(progress, 1.0)*100.0))
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(.white) +
                Text("%")
                    .font(.system(size: 10, weight: .regular, design: .default))
                    .foregroundColor(.white)
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 29, height: 29, alignment: .center)
                    .offset(x: 0, y: min(CGFloat(0.5) * geometry.size.width, geometry.size.width))
                    .rotationEffect(Angle(degrees: 180))
                
            }
        }
    }
}

struct WidgetMediumInfoView: View {
    let title: String
    let description: String
    var spacing: CGFloat = 6
    var titleWeight: Font.Weight = .semibold
    var descriptionWeight: Font.Weight = .regular
    var inOneText: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            if inOneText {
                (Text(title)
                    .font(.system(size: 14, weight: titleWeight, design: .default)) +
                Text(description)
                    .font(.system(size: 14, weight: descriptionWeight, design: .default)))
                    .foregroundColor(.white)
                    .lineSpacing(3)
                
            } else {
                VStack(alignment: .leading, spacing: spacing) {
                    if !title.isEmpty {
                        Text(title)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: titleWeight, design: .default))
                            .lineSpacing(3)
                    }
                    if !description.isEmpty {
                        Text(description)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: descriptionWeight, design: .default))
                            .lineSpacing(3)
                    }
                }
            }
        }
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            //Rule 0
            
//            WidgetLoginRequiredSmallView()
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetLoginRequiredMediumView()
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            //Rule 1
            
//            let quotaEntry = WidgetQuotaEntry(usedPercentage: 75, date: Date())
//            WidgetQuotaSmallView(entry: quotaEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetQuotaMediumView(entry: quotaEntry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            //Rule 2

//            let storageEntry = WidgetDeviceQuotaEntry(usedPercentage: 90, date: Date())
//            WidgetDeviceQuotaSmallView(entry: storageEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetDeviceQuotaMediumView(entry: storageEntry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            //Rule 3_1
//            let syncInProgressEntry = WidgetSyncInProgressEntry(uploadCount: 4, totalCount: 20, currentFileName: "Temp_file.heic", date: Date())
//            WidgetSyncInProgressSmallView(entry: syncInProgressEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetSyncInProgressMediumView(entry: syncInProgressEntry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            //Rule 3_2
            
//            let syncCompleteEntry = WidgetSyncInProgressEntry(uploadCount: 20, totalCount: 20, currentFileName: "Temp_file.heic", date: Date())
//            WidgetSyncInProgressSmallView(entry: syncCompleteEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetSyncInProgressMediumView(entry: syncCompleteEntry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            //Rule 4_1
            
//            let syncEntry = WidgetAutoSyncEntry(isSyncEnabled: false, date: Date())
//            WidgetAutoSyncStatusSmallView(entry: syncEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetAutoSyncStatusMediumView(entry: syncEntry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            //Rule 4_2
            
//            let autoSyncEntry = WidgetAutoSyncEntry(isSyncEnabled: true, date: Date())
//            WidgetAutoSyncStatusSmallView(entry: autoSyncEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetAutoSyncStatusMediumView(entry: autoSyncEntry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            //Rule 5
            
//            let backupEntry = WidgetContactBackupEntry(backupDate: nil, date: Date())
//            WidgetContactBackedupSmallView(entry: backupEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetContactBackedupMediumView(entry: backupEntry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            //Rule 6
            
//            let oldBackupEntry = WidgetContactBackupEntry(backupDate: Date().addingTimeInterval(-3000000),
//                                                          date: Date())
//            WidgetContactBackedupSmallView(entry: oldBackupEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetContactBackedupMediumView(entry: oldBackupEntry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))

            //Rule 7
            
//            let userInfoEntry = WidgetUserInfoEntry(isFIREnabled: true,
//                                                    hasFIRPermission: true,
//                                                    peopleInfos: [],
//                                                    date: Date())
//            WidgetFaceRecognitionSmallView(entry: userInfoEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetFaceRecognitionMediumView(entry: userInfoEntry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
