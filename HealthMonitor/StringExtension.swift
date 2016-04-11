//
//  StringExtension.swift
//  SplitGreens
//
//  Created by Oleksii Pylko on 02/12/15.
//  Copyright © 2015 Oleksii Pylko. All rights reserved.
//
import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
    func format(args: CVarArgType...) -> String {
        return String(format: self, arguments: args)
    }
}
