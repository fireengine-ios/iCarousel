//
//  ReachabilityService.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/27/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import Reachability


protocol ReachabilityProtocol {
    
    var isReachableViaWWAN: Bool { get }
    
    var isReachableViaWiFi: Bool { get }
    
    var isReachable: Bool { get }
}

class ReachabilityService: ReachabilityProtocol {
    
    private let reachability = Reachability()!
    
    var isReachableViaWiFi: Bool {
        return self.reachability.connection == .wifi
    }
    
    var isReachableViaWWAN: Bool {
        return self.reachability.connection == .cellular
    }
    
    var isReachable: Bool {
        return self.reachability.connection != .none
    }
    
    var status: String {
        return self.reachability.connection.description    
    }
    
    init() {
        self.reachability.whenReachable = { Reachability in
            //
        }
        
        self.reachability.whenUnreachable = { Reachability in
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
    
    enum Connection {
        case unreachable
        case reachable
        case undefined
    }
    
    static let shared = APIReachabilityService()
    
    private let requestService = APIReachabilityRequestService()
    
    private var timer: Timer?
    private (set) var connection: Connection = .undefined {
        didSet {
            if oldValue != connection {
                notify()
            }
        }
    }
    private let pingInterval: TimeInterval = 30.0
    
    
    init() {
        
    }
    
    // MARK: - Public
    
    func startNotifier() {
        guard timer == nil else {
            return
        }

        self.timer = Timer.scheduledTimer(timeInterval: pingInterval, target: self, selector: #selector(checkAPI), userInfo: nil, repeats: true)
        self.timer?.fire()
    }
    
    func stopNotifier() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func notify() {
        NotificationCenter.default.post(name: .apiReachabilityDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func checkAPI() {
        requestService.sendPingRequest { [weak self] isReachable in
            guard let `self` = self else {
                return
            }
            
            self.connection = isReachable ? .reachable : .unreachable
        }
    }

}


class APIHostReachabilityRequestParameters: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: "https://adepo.turkcell.com.tr/")!
    }
    
    override var header: RequestHeaderParametrs {
        return [:]
    }
}

class APIReachabilityRequestService: BaseRequestService {
    func sendPingRequest(handler: @escaping APIReachabilityHandler) {
        let parameters = APIHostReachabilityRequestParameters()
        let responseHandler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _ in
            handler(true)
        }, fail: { _ in
            handler(false)
        })
        executeHeadRequest(param: parameters, handler: responseHandler)
    }
}
