//
//  QLViewHost.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 01.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI
import QuickLook

public struct QLViewHost: UIViewControllerRepresentable {
    
    public var previewItem: QLPreviewItem
    
    public init(previewItem: QLPreviewItem) {
        self.previewItem = previewItem
    }

    public func makeCoordinator() -> QLViewHost.Coordinator {
        return Coordinator(previewItem: previewItem)
    }
    
    public typealias Context = UIViewControllerRepresentableContext<QLViewHost>
    
    public func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        uiViewController.dataSource = context.coordinator
        uiViewController.delegate = context.coordinator
    }

    public class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        
        var previewItem: QLPreviewItem
        
        init(previewItem: QLPreviewItem) {
            self.previewItem = previewItem
            super.init()
        }
        
        public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return previewItem
        }
        
    }
}
