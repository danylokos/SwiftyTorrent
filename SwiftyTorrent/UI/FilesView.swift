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
    @State var showModal: Bool = false
    @State var selectedItem: File!

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
                    self.showModal.toggle()
                }) {
                    FileRow(model: file)
                }
            }
        }.truncationMode(.middle)
        .navigationBarTitle(Text(model.title), displayMode: .inline) // no tvOS
        .sheet(isPresented: $showModal) {
            NavigationView {
                Group {
                    if self.selectedItem.isVideo() {
                        VLCViewHost(previewItem: self.selectedItem)
                    } else {
                        QLViewHost(previewItem: self.selectedItem)
                    }
                }
            }
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
                    self.showModal.toggle()
                }) {
                    FileRow(model: file)
                }
            }
        }.truncationMode(.middle)
        .sheet(isPresented: $showModal) {
            NavigationView {
                VLCViewHost(previewItem: self.selectedItem)
            }
        }
    }
    #endif
    
}
