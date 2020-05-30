//
//  FitBudyViewController.swift
//  FitLive
//
//  Created by Akeil S on 5/30/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit

class FitBudyViewController: UIViewController {
    
    @IBOutlet weak var fitBuddiesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fitBuddiesTable.dataSource = self
      
    }
    
    var buddies: [UserInfo] = [
        UserInfo(name: "Ina Obrien", username: "@inaobrien", points: 40)
    ]
  

}

extension FitBudyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = fitBuddiesTable.dequeueReusableCell(withIdentifier: "FitBuddyCell", for: indexPath)
        cell.textLabel?.text = buddies[indexPath.row].name
        return cell
    }
    
    
}
