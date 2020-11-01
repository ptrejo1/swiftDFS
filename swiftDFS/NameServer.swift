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
    
    var chunkNumber: Int {
        return size / chunkSize
    }
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
            case "read":
                read(commandArgs)
            case "fetch":
                fetch(commandArgs)
            case "locate":
                locate(commandArgs)
            default:
                printErr("invalid command")
                continue
            }
            
            dataServers.forEach {
                while !$0.isAvailable {
                    $0.wait()
                    $0.broadcast()
                }
            }
            
            switch argument {
            case "read":
                processRead(commandArgs)
            default:
                break
            }
        }
    }
    
    func list(_ args: [String]) {
        guard args.count == 1 else {
            printErr("invalid extra args")
            return
        }
        
        print("File\tFileId\tChunkNumber")
        fileTree.list(fileTable: meta)
    }
    
    func put(_ args: [String]) {
        guard args.count == 3 else {
            printErr("usage: put source_file_path dfs_dest_file_path")
            return
        }
        
        let sourceFile = args[1], destFile = args[2]
        guard
            let fileUrl = URL(string: sourceFile),
            let fh = try? FileHandle(forReadingFrom: fileUrl)
        else {
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
    
    func read(_ args: [String]) {
        guard args.count == 3 else {
            printErr("usage: read dfs_source_file_path dest_file_path")
            return
        }
        guard let fileInfo = meta[args[1]] else {
            printErr("error: no such file in miniDFS")
            return
        }
        
        dataServers.forEach {
            let cmd = ReadCommmand(fid: fileInfo.fid, size: fileInfo.size)
            $0.setCommand(cmd)
            $0.broadcast()
        }
    }
    
    func fetch(_ args: [String]) {
        guard args.count == 4 else {
            printErr("usage: fetch FileID Offset dest_file_path")
            return
        }
        
        dataServers.forEach {
            let cmd = FetchCommand(fid: Int(args[1])!, offset: Int(args[2])!)
            $0.setCommand(cmd)
            $0.broadcast()
        }
    }
    
    func locate(_ args: [String]) {
        guard args.count == 3 else {
            printErr("usage: locate fileID Offset")
            return
        }
        
        dataServers.forEach {
            let cmd = LocateCommand(fid: Int(args[1])!, offset: Int(args[2])!)
            $0.setCommand(cmd)
            $0.broadcast()
        }
    }
    
    func processRead(_ args: [String]) {
        for server in dataServers {
            defer { server.readData = nil }
            guard let fileData = server.readData else {
                continue
            }
            
            let destFile = args[2]
            FileManager.default.createFile(atPath: destFile, contents: nil, attributes: nil)
            guard let fh = FileHandle(forWritingAtPath: destFile) else {
                printErr("unable to create destination file")
                continue
            }
            
            fh.write(fileData)
        }
    }
}
