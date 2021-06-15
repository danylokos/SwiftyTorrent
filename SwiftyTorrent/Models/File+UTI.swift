//
//  File+UTI.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 02.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers

extension File {
    
    private var fileExtension: String {
        return URL(fileURLWithPath: path).pathExtension
    }
        
    var isVideo: Bool {
        // Special handling for 'mkv' container
        switch fileExtension {
        case "mkv": return true
        default: break
        }
        // Other file extensions
        guard
            let mimeUTI = UTType(filenameExtension: fileExtension)
        else { return false }
        return mimeUTI.conforms(to: .audiovisualContent)
    }
    
}
