//
//  Extensions.swift
//  Trove
//
//  Created by Carter Randall on 2020-05-31.
//  Copyright © 2020 Carter Randall. All rights reserved.
//

import UIKit

extension UIView {

    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(lessThanOrEqualTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height ).isActive = true
        }
    }
    
    func setShadow(offset: CGSize, opacity: Float, radius: CGFloat, color: UIColor) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        clipsToBounds = false
    }
}


extension Date {
    func timeAgoDisplay() -> String {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "minute"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
    }
    
}

extension UIColor {
    static func heatColor(rank: Int, outOf: Int) -> UIColor{
        var denom = outOf
        if (denom == 0){
            denom = 1
        }
        var alpha = 0.15 + 0.2 * (1.0-(CGFloat(rank + 1)/CGFloat(denom)))
        if (alpha > 0.22){
            alpha = 0.22
        }
        if (alpha < 0.15){
            alpha = 0.15
        }
        return UIColor.red.withAlphaComponent(alpha)
    }
    
   
    
    static func blueHeatColor(rank : Int, outOf : Int) -> UIColor{
        var denom = outOf
        if (denom == 0){
            denom = 1
        }
        var alpha = 0.15 + 0.2 * (1.0-(CGFloat(rank + 1)/CGFloat(denom)))
        if (alpha > 0.22){
            alpha = 0.22
        }
        if (alpha < 0.15){
            alpha = 0.15
        }
        
        return UIColor.blue.withAlphaComponent(alpha)
    }

    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func mainPurple() -> UIColor {
        return UIColor.rgb(red: 186, green: 165, blue: 255)
    }
    
    static func mainRed() -> UIColor {
        return UIColor.rgb(red: 255, green: 45, blue: 85)
//        #ff2d55
    }
    
    static func mainGold() -> UIColor {
        return UIColor.rgb(red: 255, green: 215, blue: 0)
    }
    
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 29, green: 203, blue: 211)
//        #1dcbd3
    }
    
    static func offWhite() -> UIColor {
        return UIColor.rgb(red: 240, green: 240, blue: 240)
    }
    
    static func darkLineColor() -> UIColor {
        return UIColor(white: 0, alpha: 0.1)
    }
    
}

