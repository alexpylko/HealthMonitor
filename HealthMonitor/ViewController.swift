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

protocol ControllerState : HeartRateMonitorDelegate {
    init(controller: ViewController)
}

class BackgroundControllerState : ControllerState {

    var controller: ViewController?
    
    required init(controller: ViewController) {
        self.controller = controller
    }
    
    private lazy var realm:Realm = try! Realm()
    
    func didChangeDeviceInfo(deviceInfoValue: NSString, ofType deviceInfoType: DeviceInformation) {
        print("Device Info: \(deviceInfoValue) bpm of type \(deviceInfoType)")
    }
    
    func didChangeBatteryLevel(batteryLevelInPercantage: UInt8) {
        print("Battery Level: \(batteryLevelInPercantage)")
    }
    
    func didChangeBodySensorLocation(bodySensorLocation: BodySensorLocation) {
        print("Body Sensor Location: \(bodySensorLocation)")
    }
    
    func didChangeHeartRate(heartRateValue: UInt16) {
        print("Heart Rate Value: \(heartRateValue)")
        let beat = HeartRateBeat(beat: heartRateValue)
        try! realm.write {
            realm.add(beat)
        }
    }
    
}

class ForegroundControllerState : BackgroundControllerState {
    
    required init(controller: ViewController) {
        super.init(controller: controller)
        setData()
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
        
        let dataSet = LineChartDataSet(yVals: yVars, label: "Data Set")
        dataSet.lineWidth = 2.0
        dataSet.circleRadius = 1.0
        
        let data = LineChartData(xVals: xVars, dataSets: [dataSet])
        controller?.setData(data)
    }
    
    override func didChangeHeartRate(heartRateValue: UInt16) {
        print("Heart Rate Value: \(heartRateValue)")
        super.didChangeHeartRate(heartRateValue)
        setData()
    }
    
}

class ViewController: UIViewController {
    
    enum State {
        case Foreground
        case Background
        func isBackground() -> Bool {
            return self == .Background
        }
    }

    var heartRateMonitor = HeartRateMonitor()
    
    @IBOutlet weak var chartView: LineChartView!
    
    var controllerState: ControllerState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChart()
        setup()
        setupNotifications()
    }
    
    private var defaultCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    private func setupNotifications() {
        defaultCenter.addObserver(self, selector: #selector(didEnterBackgroundNotification), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func didEnterBackgroundNotification() {
        setState(.Background)
    }
    
    func didBecomeActive() {
        setState(.Foreground)
    }
    
    private func setupChart() {
        chartView.descriptionText = "Heart Rate"
        chartView.noDataTextDescription = "You need to provide data for the chart."
        chartView.drawGridBackgroundEnabled = false
        chartView.dragEnabled = true
        chartView.pinchZoomEnabled = false
        chartView.rightAxis.enabled = false
        chartView.setScaleEnabled(true)
    }
    
    private func setup() {
        setState(.Foreground)
        heartRateMonitor.start()
    }
    
    private func getControllerState(state: State) -> ControllerState {
        if state.isBackground() {
            return BackgroundControllerState(controller: self)
        }
        else {
            return ForegroundControllerState(controller: self)
        }
    }
    
    func setState(state: State) {
        controllerState = getControllerState(state)
        heartRateMonitor.delegate = controllerState
    }
    
}

//  MARK: - ChartCompatible

extension ViewController : ChartCompatible {
    
    func setData(data: ChartData) {
        chartView.data = data
    }
    
}

