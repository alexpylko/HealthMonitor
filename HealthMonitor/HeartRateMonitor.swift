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
    }
}

private extension HeartRateMonitor {

    // MARK: - Private methods

    /**
        Set up Central Manager
     */
    func setup() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: HeartRateMonitor.centralManagerIdentifier])
    }
    
    /**
        Used to represent discovered peripheral services
    */
    enum Service : String, UUIDStringable {
        case DeviceInformation = "180A"
        case HeartRate = "180D"
        case Battery = "180F"
        static var UUIDS: [CBUUID] {
            return [
                DeviceInformation.UUID,
                HeartRate.UUID,
                Battery.UUID
            ]
        }
    }

    /**
        Used to represent interested characteristics of the peripheral services
     */
    enum Characteristic : String, UUIDStringable {
        case HeartRateMeasurement = "2A37"
        case BodySensorLocation = "2A38"
        case BatteryLevel = "2A19"
        static var UUIDS: [CBUUID] {
            return [
                self.HeartRateMeasurement.UUID,
                self.BodySensorLocation.UUID
            ]
        }
    }
    
    func startScan2() {
        let knownPeripherals = centralManager.retrievePeripheralsWithIdentifiers(peripheralIdentifiers)
        if knownPeripherals.count > 0 {
            if let peripheral = knownPeripherals.first {
                connectToPeripheral(peripheral)
            }
        }
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
        Connect to a peripheral
        
        - parameter peripheral: A peripheral
     */
    func connectToPeripheral(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        peripheral.delegate = self
        centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    func handlePoweredOn() {
        startScan()
    }
    
    func handlePoweredOff() {
        stopScan()
    }

    /**
        Retrieve the list of the service characteristics for observing
     
        - parameter service: A peripheral service
     
        - returns: The UUID array of the service characteristics
     */
    func observedServiceCharacteristics(service: CBService) -> [CBUUID]? {
        switch Service(rawValue: service.UUID.UUIDString)! {
        case .HeartRate:
            return [Characteristic.HeartRateMeasurement.UUID, Characteristic.BodySensorLocation.UUID]
        case .Battery:
            return [Characteristic.BatteryLevel.UUID]
        case .DeviceInformation:
            return nil
        }
    }
    
    func readPeripheral(peripheral: CBPeripheral, valueForHeartRateMeasurementCharacteristic characteristic: CBCharacteristic) {
        if let data = characteristic.value {
            var bytes = [UInt8](count: data.length, repeatedValue: 0x00)
            data.getBytes(&bytes, length: data.length)
            var bpm:UInt16?
            var offset = 2
            if (bytes[0] & 0x01) == 1 {
                bpm = (UInt16(bytes[1]) << 8) | UInt16(bytes[2])
                offset = 3
            } else {
                bpm = UInt16(bytes[1])
            }
            delegate?.didChangeHeartRate?(bpm!)
            if (bytes[0] & 0x08) == 1 {
                let energy = (UInt16(bytes[offset]) << 8) | UInt16(bytes[offset+1])
                print("Energy: \(energy) kilo joules")
            }
        }
    }
    
    func readPeripheral(peripheral: CBPeripheral, valueForBatteryLevelCharacteristic characteristic: CBCharacteristic) {
        if let data = characteristic.value {
            var bytes = [UInt8](count: data.length, repeatedValue: 0x00)
            data.getBytes(&bytes, length: data.length)
            let batteryLevel  = bytes[0]
            delegate?.didChangeBatteryLevel?(batteryLevel)
        }
    }
    
    func readPeripheral(peripheral: CBPeripheral, valueForBodySensorLocationCharacteristic characteristic: CBCharacteristic) {
        if let data = characteristic.value {
            var bytes = [UInt8](count: data.length, repeatedValue: 0x00)
            data.getBytes(&bytes, length: data.length)
            let location = bytes[0]
            delegate?.didChangeBodySensorLocation?(location)
        }
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
        switch Characteristic(rawValue: characteristic.UUID.UUIDString)! {
        case .HeartRateMeasurement:
            readPeripheral(peripheral, valueForHeartRateMeasurementCharacteristic: characteristic)
        case .BatteryLevel:
            readPeripheral(peripheral, valueForBatteryLevelCharacteristic: characteristic)
        case .BodySensorLocation:
            readPeripheral(peripheral, valueForBodySensorLocationCharacteristic: characteristic)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                switch Characteristic(rawValue: characteristic.UUID.UUIDString)! {
                case .HeartRateMeasurement:
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                case .BodySensorLocation:
                    peripheral.readValueForCharacteristic(characteristic)
                case .BatteryLevel:
                    peripheral.readValueForCharacteristic(characteristic)
                }
            }
        }
    }
    
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
            print("Bluetooth.PoweredOn".localized)
            handlePoweredOn()
        case .PoweredOff:
            print("Bluetooth.PoweredOff".localized)
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
