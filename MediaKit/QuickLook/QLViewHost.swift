//
//  QLViewHost.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 01.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI
#if canImport(QuickLook)
import QuickLook

class QLPreviewItemWrapper: NSObject, QLPreviewItem {

    var previewItemURL: URL? { _previewItemURL }
    var previewItemTitle: String? { _previewItemTitle }
    
    private var _previewItemURL: URL?
    private var _previewItemTitle: String?
    
    init(previewItem: PreviewItem) {
        _previewItemURL = previewItem.previewItemURL
        _previewItemTitle = previewItem.previewItemTitle
    }

}

public struct QLViewHost: UIViewControllerRepresentable {
    
    public var previewItem: PreviewItem
    
    public init(previewItem: PreviewItem) {
        self.previewItem = previewItem
    }

    public func makeCoordinator() -> QLViewHost.Coordinator {
        return Coordinator(previewItem: previewItem)
    }
    
    public typealias Context = UIViewControllerRepresentableContext<QLViewHost>
    public typealias Controller = QLPreviewController
    
    public func makeUIViewController(context: Context) -> Controller {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: Controller, context: Context) {
        uiViewController.dataSource = context.coordinator
        uiViewController.delegate = context.coordinator
    }

    public class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        
        var previewItem: PreviewItem
        
        init(previewItem: PreviewItem) {
            self.previewItem = previewItem
            super.init()
        }
        
        public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return QLPreviewItemWrapper(previewItem: previewItem)
        }
        
    }
}
#endif
