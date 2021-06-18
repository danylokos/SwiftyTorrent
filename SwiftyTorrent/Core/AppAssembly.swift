//
//  AppAssembly.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 17.06.2021.
//  Copyright © 2021 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import Swinject
import TorrentKit

private let swinjectContiner = Container()

func registerDependencies() {
    swinjectContiner.register(TorrentManagerProtocol.self) { _ in TorrentManager.shared() }
    swinjectContiner.register(IMDBDataProviderProtocol.self) { _ in IMDBDataProvider() }
    swinjectContiner.register(EZTVDataProviderProtocol.self) { _ in EZTVDataProvider() }
}

func registerComponent<T>(_ type: T.Type, resolver: @escaping () -> T) {
    swinjectContiner.register(type, factory: { _ in resolver() })
}

func resolveComponent<T>(_ type: T.Type) -> T {
    guard let service = swinjectContiner.resolve(type) else {
        fatalError("Missing dependency: \(type)")
    }
    return service
}

#if DEBUG
func registerStubs() {
    registerComponent(TorrentManagerProtocol.self) { StubTorrentManager() }
    registerComponent(IMDBDataProviderProtocol.self) { StubIMDBDataProvider() }
    registerComponent(EZTVDataProviderProtocol.self) { StubEZTVDataProvider() }
}
#endif
