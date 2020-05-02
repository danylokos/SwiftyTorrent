//
//  File.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/17/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import SwiftUI

protocol FileProtocol: FileRowModel {

    var name: String { get }
    
    var path: String { get }
    
    func recursiveDescription(_ level: Int)
    
}

extension FileProtocol {
    
    var title: String {
        return name
    }

}

class File: FileProtocol, CustomStringConvertible {
    
//    var id: String {
//        return path
//    }

    let name: String
    
    let path: String
    
    init(name: String, path: String) {
        self.name = name
        self.path = path
    }
    
    var description: String {
        return name //+ " (\(path))"
    }
    
    func recursiveDescription(_ level: Int) {
        let tab = String(repeating: "\t", count: level)
        print(tab + "⎜" + description)
    }
}

class Direcctory: FileProtocol, CustomStringConvertible {
    
//    var id: String {
//        return path
//    }

    let name: String
    
    let path: String
    
    var files: [FileProtocol]
    
    var allSubDirectories: [Direcctory] {
        //swiftlint:disable:next force_cast
        return files.filter({ type(of: $0) == Direcctory.self }) as! [Direcctory]
    }
    
    var allFiles: [File] {
        //swiftlint:disable:next force_cast
        return files.filter({ type(of: $0) == File.self }) as! [File]
    }
    
    init(name: String, path: String, files: [FileProtocol]? = nil) {
        self.name = name
        self.path = path
        self.files = files ?? []
    }
    
    var description: String {
        return name
    }
    
    func recursiveDescription(_ level: Int) {
        let tab = String(repeating: "\t", count: level)
        print(tab + "⎣" + description)
        
        // print all subdiectories first
        func nameOrder(lhs: FileProtocol, rhs: FileProtocol) -> Bool {
            return lhs.name < rhs.name
        }
        
        for dir in allSubDirectories.sorted(by: nameOrder) {
            dir.recursiveDescription(level + 1)
        }
        
        // all files after
        for file in allFiles.sorted(by: nameOrder) {
            file.recursiveDescription(level + 1)
        }
    }
    
    class func directory(from filePaths: [String]) -> Direcctory {
        let rootDir = Direcctory(name: "/", path: "")
        for filePath in filePaths {
            var lastDir = rootDir
            let components = filePath.components(separatedBy: "/")
            for (idx, component) in components.enumerated() {
                let isLast = (idx == components.count - 1)
                let path = lastDir.path + "/" + component
                if isLast {
                    let file = File(name: component, path: path)
                    lastDir.files.append(file)
                } else {
                    var dir: Direcctory! = lastDir.files.first(where: { $0.name == component }) as? Direcctory
                    if dir == nil {
                        dir = Direcctory(name: component, path: path)
                        lastDir.files.append(dir)
                    }
                    lastDir = dir
                }
            }
        }
        return rootDir
    }
    
}
