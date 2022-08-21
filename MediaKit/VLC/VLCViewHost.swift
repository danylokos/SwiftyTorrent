//
//  VLCViewHost.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 01.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI
#if os(iOS)
import MobileVLCKit
#elseif os(tvOS)
import TVVLCKit
#endif

public struct VLCViewHost: UIViewControllerRepresentable {
    
    public var previewItem: PreviewItem
    
    public init(previewItem: PreviewItem) {
        self.previewItem = previewItem
    }

    public func makeCoordinator() -> VLCViewHost.Coordinator {
        return Coordinator(previewItem: previewItem)
    }
    
    public typealias Context = UIViewControllerRepresentableContext<VLCViewHost>
    public typealias Controller = VLCPlayerViewController
    
    public func makeUIViewController(context: Context) -> Controller {
        let item = context.coordinator.previewItem
        return VLCPlayerViewController(previewItem: item)
    }
    
    public func updateUIViewController(_ uiViewController: Controller, context: Context) { }
    
    public static func dismantleUIViewController(_ uiViewController: Controller, coordinator: Coordinator) { }

    public class Coordinator: NSObject {
        
        let previewItem: PreviewItem
        
        init(previewItem: PreviewItem) {
            self.previewItem = previewItem
            super.init()
        }
        
    }
    
}

public final class VLCPlayerViewController: UIViewController {
    
    private var previewItem: PreviewItem
    private var player: VLCMediaPlayer
    private let controlsView = ControlsView()
    
    private var controlsHidden = true {
        didSet {
            // Bring `controlsView` in front of player's view when it becames visible
            view.bringSubviewToFront(controlsView)
            UIView.animate(withDuration: 0.3) {
                self.controlsView.alpha = self.controlsHidden ? 0.0 : 0.75
            }
        }
    }
    
    public init(previewItem: PreviewItem) {
        self.previewItem = previewItem
        self.player = VLCMediaPlayer()
        super.init(nibName: nil, bundle: nil)
        if let url = previewItem.previewItemURL {
            player.media = VLCMedia(url: url)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        player.delegate = self
        player.drawable = view
        player.play()
        
        controlsView.alpha = 0.0
        controlsView.delegate = self
        
        view.addSubview(controlsView)
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: [
            controlsView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor,
                constant: 0.0
            ),
            controlsView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -50.0
            )
        ])
        constraints.forEach({ $0.isActive = true })
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(viewDidTap(_:))
            )
        )
    }
    
    @objc func viewDidTap(_ sender: Any) {
        controlsHidden.toggle()
    }
    
    private func togglePlayback() {
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }
    
    private var hideTimer: Timer?
    
    private func hidePlaybackControlsAfterDelay() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            if self.player.isPlaying {
                self.controlsHidden = true
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideTimer?.invalidate()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hidePlaybackControlsAfterDelay()
    }
        
    public override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            switch press.type {
            case .playPause:
                togglePlayback()
            case .select:
                controlsHidden.toggle()
            default: break
            }
        }
    }

}

extension VLCPlayerViewController: VLCMediaPlayerDelegate {
    
    public func mediaPlayerStateChanged(_ aNotification: Notification) {
        guard let player = aNotification.object as? VLCMediaPlayer else { return  }
        switch player.state {
        case .stopped: break
        case .opening: break
        case .buffering: break
        case .ended: break
        case .error: break
        case .playing: break
        case .paused: break
        case .esAdded: break
        default: break
        }
    }

}

extension VLCPlayerViewController: ControlsViewDelegate {
    
    func controlView(_ controlsView: VLCPlayerViewController.ControlsView,
                     didTapAction action: VLCPlayerViewController.ControlsView.Action) {
        switch action {
        case .dismiss:
            dismiss(animated: true, completion: nil)
        case .backward:
            player.jumpBackward(10)
        case .playPause:
            togglePlayback()
        case .forward:
            player.jumpForward(10)
        }
    }
    
}

protocol ControlsViewDelegate: AnyObject {
    func controlView(_ controlsView: VLCPlayerViewController.ControlsView,
                     didTapAction action: VLCPlayerViewController.ControlsView.Action)
}

extension VLCPlayerViewController {
    
    class ControlsView: UIView {
        
        //swiftlint:disable:next nesting
        enum Action: CaseIterable {
            case dismiss
            case backward
            case playPause
            case forward
            
            var systemImageName: String {
                switch self {
                case .dismiss: return "arrow.down.right.and.arrow.up.left"
                case .backward: return "gobackward.10"
                case .playPause: return "playpause"
                case .forward: return "goforward.10"
                }
            }
        }
        
        weak var delegate: ControlsViewDelegate?
        
        private let stackView: UIStackView = {
            let view = UIStackView()
            view.axis = .horizontal
            view.distribution = .fillEqually
            return view
        }()
        
        init() {
            super.init(frame: .zero)
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: -
        
        override var intrinsicContentSize: CGSize {
            CGSize(width: 200.0, height: 44.0)
        }

        private func setup() {
            backgroundColor = .white
            
            layer.cornerRadius = 10.0
            layer.borderWidth = 1.0
            layer.borderColor = UIColor.gray.cgColor
            
            addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            var constraints = [NSLayoutConstraint]()
            constraints.append(contentsOf: [
                stackView.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: 0.0
                ),
                stackView.topAnchor.constraint(
                    equalTo: topAnchor,
                    constant: 0.0
                ),
                stackView.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: 0.0
                ),
                stackView.bottomAnchor.constraint(
                    equalTo: bottomAnchor,
                    constant: 0.0
                )
            ])
            constraints.forEach({ $0.isActive = true })
            
            // Add buttons
            for action in Action.allCases {
                let dismissButton = UIButton(
                    type: .system,
                    primaryAction:
                        UIAction(
                            title: "",
                            image: UIImage(systemName: action.systemImageName),
                            attributes: [],
                            state: .on,
                            handler: { _ in self.delegate?.controlView(self, didTapAction: action) }
                        )
                )
                dismissButton.tintColor = .black
                stackView.addArrangedSubview(dismissButton)
            }
        }
        
    }
    
}
