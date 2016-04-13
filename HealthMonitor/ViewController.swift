//
//  ViewController.swift
//  HealthMonitor
//
//  Created by Oleksii Pylko on 09/04/16.
//  Copyright © 2016 Oleksii Pylko. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    var heartRateMonitor: HeartRateMonitor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeartRateMonitor()
    }
    
    func setupHeartRateMonitor() {
        heartRateMonitor = HeartRateMonitor(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ViewController: HeartRateMonitorDelegate {
    
    func didChangeDeviceInfo(deviceInfoValue: NSString, ofType deviceInfoType: DeviceInformation) {
        print("Device Info: \(deviceInfoValue) bpm of type \(deviceInfoType)")
    }
    
    func didChangeHeartRate(heartRateValue: UInt16) {
        print("Heart Rate: \(heartRateValue) bpm")
    }
    
    func didChangeBatteryLevel(batteryLevelInPercantage: UInt8) {
        print("Battery Level: \(batteryLevelInPercantage)")
    }
    
    func didChangeBodySensorLocation(bodySensorLocation: BodySensorLocation) {
        print("Body Sensor Location: \(bodySensorLocation)")
    }
    
}
