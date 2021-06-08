//
//  FilesViewModel.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/16/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import UIKit
import Combine
import MediaKit
import TorrentKit

final class FilesViewModel: NSObject, ListViewModelProtocol {

    var title: String { return "Files" }
    var icon: UIImage? { return nil }
    
    var sections = [Section]()
    
    private let sectionsSubject = PassthroughSubject<[Section], Never>()
    var sectionsPublisher: AnyPublisher<[Section], Never>? { sectionsSubject.eraseToAnyPublisher() }
    
    private let rowSubject = PassthroughSubject<(Row, IndexPath), Never>()
    var rowPublisher: AnyPublisher<(Row, IndexPath), Never>?
    
    var presenter: ControllerPresenter?
    
    // MARK: -

    init(directory: Directory) {
        super.init()
        let dirRows = directory.allSubDirectories.map({ file in
            Row(file: file, action: {
                let filesVM = FilesViewModel(directory: file)
                let controller = ListViewController(viewModel: filesVM)
                self.presenter?.push(controller)
            })
        })
        let fileRows = directory.allFiles.map({ file in
            Row(file: file, action: {
                var controller: UIViewController!
                if file.isVideo() {
                    controller = VLCPlayerViewController(previewItem: file)
                } else {
                    #if os(iOS)
                    controller = QuickLookViewController(previewItem: file)
                    #endif
                }
                self.presenter?.present(controller)
            })
        })
        self.sections = [Section(title: nil, rows: dirRows + fileRows)]
    }
    
    func removeItem(at indexPath: IndexPath) { }
    
    func start() {
        sectionsSubject.send(sections)
    }

}

extension Row {
    
    private static var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()

    init(file: FileProtocol, action: RowAction? = nil) {
        self.id = file.name
        self.title = file.name
        if let action = action {
            self.rowType = .navigation(action)
        }
    }
    
}
