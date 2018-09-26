//
//  ExpensesDelegate.swift
//  Expenses
//
//  Created by Kelly Galakatos on 9/26/18.
//  Copyright © 2018 Tech Innovator. All rights reserved.
// 

import Foundation
import CloudKit

protocol ExpensesDelegate: class {
    func add(records: [CKRecord])
    func editedRecord()
}
