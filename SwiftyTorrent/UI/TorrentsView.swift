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
    
    func showAlert(_ title: String, _ message: String ,_ handler: @escaping (_ action: UIAlertAction) -> Void) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(.init(
            title: "OK",
            style: .destructive,
            handler: handler
        ))
        
        alertController.addAction(.init(
            title: "Cancel", style: .default
        ))
        
        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Downloads")) {
                    ForEach(model.torrents, id: \.infoHash) { torrent in
                        NavigationLink(destination: FilesView(model: torrent.directory)) {
                            TorrentRow(model: torrent)
                        }.contextMenu {
                            Button() {
                                showAlert( "Are you sure", "Are you sure want to \(torrent.paused ? "Resume" : "pause")") {action in
                                    if(torrent.paused) {
                                        model.resumeTorrent(torrent)
                                    } else {
                                        model.pauseTorrent(torrent)
                                    }
                                }
                            } label: {
                                Label("\(torrent.paused ? "Resume": "Pause") torrent", systemImage: torrent.paused ? "play" : "pause")
                            }
                            Button(role: .destructive) {
                                showAlert("Are you sure", "Are you sure want to remove") {action in
                                    model.remove(torrent)
                                }
                            } label: {
                                Label("Remove torrent", systemImage: "trash")
                            }
                            Button(role: .destructive) {
                                showAlert("Are you sure", "Are you sure want to Remove all data ?") {action in
                                    model.remove(torrent, deleteFiles: true)
                                }
                            } label: {
                                
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
