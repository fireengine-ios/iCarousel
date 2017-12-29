//
//  ReachabilityService.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/27/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import Reachability


protocol ReachabilityProtocol  {
    
    var isReachableViaWWAN: Bool { get }
    
    var isReachableViaWiFi: Bool { get }
    
    var isReachable: Bool { get }
}

class ReachabilityService: ReachabilityProtocol {
    
    private let reachability  = Reachability()!
    
    var isReachableViaWiFi: Bool {
        return self.reachability.connection == .wifi
    }
    
    var isReachableViaWWAN: Bool {
        return self.reachability.connection == .cellular
    }
    
    var isReachable:Bool {
        return self.reachability.connection != .none
    }
    
    init() {
        self.reachability.whenReachable = { (Reachability) in
            //
        }
        
        self.reachability.whenUnreachable = { (Reachability) in
            //
        }
        
        do {
            try self.reachability.startNotifier()
        } catch {
            print("Can't start REACHABILITY_NOTIFIER")
        }
    }
}


typealias APIReachabilityHandler = (_ isAvailable: Bool) -> Void


class APIReachabilityService {
    
    static let APIReachabilityDidChangeName = NSNotification.Name("APIReachabilityServiceReachabilityDidChangeName")
    
    enum Connection {
        case unreachable
        case reachable
    }
    
    static let shared = APIReachabilityService()
    
    private var timer: Timer?
    private (set) var connection: Connection = .unreachable {
        didSet {
            if oldValue != connection {
                notify()
            }
        }
    }
    private let pingInterval: TimeInterval = 60.0
    private var lastKnownSuccesfullRequestDate: TimeInterval = 0
    private var timeSinceLastKnownSuccesfullRequest: TimeInterval {
        return Date().timeIntervalSince1970 - lastKnownSuccesfullRequestDate
    }
    
    init() {
        
    }
    
    //MARK: - Public
    
    func startNotifier() {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkAPI), userInfo: nil, repeats: true).fire()
    }
    
    func stopNotifier() {
        timer = nil
    }
    
    func saveSuccesfullRequest() {
        lastKnownSuccesfullRequestDate = Date().timeIntervalSince1970
    }
    
    private func notify() {
        NotificationCenter.default.post(name: APIReachabilityService.APIReachabilityDidChangeName , object: nil)
    }
    
    
    @objc private func checkAPI() {
        guard timeSinceLastKnownSuccesfullRequest > pingInterval else {
            return
        }
        
        APIReachabilityRequestService().sendPingRequest { [weak self] (isReachable) in
            guard let `self` = self else {
                return
            }
            self.connection = isReachable ? .reachable : .unreachable
            if isReachable {
                self.saveSuccesfullRequest()
            }
        }
    }

}


class APIHostReachabilityRequestParameters: BaseRequestParametrs {
    override var patch: URL {
        return RouteRequests.BaseUrl
    }
}

class APIReachabilityRequestService: BaseRequestService {
    func sendPingRequest(handler: @escaping APIReachabilityHandler) {
        let parameters = APIHostReachabilityRequestParameters()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _ in
            handler(true)
        }, fail: { _ in
            handler(false)
        })
        executeGetRequest(param: parameters, handler: handler)
    }
}

