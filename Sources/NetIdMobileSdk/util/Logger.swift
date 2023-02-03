// Copyright 2022 European netID Foundation (https://enid.foundation)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
