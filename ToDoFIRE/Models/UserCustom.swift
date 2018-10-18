//
//  UserCustom.swift
//  ToDoFIRE
//
//  Created by Zinko Vyacheslav on 18.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import Foundation
import Firebase


struct UserCustom {
	
	public let uid:String
	public let email:String
	
	
	init(user: User) {
		self.uid = user.uid
		self.email = user.email!
	}
	
	
	
}

