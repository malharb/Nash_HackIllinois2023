//
//  ViewController.swift
//  HackDemonstration
//
//  Created by Vishal Moorjani on 2/26/23.
//

import UIKit
import CoreMotion
import CoreML


extension CMSensorDataList: Sequence {
    public typealias Iterator = NSFastEnumerationIterator

    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var CenterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CenterLabel.text = "Attempting to gather data"
        var startDate = setStartDate()
        var endDate = setEndDate()
        
        var singleData = [dataPoint]()
        var pastData: CMSensorDataList?
        pastData = gatherData(startDate: startDate, endDate: endDate)
        singleData = convertToSingle(pastData: pastData)
        if singleData.count != 2160000 {
                    let date = Date()
                    let calendar = Calendar.current
                    startDate = calendar.date(byAdding: .day, value: -1, to: startDate) ?? date
                    endDate = calendar.date(byAdding: .day, value: -1, to: endDate) ?? date
                    pastData = gatherData(startDate: startDate, endDate: endDate)
                    singleData = convertToSingle(pastData: pastData)
                    if singleData.count != 2160000 {
                        CenterLabel.text = "Not enough information"
                    }
                }
        
                let maxValue = getMax(data: singleData)
        
                var minuteData = convertToMinuteData(singleList: singleData)
        
                let MLForm = convertToMLForm(minuteData: minuteData)
        
                func gatherData(startDate: Date, endDate: Date) -> CMSensorDataList? {
                    let sensorRecorder = CMSensorRecorder()
                    let pastData = sensorRecorder.accelerometerData(from: startDate, to: endDate)
                    return pastData
                }
        
                func convertToSingle(pastData: CMSensorDataList?) -> Array<dataPoint> {
        
                    var returnValue = [dataPoint]()
                    let threshold = 0.05 * 9.81
                    for value in pastData! {
                        // Process the data.
                        let timeStamp = (value as AnyObject).timestamp ?? 0.0
                        let xAcceleration = (value as AnyObject).acceleration.x
                        let yAcceleration = (value as AnyObject).acceleration.y
                        let zAcceleration  = (value as AnyObject).acceleration.z
                        var singleValue = pow(xAcceleration, 2) + pow(yAcceleration, 2) + pow(zAcceleration, 2)
                        singleValue = pow(singleValue, 0.5)
        
                        if (singleValue - threshold < 0.0) {
                            returnValue.append(dataPoint(value: 0.0, timestamp: Float(timeStamp)))
                        } else {
                            returnValue.append(dataPoint(value: Float(singleValue), timestamp: Float(timeStamp)))
                        }
        
                    }
        
                    return returnValue
                }
        
                func getMax(data: Array<dataPoint>) -> Float {
                    var maxValue: Float = 0.0
                    for point in data {
                        if point.value > maxValue {
                            maxValue = point.value
                        }
                    }
                    return maxValue
                }
        
                func convertToMinuteData(singleList: Array<dataPoint>) -> Array<Float> {
                    var minuteAR = Array<Float>()
                    var count = 0
                    var maxVal = 0.0
                    while (count < singleList.count) {
                        if (Double((singleList[count].value / maxValue)) * 1000) > maxVal {
                            if (minuteAR.count >= Int(singleList.count / 3000 * count)) {
                                minuteAR[Int(singleList.count / 3000 * count)] = (singleList[count].value / maxValue) * 1000
                            } else {
                                minuteAR.append((singleList[count].value / maxValue) * 1000)
                            }
        
                        }
                        count += 1
        
                        if ((count + 1) % 3000 == 0) {
                            maxVal = 0.0
                        }
                    }
                    return minuteAR
                }
        
                //No longer required as MLShapedArray method builds array of the required shape from minuteData
                func convertToMLForm(minuteData: Array<Float>) -> Array<Array<Array<Float>>> {
                    var innerMostArray = Array<Float>()
                    var secondArray = Array<Array<Float>>()
                    var outerArray = Array<Array<Array<Float>>>()
        
                    for value in minuteData {
                        innerMostArray.append(value)
                        secondArray.append(innerMostArray)
                        innerMostArray = Array<Float>()
                    }
                    outerArray.append(secondArray)
                    return outerArray
                }
//            nestedValues: Array<Float>
        func runAnalysis() {
            let numberArray = (0..<720).map{ _ in Float.random(in: 1 ... 1000) }
            
            do {
                let config = MLModelConfiguration()
                let model = try coreMLAccel(configuration: config)
                //Pass values into MLShapedArray
                //let shapedAR = MLShapedArray(scalars: nestedValues, shape: [1,720,1])
                //Below line uses randomly generated data to ensure that the model is able to access data since
                //we could not use data from a phone or an apple watch
                let shapedAR = MLShapedArray(scalars: numberArray, shape: [1, 720, 1])
                let inputToModel = MLMultiArray(shapedAR)
                
                let output = try model.prediction(lstm_9_input: inputToModel)
                if (Double(truncating: output.Identity[0]) > 0.5) {
                    CenterLabel.text = "Shit lol"
                } else {
                    CenterLabel.text = "Congrats"
                }
                print(output.Identity[0])
                
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        runAnalysis()
        
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
        
    }
    
    class dataPoint {
        var value: Float
        var timestamp: Float
        
        init(value: Float, timestamp: Float) {
            self.value = value
            self.timestamp = timestamp
        }
    }
    
    
}
