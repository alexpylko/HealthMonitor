//
//  HeartRateBeat.swift
//  HealthMonitor
//
//  Created by Oleksii Pylko on 15/04/16.
//  Copyright © 2016 Oleksii Pylko. All rights reserved.
//

import Foundation
import RealmSwift

class HeartRateBeat: Object {
    
    dynamic var timestamp = NSDate().timeIntervalSince1970
    dynamic var beat: UInt16 = 0
    
    convenience init(beat: UInt16) {
        self.init()
        self.beat = beat
    }
    
    override class func primaryKey() -> String {
        return "timestamp"
    }
    
}


