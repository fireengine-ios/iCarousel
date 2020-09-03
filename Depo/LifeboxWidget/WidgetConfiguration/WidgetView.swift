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

//Small
struct WidgetSmallSizeView: View {
    let entry: WidgetProvider.Entry
    
    var body: some View {
        switch entry {
        case let entry as WidgetQuotaEntry:
            WidgetQuotaView(entry: entry)
            
        case let entry as WidgetContactBackupEntry:
            WidgetContactBackupView(entry: entry)
            
        case let entry as WidgetDeviceQuotaEntry:
            WidgetDeviceQuotaView(entry: entry)
            
        case let entry as WidgetUserInfoEntry:
            WidgetUserInfoView(entry: entry)
            
        default:
            WidgetLoginRequiredView()
        }
    }
}

// Medium
struct WidgetMediumSizeView: View {
    let entry: WidgetProvider.Entry
    
    var body: some View {
        switch entry {
        case let entry as WidgetQuotaEntry:
            WidgetQuotaView(entry: entry)
            
        case let entry as WidgetContactBackupEntry:
            WidgetContactBackupView(entry: entry)
            
        case let entry as WidgetDeviceQuotaEntry:
            WidgetDeviceQuotaView(entry: entry)
            
        case let entry as WidgetUserInfoEntry:
            WidgetUserInfoView(entry: entry)
            
        default:
            WidgetLoginRequiredMedium()
        }
    }
}

// WidgetLoginRequiredView
struct WidgetLoginRequiredView: View {
    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [.yellow, .pink]),
                startPoint: .bottomTrailing,
                endPoint: .topLeading
            )
            VStack{
                Spacer()
                Text("Log in the app")
                    .fontWeight(.bold)
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                Spacer()
                Button("Login", action: {})
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                Spacer()
            }
        }
    }
}

struct WidgetLoginRequiredMedium: View {
    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [.yellow, .pink]),
                startPoint: .bottomTrailing,
                endPoint: .topLeading
            )
            VStack{
                Spacer()
                Text("Log in the app")
                    .fontWeight(.bold)
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                Spacer()
                Button("Login", action: {})
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                Spacer()
            }
        }
    }
}

// WidgetQuotaView
struct WidgetQuotaView: View {
    var entry: WidgetQuotaEntry
    
    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [.yellow, .pink]),
                startPoint: .bottomTrailing,
                endPoint: .topLeading
            )
            Link(destination: URL(string: "akillidepo://\(PushNotificationAction.packages)")!) {
                VStack{
                    Spacer()
                    Text("Your lifebox quote is over \(entry.usedPercentage)%.")
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Text("Time to upgrade it")
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Spacer()
                    Button("View Plans", action: {}).buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                    Spacer()
                }
            }
        }
    }
}

// WidgetDeviceQuotaView
struct WidgetDeviceQuotaView: View {
    var entry: WidgetDeviceQuotaEntry
    var url = URL(string: "akillidepo://\(PushNotificationAction.packages)")!
    
    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [.yellow, .pink]),
                startPoint: .bottomTrailing,
                endPoint: .topLeading
            )
            VStack{
                Spacer()
                HStack {
                    Spacer()
                    Text("\(entry.usedPersentage)%")
                        .fontWeight(.bold)
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Spacer()
                    Text("Running out of device storage! You need space for new memories")
                        .fontWeight(.bold)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                    Spacer()
                }
                Spacer()
                Link(destination: url) {
                    Button(action: {
                        
                    }) { Text("Free up memory")
                        .frame(maxWidth: 100, maxHeight: 50, alignment: .center)
                        .padding(10)
                        
                    }
                    .buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                }
                Spacer()
            }
        }
    }
}

struct WidgetContactBackupView: View {
    var entry: WidgetContactBackupEntry
    var url = URL(string: "akillidepo://\(PushNotificationAction.contactSync)")!
    let gradient = Gradient(colors: [.yellow, .pink])
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: gradient, startPoint: .bottomTrailing, endPoint: .topLeading)
            VStack{
                if let date = entry.backupDate {
                    let components = Calendar.current.dateComponents([.weekOfYear, .month], from: date, to: Date())
                    if  components.month! >= 1 {
                        Text("It's over 1 month since your last contact backup")
                            .fontWeight(.bold)
                            .font(.system(size: 20))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                    }
                }else{
                    Text("No backed uo contacts in lifebox. Secure your contacts")
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Link(destination: url) {
                        Button("Back up contacts", action: {
                        }).buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                    }
                }
            }
        }
    }
}


//Premium state
struct WidgetUserInfoView: View {
    var entry: WidgetUserInfoEntry
    let gradient = Gradient(colors: [.yellow, .pink])
    var urlPremium = URL(string: "akillidepo://\(PushNotificationAction.becomePremium)")!
    var urlFaceToFace = URL(string: "akillidepo://\(PushNotificationAction.people)")!
    var urlUploadImage = URL(string: "akillidepo://\(PushNotificationAction.photos)")!
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: gradient, startPoint: .bottomTrailing, endPoint: .topLeading)
            VStack{
                if entry.isFIREnabled && entry.isPremiumUser {
                    Text("Upload photos")
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Link(destination: urlUploadImage) {
                        Button("Upload photos", action: {
                        }).buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                    }
                }else if entry.isPremiumUser && !entry.isFIREnabled{
                    Text("What about gruoping your phots easily by people?")
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Link(destination: urlFaceToFace) {
                        Button("Enable face-image grouping", action: {
                        }).buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                    }
                }else{
                    Text("Become premium to see people albums")
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    Link(destination: urlPremium) {
                        Button("Become Premium", action: {
                        }).buttonStyle(NeumorphicButtonStyle(bgColor: .white))
                    }
                }
            }
        }
    }
}

