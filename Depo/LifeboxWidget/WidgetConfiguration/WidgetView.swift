//
//  WidgetView.swift
//  Depo
//
//  Created by Roman Harhun on 01/09/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import SwiftUI
import WidgetKit

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
            WidgetPremiumSmallView(entry: entry)
            
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
            WidgetPremiumMediumView(entry: entry)
            
        case let entry as WidgetAutoSyncEntry:
            WidgetAutoSyncStatusMeduium(entry: entry)
            
        default:
            WidgetLoginRequiredMediumView()
        }
    }
}

//MARK:- WidgetLoginRequiredView
struct WidgetLoginRequiredSmallView: View {
    var body: some View {
        WidgetEntrySmallView(imageName: "sign_in",
                             title: "",
                             description: "You are not signed in to lifebox",
                             titleButton: "Sign in")
    }
}

struct WidgetLoginRequiredMediumView: View {
    var body: some View {
        WidgetEntryMediumView(imageName: "sign_in",
                              title: "",
                              description: "You are not signed in to lifebox",
                              titleButton: "Sign in to lifebox")
    }
}

//MARK:- WidgetQuotaView
struct WidgetQuotaSmallView: View {
    var entry: WidgetQuotaEntry
    
    var body: some View {
        WidgetEntrySmallView(imageName: "",
                             title: "Your quota is over \(entry.usedPercentage)%.",
                             description: " Time to upgrade your plan.",
                             titleButton: "View plan",
                             percentage: CGFloat(entry.usedPercentage)/100)
    }
}

struct WidgetQuotaMediumView: View {
    var entry: WidgetQuotaEntry
    
    var body: some View {
        WidgetEntryMediumView(imageName: "",
                              title: "Your lifebox quota is nearly full",
                              description: " It's time to upgrade your plan.",
                              titleButton: "Free up space",
                              percentage: CGFloat(entry.usedPercentage)/100)
    }
}


//MARK:- WidgetDeviceQuotaView
struct WidgetDeviceQuotaSmallView: View {
    var entry: WidgetDeviceQuotaEntry
    
    var body: some View {
        WidgetEntrySmallView(imageName: "",
                             title: "Device storage is \(entry.usedPersentage)% used.",
                             description: " You need more space.",
                             titleButton: "Free up space",
                             percentage: CGFloat(entry.usedPersentage)/100)
    }
}

struct WidgetDeviceQuotaMediumView: View {
    var entry: WidgetDeviceQuotaEntry
    
    var body: some View {
        WidgetEntryMediumView(imageName: "",
                              title: "Running out of device storage!",
                              description: "You need space for new memories.",
                              titleButton: "View Plans",
                              percentage: CGFloat(entry.usedPersentage)/100)
    }
}

//MARK: - WidgetBackedupContactsView

struct WidgetContactBackedupSmallView: View {
    var entry: WidgetContactBackupEntry
    
    var body: some View {
        if let backupDate = entry.backupDate {
            let components = Calendar.current.dateComponents([.weekOfYear, .month], from: backupDate, to: Date())
            if components.month! >= 1 {
                WidgetEntrySmallView(imageName: "back_up_small",
                                     title: "It's over 1 month",
                                     description: " since your last contact backup",
                                     titleButton: "Back up")
            }
        } else {
            WidgetEntrySmallView(imageName: "back_up_small",
                                 title: "No backed up contacts.",
                                 description: "",
                                 titleButton: "Back up contacts")
        }
    }
}

struct WidgetContactBackedupMediumView: View {
    var entry: WidgetContactBackupEntry
    
    var body: some View {
        if let backupDate = entry.backupDate {
            let components = Calendar.current.dateComponents([.weekOfYear, .month], from: backupDate, to: Date())
            if  components.month! >= 1 {
                WidgetEntryMediumView(imageName: "back_up_medium", title: "It's over 1 month", description: " since your last contact backup", titleButton: "Back up")
            }
        } else {
            WidgetEntryMediumView(imageName: "back_up_medium", title: "No backed up contacts.", description: " Secure your contacts by backing them up.", titleButton: "Back up")
        }
    }
}


