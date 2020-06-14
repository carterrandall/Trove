//
//  Models.swift
//  Trove
//
//  Created by Carter Randall on 2020-06-02.
//  Copyright © 2020 Carter Randall. All rights reserved.
//

import UIKit
import ARKit

struct Map {
    var worldMap: ARWorldMap?
    var snapshot: UIImage?
    var note: String
    var date: Date
    
    
    init(dictionary: [String: Any]) {
        self.worldMap = dictionary["worldMap"] as? ARWorldMap ?? nil
        self.snapshot = dictionary["snapshot"] as? UIImage ?? nil
        self.note = dictionary["note"] as? String ?? ""
        let secondsFrom1970 = dictionary["date"] as? Double ?? 0
        self.date = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
