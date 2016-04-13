//
//  HeartRateMonitorDelegate.swift
//  HealthMonitor
//
//  Created by Oleksii Pylko on 11/04/16.
//  Copyright © 2016 Oleksii Pylko. All rights reserved.
//

import Foundation

@objc protocol HeartRateMonitorDelegate {
    
    /**
     Tells the heart rate (in bpm)
     */
    optional func didChangeHeartRate(value: UInt16)
    
    /**
     Tells the battery level
     */
    optional func didChangeBatteryLevel(value: UInt8)
    
    /**
     Tells the body sensor location
     */
    optional func didChangeBodySensorLocation(value: UInt8)
}
