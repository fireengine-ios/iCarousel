//
//  WidgetView.swift
//  Depo
//
//  Created by Roman Harhun on 01/09/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import SwiftUI
import WidgetKit

private let gradientBackgroundColors = [
    Color(red: 0 / 255, green: 72 / 255, blue: 115 / 255),
    Color(red: 68 / 255, green: 205 / 255, blue: 208 / 255)
]

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
            WidgetAutoSyncStatusSmall(entry: entry)

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
            WidgetAutoSyncStatusMedium(entry: entry)
            
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
                             title: String(format: TextConstants.widgetRule2SmallTitle, entry.usedPersentage),
                             description: TextConstants.widgetRule2SmallDetail,
                             titleButton: TextConstants.widgetRule2SmallButton,
                             percentage: CGFloat(entry.usedPersentage)/100,
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
                              percentage: CGFloat(entry.usedPersentage)/100,
                              action: .widgetFreeUpSpace)
    }
}

// MARK: - Rule 3/4 AutoSync status

struct WidgetAutoSyncStatusSmall: View {
    let entry: WidgetAutoSyncEntry
    var body: some View {
        let imageName = "widget_small_sync"
        let title = entry.isSyncEnabled ? TextConstants.widgetRule42SmallTitle : ""
        let detail = entry.isSyncEnabled ? TextConstants.widgetRule42SmallDetail : TextConstants.widgetRule41SmallDetail
        let titleButton = entry.isSyncEnabled ? TextConstants.widgetRule42SmallButton : TextConstants.widgetRule41SmallButton
        let action: PushNotificationAction = entry.isSyncEnabled ? .widgetSyncInProgress : .widgetUnsyncedFiles

        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 14) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 16, height: 22, alignment: .center)
                
                VStack(alignment: .leading, spacing: 8, content: {
                    if !title.isEmpty {
                        Text(title)
                            .foregroundColor(.white)
                            .font(.system(size: 13, weight: .medium, design: .default))
                    }
                    Text(detail)
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .regular, design: .default))
                })

                Spacer()
                WidgetButton(title: titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: 36, alignment: .leading)
            }
            .padding(.all, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
            .widgetURL(URL(string: SharedConstants.applicationQueriesScheme + action.rawValue))
        }
    }
}

struct WidgetAutoSyncStatusMedium: View {
    let entry: WidgetAutoSyncEntry
    var body: some View {
        let imageName = entry.isSyncEnabled ? "widget_medium_sync" : "widget_medium_synced"
        let title = entry.isSyncEnabled ? TextConstants.widgetRule42MediumTitle : TextConstants.widgetRule41MediumDetail
        let detail = entry.isSyncEnabled ? TextConstants.widgetRule42MediumDetail : TextConstants.widgetRule41MediumDetailButton
        let titleButton = entry.isSyncEnabled ? TextConstants.widgetRule42MediumButton : TextConstants.widgetRule41MediumButton
        let action: PushNotificationAction = entry.isSyncEnabled ? .widgetSyncInProgress : .widgetUnsyncedFiles
        
        GeometryReader { geo in
            VStack(alignment: .leading) {
                HStack(spacing: 14) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(minWidth: 0, maxWidth: 60, minHeight: 0, maxHeight: 90, alignment: .top)
                    WidgetMediumInfoView(title: title,
                                         description: detail,
                                         spacing: 4,
                                         titleWeight: .regular,
                                         descriptionWeight: .semibold)
                }
                .padding(.top, 8)
                
                Spacer()
                WidgetButton(title: titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: 44, alignment: .leading)
            }
            .padding(.all, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
            .widgetURL(URL(string: SharedConstants.applicationQueriesScheme + action.rawValue))
        }
    }
}

//MARK: - Rule 5/6 - WidgetBackedupContactsView

struct WidgetContactBackedupSmallView: View {
    var entry: WidgetContactBackupEntry
    
    var body: some View {
        if let backupDate = entry.backupDate {
            let components = Calendar.current.dateComponents([.weekOfYear, .month], from: backupDate, to: Date())
            if components.month! >= 1 {
                WidgetEntrySmallView(imageName: "back_up_small",
                                     title: TextConstants.widgetRule6SmallTitle,
                                     description: TextConstants.widgetRule6SmallDetail,
                                     titleButton: TextConstants.widgetRule6SmallButton,
                                     action: .widgetOldBackup)
            }
        } else {
            WidgetEntrySmallView(imageName: "back_up_small",
                                 title: TextConstants.widgetRule5SmallDetail,
                                 description: "",
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
                    WidgetMediumInfoView(title: data.title, description: data.description)
                }
                .padding(.leading, 8)
                .padding(.top, 8)
                
                Spacer()
                WidgetButton(title: data.titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: 44, alignment: .leading)
            }
            .padding(.all, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
            .widgetURL(URL(string: SharedConstants.applicationQueriesScheme + data.action.rawValue))
        }
    }
    
    func entryData() -> (title: String, description: String, titleButton: String, action: PushNotificationAction) {
        var title = TextConstants.widgetRule5MediumTitle
        var description = TextConstants.widgetRule5MediumDetail
        var titleButton = TextConstants.widgetRule5MediumButton
        var action: PushNotificationAction = .widgetNoBackup
        
        if let backupDate = entry.backupDate {
            let components = Calendar.current.dateComponents([.weekOfYear, .month], from: backupDate, to: Date())
            if components.month! >= 1 {
                title = TextConstants.widgetRule6MediumTitle
                description = TextConstants.widgetRule6MediumDetail
                titleButton = TextConstants.widgetRule6MediumButton
                action = .widgetOldBackup
            }
        }

        return (title: title, description: description, titleButton: titleButton, action: action)
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
                        if index == 2 && entry.peopleInfos.count < 3 {
                            Image(uiImage: entry.images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: imageSide, height: imageSide, alignment: .center)
                        } else {
                            Image(uiImage: entry.images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                .frame(width: imageSide, height: imageSide, alignment: .center)
                        }
                    }
                }