//MARK: - WidgetPRemiumView
struct WidgetPremiumSmallView: View {
    let entry: WidgetUserInfoEntry
    var body: some View {
        if entry.isPremiumUser && entry.isFIREnabled {
            WidgetEntrySmallView(imageName: "", title: "You have 7 people albums.", description: " Check them out", titleButton: "People albums", imagesNames: [
                "test3", "test3", "test3"
            ])
            
        } else if entry.isPremiumUser && !entry.isFIREnabled {
            WidgetEntrySmallView(imageName: "", title: "", description: "Group your photos easily by people!", titleButton: "Enable grouping", imagesNames: [
                "test3", "test3", "test3"
            ])
        } else {
            WidgetEntrySmallView(imageName: "", title: "", description: "Become premium to see people albums!", titleButton: "Become premium", imagesNames: [
                "test3", "test3", "test3"
            ])
        }
    }
}

struct WidgetPremiumMediumView: View {
    let entry: WidgetUserInfoEntry
    var body: some View {
        if entry.isPremiumUser && entry.isFIREnabled {
            WidgetEntryMediumView(imageName: "", title: "You have 7 people albums.", description: " Check them out", titleButton: "See people albums", imagesNames: [
                "test3", "test3", "test3"
            ])
            
        } else if entry.isPremiumUser && !entry.isFIREnabled {
            WidgetEntryMediumView(imageName: "", title: "What about grouping your photos easily by people?", description: "", titleButton: "Enable face-image grouping", imagesNames: [
                "test3", "test3", "test3"
            ])
        } else {
            WidgetEntryMediumView(imageName: "", title: "Become premium to see people albums!", description: "", titleButton: "Become premium", imagesNames: [
                "test3", "test3", "test3"
            ])
        }
    }
}



// MARK: - WidgetEntrySmallView
struct WidgetEntrySmallView : View {
    var imageName: String
    var title: String
    var description: String
    var titleButton: String
    var percentage: CGFloat?
    var imagesNames: [String]?
    
    var body: some View {
        let colors = [
            Color(red: 0 / 255, green: 52 / 255, blue: 88 / 255),
            Color(red: 62 / 255, green: 198 / 255, blue: 203 / 255)
        ]
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: nil) {
                if let percentage = percentage {
                    ProgressBarSmall(progress: percentage)
                        .frame(height: 12, alignment: .center)
                    
                } else {
                    if let imagesNames = imagesNames {
                        PremiumPeopleAlbums(imagesString: imagesNames)
                            .frame(width: geo.size.height/7, height: geo.size.height/7, alignment: .leading)
                            .padding(.top, 5)
                    } else {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: 25, minHeight: 0, maxHeight: 25, alignment: .leading)
                    }
                }
                
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .bold, design: .default)) +
                Text(description)
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .light, design: .default))
                Spacer()
                WidgetButton(title: titleButton, cornerRadius: 20)
                    .frame(width: .infinity, height: 40, alignment: .center)
            }
            .padding(.all, 20)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: colors), startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 0.9, y: 0.9)))
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
    var imagesNames: [String]?
    
    let colors = [
        Color(red: 5 / 255, green: 82 / 255, blue: 122 / 255),
        Color(red: 62 / 255, green: 198 / 255, blue: 203 / 255)
    ]
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: nil) {
                HStack {
                    if let percentage = percentage {
                        ProgressBarMedium(progress: percentage)
                            .frame(width: 70, height: 70, alignment: .leading)
                            .padding(.all, 10)
                    } else {
                        if let imagesName = imagesNames {
                            PremiumPeopleAlbumsMeduium(imagesString: imagesName)
                                .frame(width: geo.size.height, height: geo.size.height / 2.5, alignment: .leading)
                        } else {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(minWidth: 0, maxWidth: 80, minHeight: 0, maxHeight: 70, alignment: .leading)
                                .padding(.all, 5)
                                
                                
                        }
                    }
                    VStack(alignment: .leading, spacing: nil) {
                        Text(title)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold, design: .default)) +
                        Text(description)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .light, design: .default))
                        if let _ = countSyncFiles {
                            Text("See files")
                                .foregroundColor(.white)
                                .font(Font.headline.weight(.bold))
                                .frame(width: .infinity, alignment: .leading)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                }
                Spacer()
                WidgetButton(title: titleButton, cornerRadius: 20)
                    .frame(width: .infinity, height: 40, alignment: .leading)
            }
            .padding(.all, 20)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: colors), startPoint: UnitPoint(x: 0.1, y: 0.1), endPoint: UnitPoint(x: 1.2, y: 1.2)))
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
    let colors = [
        Color(red: 5 / 255, green: 82 / 255, blue: 122 / 255),
        Color(red: 62 / 255, green: 198 / 255, blue: 203 / 255)
    ]
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
        .background(LinearGradient(gradient: Gradient(colors: colors), startPoint: UnitPoint(x: 0.1, y: 0.1), endPoint: UnitPoint(x: 1.2, y: 1.2)))
        .frame(width: .infinity, height: .infinity, alignment: .center)
    }
}

