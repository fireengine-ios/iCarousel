//
//  SilentPushApiService.swift
//  Depo
//
//  Created by Alper Kırdök on 30.06.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Alamofire
import XCGLogger

final class SilentPushApiService: BaseRequestService {
    @discardableResult
    func uploadLog() {

        let logPath = Device.documentsFolderUrl(withComponent: XCGLogger.lifeboxLogFileName)
        //TODO Check nil
        let widgetLogUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedConstants.groupIdentifier)!.appendingPathComponent("home_widget.log")

        do {
            let logData = try Data(contentsOf: logPath)
            let widgetLogData = try Data(contentsOf: widgetLogUrl)

            SessionManager.customDefault.upload(
                multipartFormData: {
                    $0.append(logData, withName: "logs", fileName: "logs.txt", mimeType: "text/plain")
                    $0.append(widgetLogData, withName: "widget_logs", fileName: "widget_logs.txt", mimeType: "text/plain")

                },
                to: RouteRequests.Invitation.link) { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        } catch {
            fatalLog("Unable to get log file data: \(error)")
        }

    }

/*
    http.session.upload(
        multipartFormData: {
            $0.append(data, withName: "fileName", fileName: "test.log", mimeType: "text/log")
        },
        to: url(forPath: "help/uploadLog/" + logId),
        method: .post,
        interceptor: Interceptor(interceptors: http.interceptors)
    ).responseJSONDictionary(completion: completion)
*/
//    func getInvitationLink(handler: @escaping ResponseHandler<InvitationLink>) -> URLSessionTask? {
//        return SessionManager
//            .customDefault
//            .request(RouteRequests.Invitation.link)
//            .customValidate()
//            .responseObject(handler)
//            .task
//    }
}
