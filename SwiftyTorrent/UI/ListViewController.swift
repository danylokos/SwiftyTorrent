//
//  ListViewController.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 03.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import UIKit
import Combine

final class ListViewController: UIViewController {

    private let viewModel: ListViewModelProtocol
    private let tableView = UITableView()
    private lazy var dataSource = makeDataSource()
    private var cancellables = [AnyCancellable]()
    
    init(viewModel: ListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        configUIKit()
        registerObservers()
    }
    
    private func configUIKit() {
        title = viewModel.title
        tabBarItem.title = viewModel.title
        tabBarItem.image = viewModel.icon
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    private var isInitialReload = true
    
    private func registerObservers() {
        viewModel.sectionsPublisher?
            .sink { [weak self] sections in
                guard let self = self else { return }
                //swiftlint:disable:next force_cast
                self.update(with: sections as! [ListViewModel.Section], animate: !self.isInitialReload)
                if self.isInitialReload { self.isInitialReload = false }
        }.store(in: &cancellables)
        
        viewModel.rowPublisher?
            .sink { [weak self] (rowModel, indexPath) in
                self?.updateRow(at: indexPath, rowModel: rowModel)
        }.store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.backgroundColor = .white
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.registerCell(ListCell.self)
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: 0.0).isActive = true
        tableView.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,
            constant: 0.0).isActive = true
        tableView.topAnchor.constraint(
            equalTo: view.topAnchor,
            constant: 0.0).isActive = true
        tableView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: 0.0).isActive = true
        
        viewModel.start()
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<ListViewModel.Section, ListViewModel.Row> {
        return DiffableDataSource(tableView: tableView, viewModel: viewModel)
    }
    
    func update(with sections: [ListViewModel.Section], animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<ListViewModel.Section, ListViewModel.Row>()
        snapshot.appendSections(sections)
        sections.forEach { (section) in
            //swiftlint:disable:next force_cast
            snapshot.appendItems(section.rows as! [ListViewModel.Row], toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animate)
    }
    
    private class DiffableDataSource: UITableViewDiffableDataSource<ListViewModel.Section, ListViewModel.Row> {
        
        private let viewModel: ListViewModelProtocol
        
        init(tableView: UITableView, viewModel: ListViewModelProtocol) {
            self.viewModel = viewModel
            super.init(tableView: tableView,
                cellProvider: { tableView, indexPath, row in
                    guard let rowModel = viewModel.row(at: indexPath)
                        else { fatalError("No row at indexPath: \(indexPath)") }
                    guard let cell = tableView.dequeueReusableCell(rowModel.viewType) as?
                        UITableViewCell & AnyViewModelConfigurable
                        else { fatalError("Bad viewType: \(rowModel.viewType) for rowModel: \(rowModel)") }
                    cell.configure(rowModel)
                    return cell
                }
            )
        }
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return viewModel.sections[section].title
        }
        
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }

        override func tableView(_ tableView: UITableView,
                                commit editingStyle: UITableViewCell.EditingStyle,
                                forRowAt indexPath: IndexPath) {
            viewModel.removeItem(at: indexPath)
        }
        
    }

}

/*
extension ListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowModel = viewModel.row(at: indexPath)
            else { fatalError("No row at indexPath: \(indexPath)") }
        guard let cell = tableView.dequeueReusableCell(rowModel.viewType) as?
            UITableViewCell & AnyViewModelConfigurable
            else { fatalError("Bad viewType: \(rowModel.viewType) for rowModel: \(rowModel)") }
        cell.configure(rowModel)
        return cell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        viewModel.removeItem(at: indexPath)
    }

}
*/
 
extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowModel = viewModel.row(at: indexPath)
            else { fatalError("No row at indexPath: \(indexPath)") }
        rowModel.action?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return viewModel.contextMenuConfig(at: indexPath)
    }

}

extension ListViewController {
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func updateRow(at indexPath: IndexPath, rowModel: RowProtocol) {
        guard let cell = tableView.cellForRow(at: indexPath) as?
            UITableViewCell & AnyViewModelConfigurable
            else { return }
        cell.configure(rowModel)
    }

}
