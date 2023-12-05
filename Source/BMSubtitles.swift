//
//  BMSubtitles.swift
//  Pods
//
//  Created by BrikerMan on 2017/4/2.
//
//

import Foundation
import Alamofire
import Zip

public class BMSubtitles {
    
    public class Group: NSObject {
        
        public var index: Int
        
        public var start: TimeInterval
        
        public var end  : TimeInterval
        
        public var text : String
        
        public init(_ index: Int, _ start: NSString, _ end: NSString, _ text: NSString) {
            self.index = index
            self.start = Group.parseDuration(start as String)
            self.end   = Group.parseDuration(end as String)
            self.text  = text as String
        }
        
        public static func parseDuration(_ fromStr:String) -> TimeInterval {
            var h: TimeInterval = 0.0, m: TimeInterval = 0.0, s: TimeInterval = 0.0, c: TimeInterval = 0.0
            let scanner = Scanner(string: fromStr)
            scanner.scanDouble(&h)
            scanner.scanString(":", into: nil)
            scanner.scanDouble(&m)
            scanner.scanString(":", into: nil)
            scanner.scanDouble(&s)
            scanner.scanString(",", into: nil)
            scanner.scanDouble(&c)
            return (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)
        }
        
    }
    
    public var groups: [Group] = []

    public var delay: TimeInterval = 0
            
    public init(url: URL, encoding: String.Encoding? = nil, completion: (([Group]) -> Void)? = nil) {
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let zipUrl = documentUrl.appendingPathComponent(url.lastPathComponent)
        let unzipUrl = URL(string: (zipUrl.absoluteString as NSString).deletingPathExtension)!
        
        let haveCache = self.parseData(zipUrl: zipUrl, unzipUrl: unzipUrl, completion: completion)
        if haveCache {return}
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask)
        AF.download(url, to: destination).response { result in
            switch result.result {
            case .success(let _):
                do {
                    try Zip.unzipFile(zipUrl, destination: documentUrl, overwrite: true, password: nil, progress: nil) { unzippedFile in
                        self.parseData(zipUrl: zipUrl, unzipUrl: unzippedFile, completion: completion)
                    }
                } catch {
                    
                }
                break
            case .failure(let error):
                print(result.error?.localizedDescription)
                break
            }
        }
    }
    
    public func parseData(zipUrl: URL, unzipUrl: URL, completion: (([Group]) -> Void)? = nil) -> Bool {
        print(zipUrl.absoluteString)
        print(unzipUrl.absoluteString)
        do {
            let string = try String.init(contentsOfFile: unzipUrl.path, encoding: .utf8)
            let arr = string.components(separatedBy: .newlines)
            self.groups = BMSubtitles.parseSubRip(string) ?? []
            completion?(self.groups)
            return true
        } catch {
            return false
        }
    }
    
    public static func parseSubRip(_ payload: String) -> [Group]? {
        let strings = payload.components(separatedBy: "\n\n")
        var groups: [Group] = []
        for string in strings {
            let str = string + "\n\n"
            let scanner = Scanner(string: str)
            
            var indexString: NSString?
            scanner.scanUpToCharacters(from: .newlines, into: &indexString)
            
            var startString: NSString?
            scanner.scanUpTo(" --> ", into: &startString)
            
            scanner.scanUpTo(" ", into: nil)
            
            var endString: NSString?
            scanner.scanUpTo("\n", into: &endString)
            
            var textString: NSString?
            scanner.scanUpTo("\n\n", into: &textString)

            if let text = textString {
                textString = text.trimmingCharacters(in: .whitespaces) as NSString
                textString = text.replacingOccurrences(of: "\r", with: "") as NSString
            }
            
            if let indexString = indexString,
                let index = Int(indexString as String),
                let start = startString,
                let end   = endString,
                let text  = textString {
                let group = Group(index, start, end, text)
                groups.append(group)
            }
        }
        return groups
    }
    
    public func search(for time: TimeInterval) -> Group? {
        let result = groups.first(where: { group -> Bool in
            if group.start - delay <= time && group.end - delay >= time {
                return true
            }
            return false
        })
        return result
    }
    
}
