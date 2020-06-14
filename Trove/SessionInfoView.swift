//
//  SessionInfoView.swift
//  Trove
//
//  Created by Carter Randall on 2020-06-05.
//  Copyright © 2020 Carter Randall. All rights reserved.
//

import UIKit

class SessionInfoView: UIView {
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.layer.cornerRadius = 5
        blurView.clipsToBounds = true
        addSubview(blurView)
        blurView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 16, paddingBottom: 4, paddingRight: 16, width: 0, height: 0)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
