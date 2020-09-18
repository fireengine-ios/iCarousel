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
            WidgetFaceRecognitionSmallView(entry: entry)
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
                             description: TextConstants.widgetSmallSignInText,
                             titleButton: TextConstants.widgetSmallSignInButton)
    }
}

struct WidgetLoginRequiredMediumView: View {
    var body: some View {
        WidgetEntryMediumView(imageName: "sign_in",
                              title: "",
                              description: TextConstants.widgetMediumSignInText,
                              titleButton: TextConstants.widgetMediumSignInButton)
    }
}

//MARK:- WidgetQuotaView
struct WidgetQuotaSmallView: View {
    var entry: WidgetQuotaEntry
    
    var body: some View {
        WidgetEntrySmallView(imageName: "",
                             title: String(format: TextConstants.widgetSmallQuotaTitle, entry.usedPercentage),
                             description: TextConstants.widgetSmallQuotaSubtitle,
                             titleButton: TextConstants.widgetSmallQuotaButton,
                             percentage: CGFloat(entry.usedPercentage)/100)
    }
}

struct WidgetQuotaMediumView: View {
    var entry: WidgetQuotaEntry
    
    var body: some View {
        WidgetEntryMediumView(imageName: "",
                              title: TextConstants.widgetMediumQuotaTitle,
                              description: TextConstants.widgetMediumQuotaSubtitle,
                              titleButton: TextConstants.widgetMediumQuotaButton,
                              percentage: CGFloat(entry.usedPercentage)/100)
    }
}


//MARK:- WidgetDeviceQuotaView
struct WidgetDeviceQuotaSmallView: View {
    var entry: WidgetDeviceQuotaEntry
    
    var body: some View {
        WidgetEntrySmallView(imageName: "",
                             title: String(format: TextConstants.widgetSmallDeviceStorageTitle, entry.usedPersentage),
                             description: TextConstants.widgetSmallDeviceStorageSubtitle,
                             titleButton: TextConstants.widgetSmallDeviceStorageButton,
                             percentage: CGFloat(entry.usedPersentage)/100)
    }
}

struct WidgetDeviceQuotaMediumView: View {
    var entry: WidgetDeviceQuotaEntry
    
    var body: some View {
        WidgetEntryMediumView(imageName: "",
                              title: TextConstants.widgetMediumDeviceStorageTitle,
                              description: TextConstants.widgetMediumDeviceStorageSubtitle,
                              titleButton: TextConstants.widgetMediumDeviceStorageButton,
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
                                     title: TextConstants.widgetSmallOldContactBackupTitle,
                                     description: TextConstants.widgetSmallOldDeviceContactBackupSubtitle,
                                     titleButton: TextConstants.widgetSmallOldContactBackupButton)
            }
        } else {
            WidgetEntrySmallView(imageName: "back_up_small",
                                 title: TextConstants.widgetSmallNoContactBackupTitle,
                                 description: TextConstants.widgetSmallNoContactBackupSubtitle,
                                 titleButton: TextConstants.widgetSmallNoContactBackupButton)
        }
    }
}

struct WidgetContactBackedupMediumView: View {
    var entry: WidgetContactBackupEntry
    
    var body: some View {
        if let backupDate = entry.backupDate {
            let components = Calendar.current.dateComponents([.weekOfYear, .month], from: backupDate, to: Date())
            if  components.month! >= 1 {
                WidgetEntryMediumView(imageName: "back_up_medium",
                                      title: TextConstants.widgetMediumOldContactBackupTitle,
                                      description: TextConstants.widgetMediumOldContactBackupSubtitle,
                                      titleButton: TextConstants.widgetMediumOldContactBackupButton)
            }
        } else {
            WidgetEntryMediumView(imageName: "back_up_medium",
                                  title: TextConstants.widgetMediumNoContactBackupTitle,
                                  description: TextConstants.widgetMediumNoContactBackupSubtitle,
                                  titleButton: TextConstants.widgetMediumNoContactBackupButton)
        }
    }
}


