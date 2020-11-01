//
//  DataServer.swift
//  swiftDFS
//
//  Created by Phoenix Trejo on 10/10/20.
//

import Foundation

class DataServer {
    
    let name: String
    
    private(set) var size = 0
    var isAvailable = true
    var readData: Data? = nil
    
    private let serverLock = NSLock()
    private let conditionLock = NSCondition()
    
    private var command: Command?
    
    init(_ name: String) {
        self.name = "ds_\(name)"
        shell("mkdir -p \(self.name)")
    }

    func broadcast() {
        conditionLock.broadcast()
    }
    
    func wait() {
        conditionLock.wait()
    }
    
    func setCommand(_ command: Command) {
        serverLock.lock()
        self.command = command
        self.isAvailable = false
        serverLock.unlock()
    }
    
    func run() {
        while true {
            conditionLock.wait()
            defer {
                isAvailable = true
                conditionLock.broadcast()
            }
            
            guard let cmd = command else { continue }
            
            if let putCmd = cmd as? PutCommand {
                put(putCmd)
            } else if let readCmd = cmd as? ReadCommmand {
                read(readCmd)
            } else if let fetchCmd = cmd as? FetchCommand {
                fetch(fetchCmd)
            } else if let locateCmd = cmd as? LocateCommand {
                locate(locateCmd)
            }
        }
    }
    
    func put(_ command: PutCommand) {
        size += command.fileData.count / 1024 / 1024
        var start = 0
        
        while start < command.fileData.count {
            let offset = start / chunkSize
            let filePath = "\(name)/\(command.fid)-\(offset)"
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            
            guard
                let fileUrl = URL(string: filePath),
                let fh = try? FileHandle(forWritingTo: fileUrl)
            else {
                printErr("create file error in dataserver: \(filePath)")
                return
            }
            
            let end = min(chunkSize, command.fileData.count - start)
            fh.write(command.fileData[start..<start + end])
            start += chunkSize
            
            do { try fh.close() }
            catch { print(error) }
        }
    }
    
    func read(_ command: ReadCommmand) {
        var start = 0
        readData = Data()
        
        while start < command.size {
            let offset = start / chunkSize
            let filePath = "\(name)/\(command.fid)-\(offset)"
            
            guard let fh = FileHandle(forReadingAtPath: filePath) else {
                printErr("file not found on dataserver: \(filePath)")
                readData = nil
                return
            }
            
            let length = min(chunkSize, command.size - start)
            readData!.append(fh.readData(ofLength: length))
            start += chunkSize
            
            do { try fh.close() }
            catch { print(error) }
        }
    }
    
    func fetch(_ command: FetchCommand) {
        print("fetch cmd")
    }
    
    func locate(_ command: LocateCommand) {
        print("locate cmd")
    }
}
