//
//  HeartRateMonitorDelegate.swift
//  HealthMonitor
//
//  Created by Oleksii Pylko on 11/04/16.
//  Copyright © 2016 Oleksii Pylko. All rights reserved.
//

import Foundation

protocol HeartRateMonitorDelegate {

    /**
     Tells the device info
     
     - parameter deviceInfoValue: The device info value
     - parameter deviceInfoType: The device info type
     */
    func didChangeDeviceInfo(deviceInfoValue: NSString, ofType deviceInfoType: DeviceInformation)
    
    /**
     Tells the heart rate
     
     - parameter heartRateValue: The heart rate in bpm
     */
    func didChangeHeartRate(heartRateValue: UInt16)
    
    /**
     Tells the battery level
     
     - parameter batteryLevelInPercantage: The battery level in percantage from 0% to 100%
     */
    func didChangeBatteryLevel(batteryLevelInPercantage: UInt8)
    
    /**
     Tells the body sensor location
    
     - parameter bodySensorLocation: The body sensor location
     */
    func didChangeBodySensorLocation(bodySensorLocation: BodySensorLocation)
}

// Default protocol implementation

extension HeartRateMonitorDelegate {
    
    func didChangeDeviceInfo(deviceInfoValue: NSString, ofType deviceInfoType: DeviceInformation) { }
    func didChangeHeartRate(heartRateValue: UInt16) { }
    func didChangeBatteryLevel(batteryLevelInPercantage: UInt8) { }
    func didChangeBodySensorLocation(bodySensorLocation: BodySensorLocation) { }
    
}