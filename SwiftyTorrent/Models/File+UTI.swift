//
//  File+UTI.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 02.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import MobileCoreServices

extension File {
    
    private var fileExtension: String {
        return URL(fileURLWithPath: path).pathExtension
    }
    
    private func getMimeType() -> CFString? {
        let fileExt = fileExtension as CFString
        guard
            let extUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExt, nil)?
                .takeUnretainedValue(),
            let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType)?
                .takeUnretainedValue()
            else { return nil }
        return mimeUTI
    }
    
    func isVideo() -> Bool {
        switch fileExtension {
        case "mkv": return true
        default: break
        }
        guard
            let mimeType = getMimeType(),
            let mimeUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType, nil)?
                .takeUnretainedValue()
        else { return false }
        return UTTypeConformsTo(mimeUTI, kUTTypeVideo)
    }
    
}
