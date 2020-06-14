//
//  PreviewCell.swift
//  Trove
//
//  Created by Carter Randall on 2020-06-02.
//  Copyright © 2020 Carter Randall. All rights reserved.
//

import UIKit

class PreviewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 5
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(white: 1, alpha: 0.5)
        return iv
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "2m ago"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.setShadow(offset: .zero, opacity: 0.3, radius: 5, color: UIColor.black)
        return label
    }()
    
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
        
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: frame.height)
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(dateLabel)
        dateLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 20)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
