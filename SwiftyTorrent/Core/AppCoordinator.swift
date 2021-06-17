//
//  AppCoordinator.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/12/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import TorrentKit

protocol ApplicationCoordinator {

    func start()
    
}

final class AppCoordinator: ApplicationCoordinator {
    
    private var window: UIWindow!
    private var torrentManager: TorrentManagerProtocol {
        resolveComponent(TorrentManagerProtocol.self)
    }
    private var cancellables = [Cancellable]()
    
    init(window: UIWindow) {
        self.window = window
        
        cancellables.append(contentsOf: [
            NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
                .sink { [unowned self] _ in
                    self.registerBackgroundTask()
            }]
        )
    }
    
    deinit {
        cancellables.forEach({ $0.cancel() })
    }

    func handleOpenURLContexts(_ URLContexts: Set<UIOpenURLContext>) {
        guard let URLContext = URLContexts.first else { return }
        torrentManager.open(URLContext.url)
    }

    // MARK: - ApplicationCoordinator
    
    func start() {
        registerDependencies()
        
        window.rootViewController = UIHostingController(rootView: MainView())
        window.makeKeyAndVisible()
        
        requestUserNotifications()
        
        // Prevent screen from dimming
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    // MARK: -
    
    private func requestUserNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (_, error) in
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != .invalid)
    }
    
    private func endBackgroundTask() {
        print("Background task ended.")
        showLocalNotification()
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    private func showLocalNotification() {
        #if os(iOS)
        let content = UNMutableNotificationContent()
        content.title = "SwiftyTorrent"
        content.body = "Suspending session..."
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "SuspendingSession", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error: Error?) in
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
        #endif
    }

}
