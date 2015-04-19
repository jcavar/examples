//
//  TableViewDataSource.swift
//  Dubchat
//
//  Created by Josip Cavar on 12/03/15.
//  Copyright (c) 2015 Alen Radolovic. All rights reserved.
//

import UIKit

public struct RegisteredTableViewCellFactory<Cell: UITableViewCell, Item> {
    
    private let reuseIdentifier: String
    private let cellConfigurator: ((Cell, Item, NSIndexPath) -> ())?
    
    init(reuseIdentifier: String, cellConfigurator: ((Cell, Item, NSIndexPath) -> ())?) {

        self.reuseIdentifier = reuseIdentifier
        self.cellConfigurator = cellConfigurator
    }
    
    public func cellForItem(item: Item, inTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> Cell {

        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! Cell
        cellConfigurator?(cell, item, indexPath)
        return cell
    }
}

public struct RegisteredTableViewCellEditor<Cell: UITableViewCell, Item> {
    
    private let cellEditor: (Item) -> (Bool)
    private let deleteAction: ((Item, NSIndexPath) -> ())?
    private let insertAction: ((Item) -> ())?

    public init(cellEditor: (Item) -> (Bool), deleteAction: ((Item, NSIndexPath) -> ())?, insertAction: ((Item) -> ())?) {
        
        self.cellEditor = cellEditor
        self.deleteAction = deleteAction
        self.insertAction = insertAction
    }
    
    public func canEditForItem(item: Item, inTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) -> Bool {
        
        return cellEditor(item)
    }
    
    public func deleteItem(item: Item, inTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) {
        
        deleteAction?(item, indexPath)
    }
    
    public func insertItem(item: Item, inTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) {
        
        insertAction?(item)
    }
}

public class TableViewDataSourceBuilder<Cell: UITableViewCell, Item> {
    
    var factory: RegisteredTableViewCellFactory<Cell, Item>?
    var editor: RegisteredTableViewCellEditor<Cell, Item>?

    typealias BuilderClosure = (TableViewDataSourceBuilder) -> ()
    
    init(buildClosure: BuilderClosure) {
        
        buildClosure(self)
    }
}

public class TableViewDataSource<Cell: UITableViewCell, Item> {
    
    public var sections: [[Item]] = [[Item]]()
    
    public var bridgedDataSource: UITableViewDataSource { return bridgedTableViewDataSource }
    
    private let cellFactory: RegisteredTableViewCellFactory<Cell, Item>
    private let cellEditor: RegisteredTableViewCellEditor<Cell, Item>
    
    private var bridgedTableViewDataSource: BridgeableTableViewDataSource!
    
    public init(builderClosure: TableViewDataSourceBuilder<Cell, Item>.BuilderClosure) {
        
        let builder = TableViewDataSourceBuilder(buildClosure: builderClosure)
        if let factory = builder.factory {
            self.cellFactory = factory
        } else {
            self.cellFactory = RegisteredTableViewCellFactory(reuseIdentifier: "", cellConfigurator: nil)
        }
        if let editor = builder.editor {
            self.cellEditor = editor
        } else {
            self.cellEditor = RegisteredTableViewCellEditor(cellEditor: {_ in return false}, deleteAction: nil, insertAction: nil)
        }
        
        bridgedTableViewDataSource = BridgeableTableViewDataSource(
            numberOfItemsInSectionHandler: { [weak self] in
                self?.numberOfItemsInSection($0) ?? 0
            },
            cellForItemAtIndexPathHandler: { [weak self] in
                self?.tableView($0, cellForRowAtIndexPath: $1)
            },
            numberOfSectionsHandler: { [weak self] in
                self?.numberOfSections() ?? 0
            },
            canEditRowAtIndexPathHandler: { [weak self] in
                self?.tableView($0, canEditRowAtIndexPath: $1) ?? false
            },
            commitEditingStyleHandler: { [weak self] in
                self?.tableView($0, commitEditingStyle: $1, forRowAtIndexPath: $2)
            }
        )
    }
    
    private func numberOfItemsInSection(section: Int) -> Int {

        return count(sections[section])
    }
    
    private func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return cellFactory.cellForItem(sections[indexPath.section][indexPath.row], inTableView: tableView, atIndexPath: indexPath)
    }
    
    private func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return cellEditor.canEditForItem(sections[indexPath.section][indexPath.row], inTableView: tableView, atIndexPath: indexPath)
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
            
        case .None:
            return
        case .Delete:
            cellEditor.deleteItem(sections[indexPath.section][indexPath.row], inTableView: tableView, atIndexPath: indexPath)
        case .Insert:
            cellEditor.insertItem(sections[indexPath.section][indexPath.row], inTableView: tableView, atIndexPath: indexPath)
        }
    }
    
    private func numberOfSections() -> Int {

        return count(sections)
    }
}

@objc private class BridgeableTableViewDataSource: NSObject, UITableViewDataSource {
    
    private let numberOfItemsInSectionHandler: Int -> Int
    private let cellForItemAtIndexPathHandler: (UITableView, NSIndexPath) -> UITableViewCell?
    private let numberOfSectionsHandler: () -> Int

    private let canEditRowAtIndexPathHandler: (UITableView, NSIndexPath) -> Bool
    private let commitEditingStyleHandler: (UITableView, UITableViewCellEditingStyle, NSIndexPath) -> ()


    init(numberOfItemsInSectionHandler: Int -> Int,
        cellForItemAtIndexPathHandler: (UITableView, NSIndexPath) -> UITableViewCell?,
        numberOfSectionsHandler: () -> Int, canEditRowAtIndexPathHandler: (UITableView, NSIndexPath) -> Bool,
        commitEditingStyleHandler: (UITableView, UITableViewCellEditingStyle, NSIndexPath) -> ()) {
            
            self.numberOfItemsInSectionHandler = numberOfItemsInSectionHandler
            self.cellForItemAtIndexPathHandler = cellForItemAtIndexPathHandler
            self.numberOfSectionsHandler = numberOfSectionsHandler
            self.canEditRowAtIndexPathHandler = canEditRowAtIndexPathHandler
            self.commitEditingStyleHandler = commitEditingStyleHandler
    }
    
    
    // MARK: UITableViewDataSource methods
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return numberOfSectionsHandler()
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return numberOfItemsInSectionHandler(section)
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return cellForItemAtIndexPathHandler(tableView, indexPath)!
    }
    
    @objc func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return canEditRowAtIndexPathHandler(tableView, indexPath)
    }
    
    
    @objc func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        commitEditingStyleHandler(tableView, editingStyle, indexPath)
    }

}