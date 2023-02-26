//
//  ProgramObject.swift
//  anotherDataSendingTrial
//
//  Created by Vishal Moorjani on 2/25/23.
//

import UIKit
import WatchConnectivity
import CoreMotion

class AccelerometerData: NSObject, ObservableObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    let id = UUID()
    
    @Published var accelerationData: CMSensorDataList
    
    public func initWithData(accelerationData: CMSensorDataList) {
        self.accelerationData = accelerationData
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let accelerationData = coder.decodeObject(forKey: "accelerationData") as? CMSensorDataList,
        else {return nil}
        
        self.init()
        self.initWithData(accelerationData: accelerationData as CMSensorDataList)
        
    }
    public func encode(with coder: NSCoder) {
        coder.encode(self.accelerationData, forKey: "accelerationData")
    }
    
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
