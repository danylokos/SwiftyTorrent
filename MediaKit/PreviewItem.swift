//
//  PreviewItem.swift
//  MediaKit
//
//  Created by Danylo Kostyshyn on 02.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import Foundation

public protocol PreviewItem {
    
    var previewItemURL: URL? { get }
    var previewItemTitle: String? { get }
    
}
