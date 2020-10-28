//
//  Command.swift
//  swiftDFS
//
//  Created by Phoenix Trejo on 10/24/20.
//

import Foundation

protocol Command {}

struct PutCommand: Command {
    let fid: Int
    let fileData: Data
}

struct ReadCommmand: Command {
    let fid: Int
    let size: Int
}

struct FetchCommand: Command {
    let fid: Int
    let offset: Int
}

struct LocateCommand: Command {
    let fid: Int
    let offset: Int
}
