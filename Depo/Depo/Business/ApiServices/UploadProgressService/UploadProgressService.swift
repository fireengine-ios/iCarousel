//
//  UploadPregressService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 12/11/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation



protocol UploadProgressServiceDelegate: class {
    func didSend(bytes: Int64, for tempUUID: String)
    func didSend(ratio: Float, for tempUUID: String)
    func didSend(percent: Float, for tempUUID: String)
}



class UploadProgressService: NSObject, URLSessionTaskDelegate {
    static let shared: UploadProgressService = UploadProgressService()
    
    weak var delegate: UploadProgressServiceDelegate?
 
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let progressDelegate = delegate, let tempUUIDfromURL = task.currentRequest?.url?.lastPathComponent else {
            return
        }
        
        let ratio = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
        progressDelegate.didSend(bytes: bytesSent, for: tempUUIDfromURL)
        progressDelegate.didSend(ratio: ratio, for: tempUUIDfromURL)
        progressDelegate.didSend(percent: ratio * 100, for: tempUUIDfromURL)
    }
}


