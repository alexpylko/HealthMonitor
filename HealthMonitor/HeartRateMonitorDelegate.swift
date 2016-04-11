//
//  HeartRateMonitorDelegate.swift
//  HealthMonitor
//
//  Created by Oleksii Pylko on 11/04/16.
//  Copyright © 2016 Oleksii Pylko. All rights reserved.
//

import Foundation

@objc protocol HeartRateMonitorDelegate {
    optional func didChangeHeartRate(value: UInt16)
    optional func didChangeBatteryLevel(value: UInt8)
    optional func didChangeBodySensorLocation(value: UInt8)
}
