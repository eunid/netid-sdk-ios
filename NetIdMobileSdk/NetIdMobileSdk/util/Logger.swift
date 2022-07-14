//
// Created by Tobias Riesbeck on 07/13/2022.
//

import Foundation
import os

class Logger {

    public static let shared = Logger()

    public func debug(_ message: String, file: String = #file, function: String = #function) {
        log(type: .debug, message: "\((file as NSString).lastPathComponent)::\(function), \(message)")
    }

    public func info(_ message: String, file: String = #file, function: String = #function) {
        log(type: .info, message: "\((file as NSString).lastPathComponent)::\(function), \(message)")
    }

    public func error(_ message: String, file: String = #file, function: String = #function) {
        log(type: .error, message: "\((file as NSString).lastPathComponent)::\(function), \(message)")
    }

    public func fault(_ message: String, file: String = #file, function: String = #function) {
        log(type: .fault, message: "\((file as NSString).lastPathComponent)::\(function), \(message)")
    }

    private func log(type: OSLogType, message: String) {
        var levelString: String
        switch type {
        case .info:
            levelString = "INFO"
        case .debug:
            levelString = "DEBUG"
        case .error:
            levelString = "ERROR"
        case .fault:
            levelString = "FAULT"
        default:
            levelString = "DEFAULT"
        }
        let customLog = OSLog(subsystem: "", category: levelString)
        os_log("%@", log: customLog, type: type, message)
    }
}
