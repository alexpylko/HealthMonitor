//
//  UUIDStringable.swift
//  HealthMonitor
//
//  Created by Oleksii Pylko on 10/04/16.
//  Copyright © 2016 Oleksii Pylko. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol UUIDStringable : RawRepresentable, Equatable {
    var UUID: CBUUID { get }
    
    func isEqual(uuid: CBUUID) -> Bool
}

extension UUIDStringable where RawValue == String {
    
    var UUID: CBUUID {
        return CBUUID(string: self.rawValue)
    }
    
    func isEqual(uuid: CBUUID) -> Bool {
        return self.UUID.isEqual(uuid)
    }
}

