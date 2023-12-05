//
//  BMPlayerItem.swift
//  Pods
//
//  Created by BrikerMan on 16/5/21.
//
//

import Foundation
import AVFoundation

public class BMPlayerResource {
    
    public let name: String
    
    public let cover: URL?
    
    public var subtitle: BMSubtitles?
    
    public let definitions: [BMPlayerResourceDefinition]
    
    public convenience init(url: URL, name: String = "", cover: URL? = nil, subtitle: URL? = nil) {
        let definition = BMPlayerResourceDefinition(url: url, definition: "")
        
        var subtitles: BMSubtitles? = nil
        if let subtitle = subtitle {
            subtitles = BMSubtitles(url: subtitle)
        }
        
        self.init(name: name, definitions: [definition], cover: cover, subtitles: subtitles)
    }
    
    public init(name: String = "", definitions: [BMPlayerResourceDefinition], cover: URL? = nil, subtitles: BMSubtitles? = nil) {
        self.name        = name
        self.cover       = cover
        self.subtitle    = subtitles
        self.definitions = definitions
    }
    
}


open class BMPlayerResourceDefinition {
    
    public let url: URL
    
    public let definition: String
    
    /// An instance of NSDictionary that contains keys for specifying options for the initialization of the AVURLAsset. See AVURLAssetPreferPreciseDurationAndTimingKey and AVURLAssetReferenceRestrictionsKey above.
    public var options: [String : Any]?
    
    open var avURLAsset: AVURLAsset {
        get {
            guard !url.isFileURL, url.pathExtension != "m3u8" else {
                return AVURLAsset(url: url)
            }
            return BMPlayerManager.asset(for: self)
        }
    }
    
    public init(url: URL, definition: String, options: [String : Any]? = nil) {
        self.url        = url
        self.definition = definition
        self.options    = options
    }
    
}
