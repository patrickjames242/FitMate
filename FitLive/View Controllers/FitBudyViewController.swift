//
//  FitBudyViewController.swift
//  FitLive
//
//  Created by Akeil S on 5/30/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit

class FitBudyViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "BuddyCell", bundle: nil), forCellReuseIdentifier: "FitBuddyCell")
    }
    
	
    var buddies: [UserInfo] = [
        UserInfo(name: "Ina Obrien", username: "@inaobrien", points: 40),
        UserInfo(name: "Ina Obrien", username: "@inaobrien", points: 40)
    ]
	
}


extension FitBudyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FitBuddyCell", for: indexPath)
        as! BuddyCell
        cell.name.text = buddies[indexPath.row].name
        return cell
    }
    
    
}
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
        return UITableView.automaticDimension
    } else {
        return 40
    }
}

func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
        return UITableView.automaticDimension
    } else {
        return 40
    }
}
extension FitBudyViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}
