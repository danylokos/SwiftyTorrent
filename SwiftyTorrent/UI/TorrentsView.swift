//
//  TorrentsView.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/1/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI
import Combine

struct TorrentsView : View {
    
    @ObjectBinding var model: TorrentsViewModel
    
    private let buttonTintColor = Color.blue
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Downloads")) {
                    ForEach(model.torrents) { torrent in
                        NavigationLink(destination: FilesView(model: torrent.directory)) {
                            TorrentRow(model: torrent)
                        }
                    }.onDelete { (indexSet) in
                        for index in indexSet {
                            let torrent = self.model.torrents[index]
                            self.model.remove(torrent)
                        }
                    }
                }
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
            }.navigationBarTitle(Text("Torrents"))
        }
    }
    
}

#if DEBUG
struct TorrentsView_Previews : PreviewProvider {
    static var previews: some View {
        let model = TorrentsViewModel()
        return TorrentsView(model: model).environment(\.colorScheme, .dark)
    }
}
#endif
