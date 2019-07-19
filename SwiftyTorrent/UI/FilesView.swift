//
//  FilesView.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/16/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI

struct FilesView : View {
    
    var model: FilesViewModel
    
    var body: some View {
        List {
            ForEach(model.directory.allSubDirectories, id: \.path) { subDir in
                NavigationLink(destination: FilesView(model: FilesViewModel(directory: subDir))) {
                    FileRow(model: subDir)
                }
            }
            ForEach(model.directory.allFiles, id: \.path) { file in
                FileRow(model: file)
            }
        }.truncationMode(.middle)
            .navigationBarTitle(Text(model.title), displayMode: .inline)
    }
    
}
