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

    #if os(iOS)
    var body: some View {
        List {
            ForEach(model.directory.allSubDirectories, id: \.path) { subDir in
                NavigationLink(destination: FilesView(model: subDir)) {
                    FileRow(model: subDir)
                }
            }
            ForEach(model.directory.allFiles, id: \.path) { file in
                Button(action: {
                    self.selectedItem = file
                }) {
                    FileRow(model: file)
                }
            }
        }.truncationMode(.middle)
        .navigationBarTitle(Text(model.title), displayMode: .inline) // no tvOS
        .fullScreenCover(item: $selectedItem) { item in
            Group {
                if item.isVideo() {
                    VLCViewHost(previewItem: item)
                } else {
                    QLViewHost(previewItem: item)
                }
            }.edgesIgnoringSafeArea(.all)
        }
    }
    #elseif os(tvOS)
    var body: some View {
        List {
            ForEach(model.directory.allSubDirectories, id: \.path) { subDir in
                NavigationLink(destination: FilesView(model: subDir)) {
                    FileRow(model: subDir)
                }
            }
            ForEach(model.directory.allFiles, id: \.path) { file in
                Button(action: {
                    self.selectedItem = file
                }) {
                    FileRow(model: file)
                }
            }
        }.truncationMode(.middle)
        .fullScreenCover(item: $selectedItem) { item in
            Group {
                if item.isVideo() {
                    VLCViewHost(previewItem: item)
                } else {
                    Text("Not Supported")
                    Spacer()
                    Text(item.name)
                }
            }.edgesIgnoringSafeArea(.all)
        }
    }
    #endif
    
}
