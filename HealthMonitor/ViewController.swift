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
    
    func didChangeDeviceInfo(value: NSString, ofType type: DeviceInformation) {
        print("Device Info: \(value) bpm of type \(type)")
    }
    
    func didChangeHeartRate(value: UInt16) {
        print("Heart Rate: \(value) bpm")
    }
    
    func didChangeBatteryLevel(value: UInt8) {
        print("Battery Level: \(value)")
    }
    
    func didChangeBodySensorLocation(value: BodySensorLocation) {
        print("Body Sensor Location: \(value)")
    }
    
}
