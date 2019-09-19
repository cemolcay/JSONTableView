//
//  ViewController.swift
//  JSONTableView
//
//  Created by cem.olcay on 18/09/2019.
//  Copyright © 2019 cemolcay. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
  @IBOutlet weak var tableView: JSONTableView?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Load json
    guard let ditto = Bundle.main.url(forResource: "ditto", withExtension: "json"),
      let data = try? Data(contentsOf: ditto),
      let json = try? JSON(data: data)
      else { return }

    tableView?.data = json
    tableView?.reloadData()
  }

  @IBAction func collapseAll() {
    tableView?.collapseAll()
  }

  @IBAction func expandAll() {
    tableView?.expandAll()
  }
}
