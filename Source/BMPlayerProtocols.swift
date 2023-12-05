//
//  BMPlayerProtocols.swift
//  Pods
//
//  Created by BrikerMan on 16/4/30.
//
//

import UIKit

public func BMImageResourcePath(_ fileName: String) -> UIImage? {
    let bundle = Bundle(for: BMPlayer.self)
    return UIImage(named: fileName, in: bundle, compatibleWith: nil)
}

public func formatSecondsToString(_ seconds: TimeInterval) -> String {
    if seconds.isNaN {
        return "00:00:00"
    }
    let hour = Int(seconds / 3600)
    let min = Int(seconds.truncatingRemainder(dividingBy: 3600) / 60)
    let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
    if hour > 0 {
        return String(format: "%d:%02d:%02d", hour, min, sec)
    } else {
        return String(format: "%02d:%02d", min, sec)
    }
}
