//
//  ViewController.swift
//  HealthMonitor
//
//  Created by Oleksii Pylko on 09/04/16.
//  Copyright © 2016 Oleksii Pylko. All rights reserved.
//

import UIKit
import CoreBluetooth
import RealmSwift
import Charts

class ViewController: UIViewController {

    var heartRateMonitor: HeartRateMonitor?
    
    lazy var realm:Realm = try! Realm()
    
    @IBOutlet weak var chartView: LineChartView!
    
    var dataSet: LineChartDataSet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeartRateMonitor()
        setupChart()
        setData()
    }
    
    func setupChart() {
        chartView.descriptionText = "Heart Rate"
        chartView.noDataTextDescription = "You need to provide data for the chart."
        chartView.drawGridBackgroundEnabled = false
        chartView.dragEnabled = true
        chartView.pinchZoomEnabled = false
        chartView.rightAxis.enabled = false
        chartView.setScaleEnabled(true)
    }
    
    func setData() {
        let beats = realm.objects(HeartRateBeat).sorted("timestamp", ascending: false)
        let limit = 100
        let size = min(100, beats.count)
        
        var xVars = [String]()
        var yVars = [ChartDataEntry]()
        for i in 1...size {
            let beat = beats[limit - i]
            xVars.append(String(beat.timestamp))
            yVars.append(ChartDataEntry(value: Double(beat.beat), xIndex: i - 1))
        }
        
        dataSet = LineChartDataSet(yVals: yVars, label: "Data Set")
        dataSet.lineWidth = 2.0
        dataSet.circleRadius = 1.0
        
        let data = LineChartData(xVals: xVars, dataSets: [dataSet])
        chartView.data = data
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
        guard heartRateValue > 0 else { return }
        let beat = HeartRateBeat(beat: heartRateValue)
        try! realm.write {
            realm.add(beat)
        }
        setData()
    }
    
    func didChangeBatteryLevel(batteryLevelInPercantage: UInt8) {
        print("Battery Level: \(batteryLevelInPercantage)")
    }
    
    func didChangeBodySensorLocation(bodySensorLocation: BodySensorLocation) {
        print("Body Sensor Location: \(bodySensorLocation)")
    }
    
}
