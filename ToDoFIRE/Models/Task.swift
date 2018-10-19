//
//  TaskCustom.swift
//  ToDoFIRE
//
//  Created by Zinko Vyacheslav on 18.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import Foundation
import Firebase


struct Task {
	
	public let title:String
	public let userID:String
	public let ref:DatabaseReference? //ссылка в базу данных, чтоб добраться до пользователя. Появляется только после того как объект помещен в БД
	public var completed:Bool = false

	
	
	// при создании запроса
	init(title:String, userID:String) {
		self.title = title
		self.userID = userID
		self.ref = nil
	}
	
	// при получении данных
	init(snapshot:DataSnapshot) { // snapshot - "снимок" данных БД на момент запроса
		let snapshotValue = snapshot.value as! [String:AnyObject]
		title = snapshotValue["title"] as! String
		userID = snapshotValue["userID"] as! String
		completed = snapshotValue["completed"] as! Bool
		ref = snapshot.ref
	}
	
	
	
	public func convertToDict() -> Any {
		return [
			"title"		: title,
			"userID"	: userID,
			"completed"	: completed
		]
	}
	
	
	
	
	
	
}