                Text(data.description)
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .regular, design: .default))
                Spacer()
                WidgetButton(title: data.titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: 36, alignment: .center)
            }
            .padding(.all, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
            .widgetURL(URL(string: SharedConstants.applicationQueriesScheme + data.action.rawValue))
        }
    }
    
    func entryData() -> (description: String, titleButton: String, action: PushNotificationAction) {
        if entry.isPremiumUser && entry.isFIREnabled {
            if entry.images.count > 2 {
                return (description: TextConstants.widgetRule71SmallDetail,
                        titleButton: TextConstants.widgetRule71SmallButton,
                        action: .widgetFIRLess3People)
            } else {
                return (description: TextConstants.widgetRule72SmallDetail,
                        titleButton: TextConstants.widgetRule72SmallButton,
                        action: .widgetFIR)
            }
        } else if entry.isPremiumUser && !entry.isFIREnabled {
            return (description: TextConstants.widgetRule73SmallDetail,
                    titleButton: TextConstants.widgetRule73SmallButton,
                    action: .widgetFIRDisabled)
        }
        return (description: TextConstants.widgetRule74SmallDetail,
                titleButton: TextConstants.widgetRule74SmallButton,
                action: .widgetFIRStandart)
    }
}

struct WidgetFaceRecognitionMediumView: View {
    let entry: WidgetUserInfoEntry
    var body: some View {
        let data = entryData()
        let imageSide: CGFloat = 57
        
        GeometryReader { geo in
            VStack(alignment: .center) {
                HStack(spacing: 10) {
                    HStack(spacing: -25) {
                        ForEach(entry.images.indices, id: \.self) { index in
                            if index == 2 && entry.peopleInfos.count < 3 {
                                Image(uiImage: entry.images[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: imageSide, height: imageSide, alignment: .center)
                            } else {
                                Image(uiImage: entry.images[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .frame(width: imageSide, height: imageSide, alignment: .center)
                            }
                        }
                    }
                    .frame(width: .infinity, height: imageSide, alignment: .top)

                    WidgetMediumInfoView(title: "", description: data.description)
                        .frame(width: .infinity, height: imageSide, alignment: .top)
                }
                Spacer()
                WidgetButton(title: data.titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: 44, alignment: .leading)
            }
            .padding(.all, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
            .widgetURL(URL(string: SharedConstants.applicationQueriesScheme + data.action.rawValue))
        }
    }
    
    func entryData() -> (description: String, titleButton: String, action: PushNotificationAction) {
        if entry.isPremiumUser && entry.isFIREnabled {
            if entry.peopleInfos.count < 3 {
                return (description: TextConstants.widgetRule71MediumDetail,
                        titleButton: TextConstants.widgetRule71MediumButton,
                        action: .widgetFIRLess3People)
            } else {
                return (description: TextConstants.widgetRule72MediumDetail,
                        titleButton: TextConstants.widgetRule72MediumButton,
                        action: .widgetFIR)
            }
        } else if entry.isPremiumUser && !entry.isFIREnabled {
            return (description: TextConstants.widgetRule73MediumDetail,
                    titleButton: TextConstants.widgetRule73MediumButton,
                    action: .widgetFIRDisabled)
        }
        return (description: TextConstants.widgetRule74MediumDetail,
                titleButton: TextConstants.widgetRule74MediumButton,
                action: .widgetFIRStandart)
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
                        .frame(width: 27, height: 27, alignment: .center)
                }
                
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .semibold, design: .default)) +
                    Text(description)
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .regular, design: .default))
                    Spacer()
                }

                WidgetButton(title: titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: 36, alignment: .center)
            }
            .padding(.all, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
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
                        .padding(.top, 8)
                }
                
                Spacer()
                WidgetButton(title: titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: 44, alignment: .leading)
            }
            .padding(.all, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: gradientBackgroundColors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
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
        .background(LinearGradient(gradient: Gradient(colors: gradientBackgroundColors), startPoint: UnitPoint(x: 0.1, y: 0.1), endPoint: UnitPoint(x: 1.2, y: 1.2)))
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
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: spacing) {
                if !title.isEmpty {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: titleWeight, design: .default))
                }
                if !description.isEmpty {
                    Text(description)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: descriptionWeight, design: .default))
                }
                Spacer()
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

//            let storageEntry = WidgetDeviceQuotaEntry(usedPersentage: 90, date: Date())
//            WidgetDeviceQuotaSmallView(entry: storageEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetDeviceQuotaMediumView(entry: storageEntry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            //Rule 4_1
            
//            let syncEntry = WidgetAutoSyncEntry(hasUnsynced: true, isSyncEnabled: false, date: Date())
//            WidgetAutoSyncStatusSmall(entry: syncEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetAutoSyncStatusMedium(entry: syncEntry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            //Rule 4_2
            
//            let autoSyncEntry = WidgetAutoSyncEntry(hasUnsynced: true, isSyncEnabled: true, date: Date())
//            WidgetAutoSyncStatusSmall(entry: autoSyncEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//            WidgetAutoSyncStatusMedium(entry: autoSyncEntry)
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
//                                                    isPremiumUser: true,
//                                                    peopleInfos: [],
//                                                    images: [UIImage(named: "user-3")!,
//                                                             UIImage(named: "user-2")!,
//                                                             UIImage(named: "plusIcon")!],
//                                                    date: Date())
//            WidgetFaceRecognitionSmallView(entry: userInfoEntry)
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//
//            WidgetFaceRecognitionMediumView(entry: userInfoEntry)
//                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
