//
//  NSDataExtension.swift
//  HealthMonitor
//
//  Created by Oleksii Pylko on 13/04/16.
//  Copyright © 2016 Oleksii Pylko. All rights reserved.
//

import Foundation

extension NSData {
    
    func arrayOfBytes() -> [UInt8] {
        var bytes = [UInt8](count: self.length, repeatedValue: 0x00)
        getBytes(&bytes, length: self.length)
        return bytes
    }

}