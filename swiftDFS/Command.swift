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