// MARK: - ProgressBarSmall
struct ProgressBarSmall: View {
    var progress: CGFloat
    var body: some View {
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
                Image("signinicon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 12, height: 12, alignment: .center)
                    .offset(x: min(CGFloat(progress)*geometry.size.width - 5, geometry.size.width), y: 0)
            }
        }
    }
}

// MARK: - ProgressBarMedium
struct ProgressBarMedium: View {
    var progress: CGFloat
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(lineWidth: 12.0)
                    .opacity(0.3)
                    .foregroundColor(Color.black)
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.white)
                    .rotationEffect(Angle(degrees: 270.0))
                    .rotation3DEffect(
                        .degrees(180),
                        axis: /*@START_MENU_TOKEN@*/(x: 0.0, y: 1.0, z: 0.0)/*@END_MENU_TOKEN@*/
                    )
                    .animation(.linear)
                Text(String(format: "%.0f%%", min(progress, 1.0)*100.0))
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                Image("signinicon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20, alignment: .center)
                    .offset(x: 0, y:  min(CGFloat(0.5) * geometry.size.width, geometry.size.width))
                    .rotationEffect(Angle(degrees: 180))
                
            }
        }
    }
}


// MARK: - PremiumPeopleAlbums
struct PremiumPeopleAlbums: View {
    var imagesString: Array<String>
    var offset: CGFloat = 0
    var body: some View {
        HStack(alignment: .center, spacing: -25) {
            ForEach(imagesString.indices, id: \.self) { index in
                Image(imagesString[index])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
            }
        }
    }
}

struct PremiumPeopleAlbumsMeduium: View {
    var imagesString: Array<String>
    var offset: CGFloat = 0
    var body: some View {
        HStack(alignment: .center, spacing: -80) {
            ForEach(imagesString.indices, id: \.self) { index in
                Image(imagesString[index])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
        }
    }
}


// MARK: - AutoSync status
struct WidgetAutoSyncStatusSmall: View {
    let entry: WidgetAutoSyncEntry
    var body: some View {
        let message = entry.isSyncEnabled ? TextConstants.widgetRule41SmallDetail : TextConstants.widgetRule42SmallDetail
        let buttonTitle = entry.isSyncEnabled ? TextConstants.widgetRule41SmallButton : TextConstants.widgetRule42SmallButton
        WidgetEntrySmallView(imageName: "widget_small_sync",
                             title: "",
                             description: message,
                             titleButton: buttonTitle,
                             percentage: nil,
                             imagesNames: nil)
    }
}

struct WidgetAutoSyncStatusMeduium: View {
    let entry: WidgetAutoSyncEntry
    var body: some View {
        let message = entry.isSyncEnabled ? TextConstants.widgetRule41MediumDetail : TextConstants.widgetRule42MediumDetail
        let buttonTitle = entry.isSyncEnabled ? TextConstants.widgetRule41MediumButton : TextConstants.widgetRule42MediumButton
        WidgetEntryMediumView(imageName: "widget_medium_sync",
                              title: "",
                              description: message,
                              titleButton: buttonTitle,
                              percentage: nil,
                              countSyncFiles: nil,
                              imagesNames: nil)
    }
}
