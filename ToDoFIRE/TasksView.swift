//
//  TasksView.swift
//  ToDoFIRE
//
//  Created by Zinko Vyacheslav on 17.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit

class TasksView: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	
	@IBOutlet weak var tableView_user: UITableView!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		
    }

	

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "my_cell", for: indexPath)
		
		cell.backgroundColor = .clear
		cell.textLabel?.text = "This is cell No \(indexPath.row)"
		cell.textLabel?.textColor = .white
		
		return cell
	}
    

	@IBAction func onPlusClick(_ sender: UIBarButtonItem) {
		
	}
	
}
