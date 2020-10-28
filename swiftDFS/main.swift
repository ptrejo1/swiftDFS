//
//  main.swift
//  swiftDFS
//
//  Created by Phoenix Trejo on 10/10/20.
//

import Foundation

let replicationFactor = 3
let initialDataServersCount = 4

func main() {
    let nameServer = NameServer(replicationFactor: replicationFactor)
    let dataServers = (0..<initialDataServersCount).map { _ in DataServer() }
    
    dataServers.forEach { nameServer.addServer(server: $0) }
    dataServers.forEach { server in
        Thread.detachNewThread { server.run() }
    }
    
    nameServer.run()
}

main()
