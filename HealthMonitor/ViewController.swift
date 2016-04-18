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
    
    weak var chartView: LineChartView!
    
    required init(controller: ViewController) {
        super.init(controller: controller)
        chartView = controller.chartView
        setData()
    }
    
    /**
     Calculate max numbers of visible points on the chart
     
     - returns: max numbers of visible points
     
     TODO: implement the calculation depending on screen size and orientation
     */
    private var maxNumberOfPoints: Int {
        return 100
    }

    /**
     Apply data on chart
     */
    private func setData() {
        let beats = realm.objects(HeartRateBeat).sorted("timestamp", ascending: false)
        let size = min(maxNumberOfPoints, beats.count)
        
        var xVars = [String]()
        var yVars = [ChartDataEntry]()
        for i in 1...size {
            let beat = beats[size - i]
            xVars.append(String(beat.timestamp))
            yVars.append(ChartDataEntry(value: Double(beat.beat), xIndex: i - 1))
        }
        
        let dataSet = LineChartDataSet(yVals: yVars, label: "Data Set")
        dataSet.lineWidth = 2.0
        dataSet.circleRadius = 1.0
        
        let data = LineChartData(xVals: xVars, dataSets: [dataSet])
        controller?.setData(data)
    }

    /**
     Update the chart with a new heart rate value
     
     - prameter heartRateValue: The new heart rate value
     */
    private func updateDataWithHeartRate(heartRateValue: UInt16) {
        setData()
    }
    
    /**
        Update the chart with a new heart rate value
     
        - prameter heartRateValue: The new heart rate value
     
        TODO: By some reason the functionlity bellow doesn't work
    */
    private func altUpdateDataWithHeartRate(heartRateValue: UInt16) {
        if let data = chartView.data {
            let dataSet = data.getDataSetByIndex(0)
            
            dataSet.removeFirst()
            chartView.notifyDataSetChanged()
            
            dataSet.addEntry(ChartDataEntry(value: Double(heartRateValue), xIndex: dataSet.entryCount))
            chartView.notifyDataSetChanged()
            
            chartView.setVisibleXRangeMaximum(100)
            chartView.moveViewTo(xIndex: CGFloat(data.xValCount - 101), yValue: Double(50), axis: ChartYAxis.AxisDependency.Right)
        }
    }
    
    override func didChangeHeartRate(heartRateValue: UInt16) {
        print("Heart Rate Value: \(heartRateValue)")
        super.didChangeHeartRate(heartRateValue)
        updateDataWithHeartRate(heartRateValue)
    }
    
}

class ViewController: UIViewController {
    
    enum State {
        case Undefined
        case Foreground
        case Background
        func isBackground() -> Bool {
            return self == .Background
        }
    }
    
    var currentState: State = .Undefined

    var heartRateMonitor = HeartRateMonitor()
    
    @IBOutlet weak var chartView: LineChartView!
    
    var controllerState: ControllerState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChart()
        setupState()
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
    
    private func setupState() {
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
        guard state != currentState else { return }
        controllerState = getControllerState(state)
        heartRateMonitor.delegate = controllerState
        currentState = state
    }
    
}

//  MARK: - ChartCompatible

extension ViewController : ChartCompatible {
    
    func setData(data: ChartData) {
        chartView.data = data
    }
    
}

