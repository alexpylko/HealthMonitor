//
//  Device.swift
//  HealthMonitor
//
//  Created by Oleksii Pylko on 19/04/16.
//  Copyright © 2016 Oleksii Pylko. All rights reserved.
//

import Foundation
import RealmSwift

class Device: Object {
    
    dynamic var identifier: String = ""
    dynamic var name: String?
    
    let heartRateBeats = List<HeartRateBeat>()

    convenience init(identifier: String, name: String?) {
        self.init()
        self.identifier = identifier
        self.name = name ?? identifier
    }
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
}
