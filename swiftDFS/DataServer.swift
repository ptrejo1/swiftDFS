//
//  DataServer.swift
//  swiftDFS
//
//  Created by Phoenix Trejo on 10/10/20.
//

import Foundation

class DataServer {
    
    let size = 0.0
    
    var isAvailable = true
    
    private let serverLock = NSLock()
    private let conditionLock = NSCondition()
    
    private var command: Command?

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
            }
        }
    }
    
    func put(_ command: PutCommand) {
        print("put cmd")
    }
    
    func read(_ command: ReadCommmand) {
        print("read cmd")
    }
}
