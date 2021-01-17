//
//  TorrentsView.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/1/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI
import Combine

// https://medium.com/better-programming/swiftui-navigation-links-and-the-common-pitfalls-faced-505cbfd8029b
struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct TorrentsView: View {
    
    @ObservedObject var model: TorrentsViewModel
    
    private let buttonTintColor = Color.blue
    
    #if os(iOS)
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Downloads")) {
                    ForEach(model.torrents, id: \.infoHash) { torrent in
                        NavigationLink(destination: LazyView(FilesView(model: torrent.directory))) {
                            TorrentRow(model: torrent)
                        }
                    }.onDelete { (indexSet) in
                        for index in indexSet {
                            let torrent = self.model.torrents[index]
                            self.model.remove(torrent)
                        }
                    }
                }
                #if DEBUG
                Section(header: Text("Debug")) {
                    Button("Add test torrent files") {
                        self.model.addTestTorrentFiles()
                    }.foregroundColor(buttonTintColor)
                    Button("Add test magnet links") {
                        self.model.addTestMagnetLinks()
                    }.foregroundColor(buttonTintColor)
                    Button("Add all test torrents") {
                        self.model.addTestTorrents()
                    }.foregroundColor(buttonTintColor)
                }
                #endif
            }.navigationBarTitle(Text("Torrents"))
        }.alert(isPresented: model.isPresentingAlert) { () -> Alert in
            Alert(error: model.activeError!)
        }
    }
    #elseif os(tvOS)
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Downloads")) {
                    ForEach(model.torrents, id: \.infoHash) { torrent in
                        NavigationLink(destination: LazyView(FilesView(model: torrent.directory))) {
                            TorrentRow(model: torrent)
                        }
                    }.onDelete { (indexSet) in
                        for index in indexSet {
                            let torrent = self.model.torrents[index]
                            self.model.remove(torrent)
                        }
                    }
                }
            }
        }.alert(isPresented: model.isPresentingAlert) { () -> Alert in
            Alert(error: model.activeError!)
        }
    }
    #endif

}

extension Alert {
    init(error: Error) {
        self = Alert(title: Text("Error"),
                     message: Text(error.localizedDescription),
                     dismissButton: .default(Text("OK")))
    }
}

#if DEBUG
struct TorrentsView_Previews: PreviewProvider {
    static var previews: some View {
        let model = TorrentsViewModel()
        return TorrentsView(model: model).environment(\.colorScheme, .dark)
    }
}
#endif
