//
//  ViewController.swift
//  GenericTableView
//
//  Created by Josip Cavar on 18/04/15.
//  Copyright (c) 2015 Josip Cavar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: TableViewDataSource<CustomTableViewCell, String>?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.registerNib(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        dataSource = TableViewDataSource { builder in
            builder.factory = RegisteredTableViewCellFactory(reuseIdentifier: "CustomTableViewCell", cellConfigurator: { (cell, item, indexPath) -> () in
                cell.labelTitle.text = item
            })
            builder.editor = RegisteredTableViewCellEditor(cellEditor: {_ in return true}, deleteAction: {
                (item, indexPath) in
                self.dataSource?.sections[indexPath.section].removeAtIndex(indexPath.row)
                self.tableView.reloadData()
                return
            }, insertAction: {
                item in
            })
        }
        
        
        dataSource?.sections = [Array(count: 10, repeatedValue: "test")]
        tableView.dataSource = dataSource?.bridgedDataSource
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

