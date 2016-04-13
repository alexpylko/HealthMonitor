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
     */
    func didChangeDeviceInfo(value: NSString, ofType type: DeviceInformation)
    
    /**
     Tells the heart rate (in bpm)
     */
    func didChangeHeartRate(value: UInt16)
    
    /**
     Tells the battery level
     */
    func didChangeBatteryLevel(value: UInt8)
    
    /**
     Tells the body sensor location
     */
    func didChangeBodySensorLocation(value: BodySensorLocation)
}

// Default protocol implementation

extension HeartRateMonitorDelegate {
    
    func didChangeDeviceInfo(value: NSString, ofType type: DeviceInformation) { }
    func didChangeHeartRate(value: UInt16) { }
    func didChangeBatteryLevel(value: UInt8) { }
    func didChangeBodySensorLocation(value: BodySensorLocation) { }
    
}