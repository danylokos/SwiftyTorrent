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
        }.listStyle(PlainListStyle())
        .truncationMode(.middle)
        #if os(iOS)
        .navigationBarTitle(model.title, displayMode: .inline)
        #endif
        .fullScreenCover(item: $selectedItem) { item in
            Group {
                if item.isVideo() {
                    VLCViewHost(previewItem: item)
                } else {
                    #if os(iOS)
                    QLViewHost(previewItem: item)
                    #else
                    Text("Not Supported")
                    Spacer()
                    Text(item.name)
                    #endif
                }
            }.edgesIgnoringSafeArea(.all)
        }
    }
    
}
