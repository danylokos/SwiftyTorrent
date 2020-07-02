//
//  VLCViewHost.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 01.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI
import QuickLook
import MobileVLCKit

public struct VLCViewHost: UIViewControllerRepresentable {
    
    public var previewItem: QLPreviewItem
    
    public init(previewItem: QLPreviewItem) {
        self.previewItem = previewItem
    }

    public func makeCoordinator() -> VLCViewHost.Coordinator {
        return Coordinator(previewItem: previewItem)
    }
    
    public typealias Context = UIViewControllerRepresentableContext<VLCViewHost>
    
    public func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let player = context.coordinator.player
        player.delegate = context.coordinator
        player.drawable = controller.view
        player.play()
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    public static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        coordinator.player.stop()
    }

    public class Coordinator: NSObject, VLCMediaPlayerDelegate {
        
        var previewItem: QLPreviewItem
        var player: VLCMediaPlayer
        
        init(previewItem: QLPreviewItem) {
            self.previewItem = previewItem
            self.player = VLCMediaPlayer()
            if let url = previewItem.previewItemURL {
                player.media = VLCMedia(url: url)
            }
            super.init()
        }
        
    }
}