//MARK: - WidgetPRemiumView
struct WidgetFaceRecognitionSmallView: View {
    let entry: WidgetUserInfoEntry
    var body: some View {
        if entry.isPremiumUser && entry.isFIREnabled {
            WidgetEntrySmallView(imageName: "",
                                 title: TextConstants.widgetSmallFaceRecognitionTitle,
                                 description: TextConstants.widgetSmallFaceRecognitionSubtitle,
                                 titleButton: TextConstants.widgetSmallFaceRecognitionButton,
                                 imagesNames: ["test3", "test3", "test3"])
            
        } else if entry.isPremiumUser && !entry.isFIREnabled {
            WidgetEntrySmallView(imageName: "",
                                 title: TextConstants.widgetSmallFaceRecognitionDisabledFIRTitle,
                                 description: TextConstants.widgetSmallFaceRecognitionDisabledFIRSubtitle,
                                 titleButton: TextConstants.widgetSmallFaceRecognitionDisabledFIRButton,
                                 imagesNames: ["test3", "test3", "test3"])
        } else {
            WidgetEntrySmallView(imageName: "",
                                 title: TextConstants.widgetSmallFaceRecognitionNeedPremiumTitle,
                                 description: TextConstants.widgetSmallFaceRecognitionNeedPremiumSubtitle,
                                 titleButton: TextConstants.widgetSmallFaceRecognitionNeedPremiumButton,
                                 imagesNames: ["test3", "test3", "test3"])
        }
    }
}

struct WidgetFaceRecognitionMediumView: View {
    let entry: WidgetUserInfoEntry
    var body: some View {
        if entry.isPremiumUser && entry.isFIREnabled {
            WidgetEntryMediumView(imageName: "",
                                  title: TextConstants.widgetMediumFaceRecognitionTitle,
                                  description: TextConstants.widgetMediumFaceRecognitionSubtitle,
                                  titleButton: TextConstants.widgetMediumFaceRecognitionButton,
                                  imagesNames: ["test3", "test3", "test3"])
            
        } else if entry.isPremiumUser && !entry.isFIREnabled {
            WidgetEntryMediumView(imageName: "",
                                  title: TextConstants.widgetMediumFaceRecognitionDisabledFIRTitle,
                                  description: TextConstants.widgetMediumFaceRecognitionDisabledFIRSubtitle,
                                  titleButton: TextConstants.widgetMediumFaceRecognitionDisabledFIRButton,
                                  imagesNames: ["test3", "test3", "test3"])
        } else {
            WidgetEntryMediumView(imageName: "",
                                  title: TextConstants.widgetMediumFaceRecognitionNeedPremiumTitle,
                                  description: TextConstants.widgetMediumFaceRecognitionNeedPremiumSubtitle,
                                  titleButton: TextConstants.widgetMediumFaceRecognitionNeedPremiumButton,
                                  imagesNames: ["test3", "test3", "test3"])
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
            Color(red: 0 / 255, green: 72 / 255, blue: 115 / 255),
            Color(red: 68 / 255, green: 205 / 255, blue: 208 / 255)
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
                            .frame(minWidth: 0, maxWidth: 27, minHeight: 0, maxHeight: 27, alignment: .leading)
                    }
                }
                
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .semibold, design: .default)) +
                Text(description)
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .regular, design: .default))
                Spacer()
                WidgetButton(title: titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: 36, alignment: .center)
            }
            .padding(.all, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: colors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
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
        Color(red: 0 / 255, green: 72 / 255, blue: 115 / 255),
        Color(red: 68 / 255, green: 205 / 255, blue: 208 / 255)
    ]
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: nil) {
                HStack(spacing: 8) {
                    if let percentage = percentage {
                        ProgressBarMedium(progress: percentage)
                            .frame(width: 57, height: 57, alignment: .leading)
//                            .padding(.all, 10)
                    } else {
                        if let imagesName = imagesNames {
                            PremiumPeopleAlbumsMeduium(imagesString: imagesName)
                                .frame(width: geo.size.height, height: geo.size.height / 2.5, alignment: .leading)
                        } else {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(minWidth: 0, maxWidth: 54, minHeight: 0, maxHeight: 54, alignment: .leading)
                        }
                    }
                    VStack(alignment: .leading, spacing: nil) {
                        Text(title)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .semibold, design: .default)) +
                        Text(description)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .regular, design: .default))
                        if let _ = countSyncFiles {
                            Text("See files")
                                .foregroundColor(.white)
                                .font(Font.headline.weight(.bold))
                                .frame(width: .infinity, alignment: .leading)
                        }
                        Spacer()
                    }
                    .padding(.top, 12)
                    
                    Spacer()
                }
                Spacer()
                WidgetButton(title: titleButton, cornerRadius: 12)
                    .frame(width: .infinity, height: 44, alignment: .leading)
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(LinearGradient(gradient: Gradient(colors: colors), startPoint: .zero, endPoint: UnitPoint(x: 1, y: 1)))
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
        Color(red: 0 / 255, green: 72 / 255, blue: 115 / 255),
        Color(red: 68 / 255, green: 205 / 255, blue: 208 / 255)
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
                    .stroke(lineWidth: 8.0)
                    .opacity(0.3)
                    .foregroundColor(Color.black)
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
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
