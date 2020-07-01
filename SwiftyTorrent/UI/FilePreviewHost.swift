//
//  FilePreviewHost.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 01.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI
import QuickLook
import TorrentKit

struct FilePreviewHost: UIViewControllerRepresentable {
    
    var previewItem: QLPreviewItem

    func makeCoordinator() -> FilePreviewHost.Coordinator {
        return Coordinator(previewItem: previewItem)
    }
    
    typealias Context = UIViewControllerRepresentableContext<FilePreviewHost>
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        uiViewController.dataSource = context.coordinator
        uiViewController.delegate = context.coordinator
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        
        var previewItem: QLPreviewItem
        
        init(previewItem: QLPreviewItem) {
            self.previewItem = previewItem
            super.init()
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return previewItem
        }
        
    }
}

extension File: QLPreviewItem {
    
    public var previewItemURL: URL? {
        return TorrentManager.shared().downloadsDirectoryURL()
            .appendingPathComponent(path)
    }
    
    public var previewItemTitle: String? {
        return title
    }
    
}
