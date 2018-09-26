//
//  SingleExpenseViewController.swift
//  Expenses
//
//  Created by Tech Innovator on 11/30/17.
//  Copyright © 2017 Tech Innovator. All rights reserved.
//

import UIKit
import CloudKit

class SingleExpenseViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let privateDatabase = CKContainer.default().privateCloudDatabase
    let zone = CKRecordZone(zoneName: "ExpenseZone")
    
    var record: CKRecord?
    
    weak var expensesDelegate: ExpensesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        amountTextField.delegate = self
        
        nameTextField.text = record?.object(forKey: "name") as? String
        amountTextField.text = record?.object(forKey: "amount") as? String
        
        if let date = record?.object(forKey: "date") as? Date {
            datePicker.date = date
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveExpense(_ sender: Any) {
        let name = nameTextField.text as CKRecordValue?
        let amount = amountTextField.text as CKRecordValue?
        let date = datePicker.date as CKRecordValue
        
        let record = self.record ?? CKRecord(recordType: "Expense", zoneID: zone.zoneID)
        
        record.setObject(name, forKey: "name")
        record.setObject(amount, forKey: "amount")
        record.setObject(date, forKey: "date")
        
        self.navigationItem.backBarButtonItem?.isEnabled = false
        
//        privateDatabase.save(record) { (record, error) in
//            DispatchQueue.main.async {
//                self.navigationItem.backBarButtonItem?.isEnabled = true
//
//                if let error = error {
//                    print(error)
//                } else {
//                    print("Record was saved")
//
//                    self.navigationController?.popViewController(animated: true)
//                }
//            }
//        }
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        let configuration = CKOperationConfiguration()
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        
        operation.configuration = configuration
        
        operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
            DispatchQueue.main.async {
                self.navigationItem.backBarButtonItem?.isEnabled = true

                if let error = error {
                    print(error)
                } else {
                    print("Record was saved")
                    
                    if self.record != nil {
                        self.expensesDelegate?.editedRecord()
                    } else if let savedRecords = savedRecords {
                        self.expensesDelegate?.add(records: savedRecords)
                    }

                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        privateDatabase.add(operation)
        
    }
}

extension SingleExpenseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
