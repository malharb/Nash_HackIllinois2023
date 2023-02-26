//
//  AccelerometerModel.swift
//  SharingDataTest
//
//  Created by Vishal Moorjani on 2/25/23.
//

//Creates a model to share unencoded accelerometer data using WatchConnectivity

import Foundation
import Combine
import WatchConnectivity
import CoreMotion

final class DataList: ObservableObject {
    var session: WCSession
    let delegate: WCSessionDelegate
    let subject = PassthroughSubject<CMSensorDataList, Never>()
    
    
    
    @Published private var dataToSend: CMSensorDataList
    
    init(session: WCSession = .default){
        let sensorRecorder = CMSensorRecorder()
        let pastData = sensorRecorder.accelerometerData(from: setStartDate(), to: setEndDate())
        self.dataToSend = pastData!
        self.delegate = SessionDelegater(countSubject: subject)
        self.session = session
        self.session.delegate = self.delegate
        self.session.activate()
        
        subject
            .receive(on: DispatchQueue.main)
            .assign(to: &$dataToSend)
    }
    
    func sendData() {
        session.sendMessage(["count": dataToSend], replyHandler: nil) { error in
            print(error.localizedDescription)
        }
    }
}


func setStartDate() -> Date {
    let date = Date()
    let calendar = Calendar.current
    var startDate = calendar.date(byAdding: .day, value: -2, to: date) ?? date
    startDate = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: startDate) ?? date
    
    return startDate
}

func setEndDate() -> Date {
    let date = Date()
    let calendar = Calendar.current
    var endDate = calendar.date(byAdding: .day, value: -1, to: date) ?? date
    endDate = calendar.date(bySettingHour: 2, minute: 59, second: 59, of: endDate) ?? date
    return endDate
}
