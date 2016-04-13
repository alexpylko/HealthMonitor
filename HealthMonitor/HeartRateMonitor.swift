//
//  HeartRateMonitor.swift
//  HealthMonitor
//
//  Created by Oleksii Pylko on 11/04/16.
//  Copyright © 2016 Oleksii Pylko. All rights reserved.
//

import Foundation
import CoreBluetooth

class HeartRateMonitor : NSObject {

    // MARK: - Properties
    
    /// The restore identifier of the Heart Rate Monitor
    static var centralManagerIdentifier = "HeartRateCentralManagerIdentifier"
    
    /// The delegate of the Heart Rate Monitor
    var delegate: HeartRateMonitorDelegate?
    
    private var centralManager:CBCentralManager!
    
    private var peripheral:CBPeripheral?
    
    private var peripheralIdentifiers: [NSUUID] = []
    
    init(delegate: HeartRateMonitorDelegate?) {
        super.init()
        self.delegate = delegate
        setup()
    }
    
}

// MARK: - Body sensor location

enum BodySensorLocation : UInt8 {
    case Other
    case Chest
    case Wrist
    case Finger
    case Hand
    case EarLobe
    case Foot
}

//  MARK: - CBCentralManagerDelegate

extension HeartRateMonitor : CBCentralManagerDelegate {
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name)")
        peripheralIdentifiers.append(peripheral.identifier)
        peripheral.discoverServices(Service.UUIDS)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Disconnected to \(peripheral.name)")
        startScan()
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Connecting failed to \(peripheral.name)")
        startScan()
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("Discovered \(peripheral.name)")
        stopScan()
        connectToPeripheral(peripheral)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            handlePoweredOn()
        case .PoweredOff:
            handlePoweredOff()
        case .Unauthorized:
            print("Bluetooth.Unauthorized".localized)
        case .Unsupported:
            print("Bluetooth.Unsupported".localized)
        case .Resetting:
            print("Bluetooth.Resetting".localized)
        case .Unknown:
            print("Bluetooth.Unknown".localized)
        }
    }
    
}

//  MARK: - Private methods for CBCentralManagerDelegate

private extension HeartRateMonitor {

    /**
     Used to represent discovered peripheral services
     */
    enum Service : String, UUIDStringable {
        case DeviceInfo = "180A"
        case HeartRate = "180D"
        case Battery = "180F"
        static var UUIDS: [CBUUID] {
            return [
                DeviceInfo.UUID,
                HeartRate.UUID,
                Battery.UUID
            ]
        }
    }
    
    /**
     Set up Central Manager
     */
    func setup() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: HeartRateMonitor.centralManagerIdentifier])
    }

    /**
     Start peripherals discovering
     */
    func startScan() {
        centralManager.scanForPeripheralsWithServices(Service.UUIDS, options: nil)
    }
    
    /**
     Stop peripherals discovering
     */
    func stopScan() {
        centralManager.stopScan()
    }
    
    /**
     Connect to a peripheral with no discovering
     
     - returns: True if a cached peripheral is found, False otherwise
     */
    func connectToKnownPeripheral() -> Bool {
        let knownPeripherals = centralManager.retrievePeripheralsWithIdentifiers(peripheralIdentifiers)
        if let peripheral = knownPeripherals.first where knownPeripherals.count > 0 {
            connectToPeripheral(peripheral)
            return true
        }
        return false
    }
    
    /**
     Connect to a peripheral
     
     - parameter peripheral: A peripheral
     */
    func connectToPeripheral(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        peripheral.delegate = self
        centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    /**
     Handle bluetooth power on event
     */
    func handlePoweredOn() {
        print("Bluetooth.PoweredOn".localized)
        startScan()
    }
    
    /**
     Handle bluetooth power off event
     */
    func handlePoweredOff() {
        print("Bluetooth.PoweredOff".localized)
        stopScan()
    }

}

//  MARK: - CBPeripheralDelegate

extension HeartRateMonitor : CBPeripheralDelegate {
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(observedServiceCharacteristics(service), forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let characteristicType = Characteristic(rawValue: characteristic.UUID.UUIDString) {
            switch characteristicType {
            case .HeartRateMeasurement:
                heartRateMeasurementCharacteristicDidChange(characteristic)
            case .BatteryLevel:
                batteryLevelCharacteristicDidChange(characteristic)
            case .BodySensorLocation:
                bodySensorLocationCharacteristicDidChange(characteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                discoverServiceCharacteristic(characteristic, forPeripheral: peripheral)
            }
        }
    }
    
}

// MARK: - Private methods

private extension HeartRateMonitor {
    
    /**
     Used to represent interested characteristics of the peripheral services
     */
    enum Characteristic : String, UUIDStringable {
        case HeartRateMeasurement = "2A37"
        case BodySensorLocation = "2A38"
        case BatteryLevel = "2A19"
    }
    
    /**
     Retrieve the list of the service characteristics for observing
     
     - parameter service: A peripheral service
     
     - returns: The UUID array of the service characteristics
     */
    func observedServiceCharacteristics(service: CBService) -> [CBUUID]? {
        if let serviceType = Service(rawValue: service.UUID.UUIDString) {
            switch serviceType {
            case .HeartRate:
                return [Characteristic.HeartRateMeasurement.UUID, Characteristic.BodySensorLocation.UUID]
            case .Battery:
                return [Characteristic.BatteryLevel.UUID]
            case .DeviceInfo:
                return nil
            }
        }
        return nil
    }

    /**
     Discover a service characteristic for a peripheral
     
     - parameter characteristic: A service characteristic
     - parameter peripheral: A peripheral
     */
    func discoverServiceCharacteristic(characteristic: CBCharacteristic, forPeripheral peripheral: CBPeripheral) {
        if let characteristicType = Characteristic(rawValue: characteristic.UUID.UUIDString) {
            switch characteristicType {
            case .HeartRateMeasurement:
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            case .BodySensorLocation,
                 .BatteryLevel:
                peripheral.readValueForCharacteristic(characteristic)
            }
        }
    }
    
    /**
     Process the change of the heart rate measurement characteristic
     
     - parameter characteristic: A service characteristic
     */
    func heartRateMeasurementCharacteristicDidChange(characteristic: CBCharacteristic) {
        if let data = characteristic.value {
            var bytes = data.arrayOfBytes()
            var bpm:UInt16?
            if (bytes[0] & 0x01) == 1 {
                bpm = (UInt16(bytes[1]) << 8) | UInt16(bytes[2])
            } else {
                bpm = UInt16(bytes[1])
            }
            delegate?.didChangeHeartRate?(bpm!)
        }
    }
    
    /**
     Process the change of the battery level characteristic
     
     - parameter characteristic: A service characteristic
     */
    func batteryLevelCharacteristicDidChange(characteristic: CBCharacteristic) {
        if let data = characteristic.value {
            var bytes = data.arrayOfBytes()
            let batteryLevel  = bytes[0]
            delegate?.didChangeBatteryLevel?(batteryLevel)
        }
    }

    /**
     Process the change of the body sensor location
     
     - parameter characteristic: A service characteristic
     */
    func bodySensorLocationCharacteristicDidChange(characteristic: CBCharacteristic) {
        if let data = characteristic.value {
            var bytes = data.arrayOfBytes()
            let location = bytes[0]
            delegate?.didChangeBodySensorLocation?(location)
        }
    }
    
}

