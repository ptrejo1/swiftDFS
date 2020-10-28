//
//  NameServer.swift
//  swiftDFS
//
//  Created by Phoenix Trejo on 10/21/20.
//

import Foundation

struct FileInfo {
    let fid: Int
    let size: Int
}

class NameServer {
    
    let replicationFactor: Int
    
    var meta: [String: FileInfo] = [:]
    
    private let fileTree = FileTree()
    private var dataServers: [DataServer] = []
    private var insertId = 0
    
    init(replicationFactor: Int) {
        self.replicationFactor = replicationFactor
    }
    
    func addServer(server: DataServer) {
        dataServers.append(server)
    }
    
    func parseCommand() -> [String] {
        print("SwiftDFS> ", terminator: "")
        guard let command = readLine() else { return [] }
        return command.components(separatedBy: " ")
    }
    
    func run() {
        while true {
            let commandArgs = parseCommand()
            if commandArgs.isEmpty { continue }
            
            let argument = commandArgs[0]
            switch argument {
            case "quit":
                exit(0)
            case "list", "ls":
                list(commandArgs)
            case "put":
                put(commandArgs)
            default:
                printErr("invalid command")
            }
            
            dataServers.forEach {
                while !$0.isAvailable {
                    $0.wait()
                    $0.broadcast()
                }
            }
        }
    }
    
    func list(_ args: [String]) {
        guard args.count == 1 else {
            printErr("invalid extra args")
            return
        }
        
        print("File\tFileId\tChunkNumber")
        fileTree.list()
    }
    
    func put(_ args: [String]) {
        guard args.count == 3 else {
            printErr("usage: put source_file_path des_file_path")
            return
        }
        
        let sourceFile = args[1], destFile = args[2]
        guard let fh = FileHandle(forReadingAtPath: sourceFile) else {
            printErr("open file error: \(args[1])")
            return
        }
        guard fileTree.insert(filePath: destFile) else {
            printErr("create file error: maybe \(destFile) exists")
            return
        }
        
        let fileData = fh.readDataToEndOfFile()
        let sortedServers = dataServers.sorted { $0.size < $1.size }
        
        insertId += 1
        for i in 0..<replicationFactor {
            meta[destFile] = FileInfo(fid: insertId, size: fileData.count)
            let cmd = PutCommand(fid: insertId, fileData: fileData)
            sortedServers[i].setCommand(cmd)
            sortedServers[i].broadcast()
        }
    }
}