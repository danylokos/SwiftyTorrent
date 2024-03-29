//
//  TorrentsView.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/1/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI
import Combine
import TorrentKit

struct TorrentsView: View {
    
    @ObservedObject var model: TorrentsViewModel

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Downloads")) {
                    ForEach(model.torrents, id: \.infoHash) { torrent in
                        NavigationLink(destination: FilesView(model: torrent.directory)) {
                            TorrentRow(model: torrent)
                        }.contextMenu {
                            Button(role: .destructive) { model.remove(torrent) } label: {
                                Label("Remove torrent", systemImage: "trash")
                            }
                            Button(role: .destructive) { model.remove(torrent, deleteFiles: true) } label: {
                                Label("Remove all data", systemImage: "trash")
                            }
                        }.disabled(!torrent.hasMetadata)
                    }
                }
                #if DEBUG
                Section(header: Text("Debug")) {
                    Button("Add test torrent files") {
                        model.addTestTorrentFiles()
                    }
                    Button("Add test magnet links") {
                        model.addTestMagnetLinks()
                    }
                    Button("Add all test torrents") {
                        model.addTestTorrents()
                    }
                }
                #if os(iOS)
                .buttonStyle(BlueButton())
                #endif
                #endif
            }
            .refreshable { model.reloadData() }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Torrents")
        }
        .alert(isPresented: model.isPresentingAlert) { () -> Alert in
            Alert(error: model.activeError!)
        }
    }

}

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.blue)
    }
}

extension Alert {
    init(error: Error) {
        self = Alert(
            title: Text("Error"),
            message: Text(error.localizedDescription),
            dismissButton: .default(Text("OK"))
        )
    }
}

#if DEBUG
struct TorrentsView_Previews: PreviewProvider {
    static var previews: some View {
        // Use stubs
        registerStubs()
        let model = TorrentsViewModel()
        return TorrentsView(model: model).environment(\.colorScheme, .dark)
    }
}
#endif
