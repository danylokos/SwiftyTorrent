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
            ForEach(model.files.identified(by: \.self)) { file in
                FileRow(model: file)
            }.truncationMode(.middle)
        }.navigationBarTitle(Text("Files"), displayMode: .inline)
    }
    
}
