//
//  SaveButton.swift
//  Trove
//
//  Created by Carter Randall on 2020-06-01.
//  Copyright © 2020 Carter Randall. All rights reserved.
//

import UIKit

class SaveButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor.mainGold()
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = UIColor.mainGold()
                setTitleColor(UIColor.white, for: .normal)
            } else {
                backgroundColor = .none
//                setTitleColor(UIColor.gray, for: .normal)
            }
        }
    }
}
