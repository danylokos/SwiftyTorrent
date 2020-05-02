//
//  TorrentsView.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/1/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI
import Combine

struct TorrentsView: View {
    
    @ObservedObject var model: TorrentsViewModel
    
    var body: some View {
        let buttonTintColor = Color.blue
        return NavigationView {
            List {
                Section(header: Text("Downloads")) {
                    ForEach(model.torrents, id: \.infoHash) { torrent in
                        TorrentRow(model: torrent)
                    }.onDelete { (indexSet) in
                        for index in indexSet {
                            guard let torrent = self.model.torrents?[index] else { return }
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
            }.navigationBarTitle("Torrents")
        }.navigationViewStyle(StackNavigationViewStyle())
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
