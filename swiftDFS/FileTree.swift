//
//  FileTree.swift
//  swiftDFS
//
//  Created by Phoenix Trejo on 10/22/20.
//

import Foundation

class TreeNode {
    
    let value: String
    let isFile: Bool
    
    var parent: TreeNode? = nil
    var firstSon: TreeNode? = nil
    var nextSibling: TreeNode? = nil
    
    init(value: String, isFile: Bool = true) {
        self.value = value
        self.isFile = isFile
    }
}

class FileTree {
    
    private let root = TreeNode(value: "/", isFile: false)
    
    func list(fileTable: [String: FileInfo]) {
        list(node: root, fileTable: fileTable)
    }
    
    private func list(node: TreeNode?, fileTable: [String: FileInfo]) {
        guard let node = node else { return }
        
        if let fileInfo = fileTable[node.value] {
            print(String("\(node.value)\t\(fileInfo.fid)\t\(fileInfo.chunkNumber)"))
        } else {
            print(String("\(node.value)\t\("nil")\t\("nil")"))
        }
        
        list(node: node.firstSon, fileTable: fileTable)
        list(node: node.nextSibling, fileTable: fileTable)
    }
    
    func insert(filePath: String) -> Bool {
        var parent: TreeNode? = nil
        guard !findNode(path: filePath, lastNode: &parent) else {
            return false
        }
        
        let newNode = TreeNode(value: filePath)
        newNode.parent = parent
        var son = parent?.firstSon
        
        if son != nil {
            while son!.nextSibling != nil {
                son = son!.nextSibling
            }
            son!.nextSibling = newNode
        } else {
            parent?.firstSon = newNode
        }
        
        while son != nil {
            son = son?.nextSibling
        }
        son = newNode
        
        return true
    }
    
    private func findNode(path: String, lastNode: inout TreeNode?) -> Bool {
        let pathComponents = path.components(separatedBy: "/")
        var node = root.firstSon
        lastNode = root
        
        for component in pathComponents {
            while node != nil && node?.value != component {
                node = node?.nextSibling
            }
            
            if node == nil { return false }
            
            lastNode = node
            node = node?.firstSon
        }
        
        return node != nil && node!.isFile
    }
}
