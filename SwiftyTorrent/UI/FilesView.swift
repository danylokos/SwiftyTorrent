//
//  FilesView.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/16/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI
import MediaKit

struct FilesView: View {
    
    var model: FilesViewModel
    @State var selectedItem: File?
    @State var selectedVideo: File?

    var body: some View {
        List {
            ForEach(model.directory.allSubDirectories, id: \.path) { subDir in
                NavigationLink(destination: FilesView(model: subDir)) {
                    FileRow(model: subDir)
                }
            }
            ForEach(model.directory.allFiles, id: \.path) { item in
                Button(action: {
                    if item.isVideo {
                        self.selectedVideo = item
                    } else {
                        self.selectedItem = item
                    }
                }) {
                    FileRow(model: item)
                }
            }
        }.listStyle(PlainListStyle())
        .truncationMode(.middle)
        #if os(iOS)
        .navigationBarTitle(model.title, displayMode: .inline)
        #endif
        .sheet(item: $selectedItem) { item in
            NavigationView {
                Group {
                    #if os(iOS)
                    QLViewHost(previewItem: item)
                    #else
                    Text("Not Supported")
                    Spacer()
                    Text(item.name)
                    #endif
                }
                .navigationBarItems(leading: Button("Done") { selectedItem = nil })
                #if os(iOS)
                .navigationBarTitle(item.name, displayMode: .inline)
                #endif
            }
        }
        .fullScreenCover(item: $selectedVideo) { item in
            VLCViewHost(previewItem: item)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
}
