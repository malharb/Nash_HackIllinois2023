//
//  sessionDelegator.swift
//  SharingDataTest
//
//  Created by Vishal Moorjani on 2/25/23.
//
//Adapted from: https://cgaaf.medium.com/swiftui-watch-connectivity-in-4-steps-594f90f3a0bc
//Allows for two way transfer - watch to phone and phone to watch - which is not required, but is enabled incase it is required in the future. 

import Combine
import WatchConnectivity
import CoreMotion

class SessionDelegater: NSObject, WCSessionDelegate {
    let countSubject: PassthroughSubject<CMSensorDataList, Never>
    
    init(countSubject: PassthroughSubject<CMSensorDataList, Never>) {
        self.countSubject = countSubject
        super.init()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Protocol comformance only
        // Not needed for this demo
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let count = message["count"] as? CMSensorDataList {
                self.countSubject.send(count)
            } else {
                print("There was an error")
            }
        }
    }
    
    // iOS Protocol comformance
    // Not needed for this demo otherwise
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Activate the new session after having switched to a new watch.
        session.activate()
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("\(#function): activationState = \(session.activationState.rawValue)")
    }
    #endif
}
