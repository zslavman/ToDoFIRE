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
	
	public let title:String				// сам таск
	public var completed:Bool = false	// выполнен ли таск
	public let userID:String			// ID-шник юзера (присваивает БД)
	public var order:Int				// порядок заданий относительно друг друга
	
	
	public let ref:DatabaseReference? //ссылка в базу данных, чтоб добраться до пользователя. Появляется только после того как объект помещен в БД

	
	
	// при создании запроса
	init(title:String, userID:String, order:Int) {
		self.title = title
		self.userID = userID
		self.order = order
		self.ref = nil
	}
	
	// при получении данных
	init(snapshot:DataSnapshot) { // snapshot - "снимок" данных БД на момент запроса
		let snapshotValue = snapshot.value as! [String:AnyObject]
		
		title 		= snapshotValue["title"] as! String
		userID 		= snapshotValue["userID"] as! String
		completed 	= snapshotValue["completed"] as! Bool
		order 		= snapshotValue["order"] as! Int
		ref 		= snapshot.ref
	}
	
	

	
	
	
	
	
	
}
