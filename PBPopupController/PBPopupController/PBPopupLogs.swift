//
//  PBPopupLogs.swift
//  PBPopupController
//
//  Created by Patrick BODET on 23/12/2018.
//  Copyright © 2018-2022 Patrick BODET. All rights reserved.
//

import Foundation

@objc public class PBPopupLogs: NSObject {
    
    public static var instance = PBPopupLogs()
    
    public var isEnabled: Bool = true
}

/**
 Logs a message to the Apple System Log facility.
 */
public func PBLog<T>( _ object: @autoclosure() -> T, error: Bool = false, file: String = #fileID, function: String = #function, _ line: Int = #line)
{
    #if DEBUG
    if PBPopupLogs.instance.isEnabled || !file.contains("PBPopupController/") {
        let value = object()
        let stringRepresentation: String
        
        if let value = value as? CustomDebugStringConvertible
        {
            stringRepresentation = value.debugDescription
        }
        else if let value = value as? CustomStringConvertible
        {
            stringRepresentation = value.description
        }
        else
        {
            fatalError("PBLog only works for values that conform to CustomDebugStringConvertible or CustomStringConvertible")
        }
        
        //let fileURL = NSURL(string: file)?.lastPathComponent ?? "Unknown file"
        let fileURL = NSURL(string: file.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlPathAllowed) ?? " ")?.lastPathComponent ?? "Unknown file"
        let queue = Thread.isMainThread ? "UI" : "BG"
        let gFormatter = DateFormatter()
        gFormatter.dateFormat = "HH:mm:ss:SSS"
        let timestamp = gFormatter.string(from: Date())
        
        print((error ? "🆘" : "✅") + " \(timestamp) {\(queue)} \(fileURL) > \(function)[\(line)]: " + stringRepresentation + "\n")
    }
    #endif
}
