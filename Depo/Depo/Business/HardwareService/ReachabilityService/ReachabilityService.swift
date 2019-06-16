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

protocol ReachabilityServiceDelegate: class {
    func reachabilityDidChanged(_ service: ReachabilityService)
}

final class ReachabilityService: ReachabilityProtocol {
    
    static let shared = ReachabilityService()
    
    private lazy var reachability = Reachability()
    private lazy var apiReachability = APIReachabilityService()
    
    var isReachableViaWiFi: Bool {
        return self.reachability?.connection == .wifi && apiReachability.connection == .reachable
    }
    
    var isReachableViaWWAN: Bool {
        return self.reachability?.connection == .cellular && apiReachability.connection == .reachable
    }
    
    var isReachable: Bool {
        ///If you just .none, then compares not with the right enum
        return self.reachability?.connection != Reachability.Connection.none && apiReachability.connection == .reachable
    }
    
    var status: String {
        return self.reachability?.connection.description ?? Reachability.Connection.none.description
    }
    
    let delegates = MulticastDelegate<ReachabilityServiceDelegate>()
    
    private var updatingApiStatus = false
    
    private init() {
        setupObservers()
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Can't start REACHABILITY_NOTIFIER")
        }
        apiReachability.startNotifier()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: reachability, queue: .main) { [weak self] notification in
            guard let self = self else {
                return
            }
            if let connection = (notification.object as? Reachability)?.connection {
                debugPrint("ReachabilityService: new connection status \(connection.description)")
            
                if connection == .none {
                    self.notifyDelegates()
                    return
                }
            }
            
            guard !self.updatingApiStatus else {
                return
            }
            
            self.updatingApiStatus = true
            self.apiReachability.checkAPI { [weak self] in
                self?.updatingApiStatus = false
                self?.notifyDelegates()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .apiReachabilityDidChange, object: nil, queue: .main) { [weak self] _ in
            if let connection = self?.apiReachability.connection {
                debugPrint("ReachabilityService: new api connection status \(connection)")
            }
            self?.notifyDelegates()
        }
    }
    
    deinit {
        apiReachability.stopNotifier()
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func notifyDelegates() {
        delegates.invoke { $0.reachabilityDidChanged(self) }
    }
}


typealias APIReachabilityHandler = (_ isAvailable: Bool) -> Void

private final class APIReachabilityService {
    
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
    
    // MARK: - Public
    
    func startNotifier() {
        guard timer == nil else {
            return
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: pingInterval, target: self, selector: #selector(pingApi), userInfo: nil, repeats: true)
        self.timer?.tolerance = pingInterval * 0.1
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
    
    @objc private func pingApi() {
        checkAPI()
    }
    
    func checkAPI(_ completion: VoidHandler? = nil) {
        requestService.sendPingRequest { [weak self] isReachable in
            guard let `self` = self else {
                return
            }
            
            self.connection = isReachable ? .reachable : .unreachable
            completion?()
        }
    }

}

final class APIHostReachabilityRequestParameters: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: "https://adepo.turkcell.com.tr/")!
    }
    
    override var header: RequestHeaderParametrs {
        return [:]
    }
}

final class APIReachabilityRequestService: BaseRequestService {
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
