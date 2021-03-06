//
//  Utils.swift
//  swiftDFS
//
//  Created by Phoenix Trejo on 10/10/20.
//

import Foundation

let chunkSize = 2 * 1024 * 1024

struct StandardErrorOutputStream: TextOutputStream {
    
    func write(_ string: String) {
        FileHandle.standardError.write(Data(string.utf8))
    }
}

@discardableResult
func shell(_ command: String) -> Int32 {
    let task = Process()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", command]
    task.launch()
    task.waitUntilExit()
    
    return task.terminationStatus
}

func printErr(_ items: Any...) {
    var outputStream = StandardErrorOutputStream()
    print(items, to: &outputStream)
}

extension FileHandle {
    
    func unsafeClose() {
        do { try self.close() }
        catch { printErr(error) }
    }
}
