//
//  ExpensesViewController.swift
//  Expenses
//
//  Created by Tech Innovator on 11/30/17.
//  Copyright © 2017 Tech Innovator. All rights reserved.
//
//
// https://www.youtube.com/playlist?list=PLTQyl3JwSx0Lmg95dxDWxi3ffGJSJMLPf
//

import UIKit
import CloudKit

class ExpensesViewController: UIViewController {
    
    @IBOutlet weak var expensesTableView: UITableView!
    
    let privateDatabase = CKContainer.default().privateCloudDatabase
    let zone = CKRecordZone(zoneName: "ExpenseZone")
    
    let dateFormatter = DateFormatter()
    let refreshControl = UIRefreshControl()
    
    var records = [CKRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.timeStyle = .long
        dateFormatter.dateStyle = .long
        
        expensesTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshExpenses), for: .valueChanged)
        
        privateDatabase.save(zone) { (zone, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                } else {
                    print("Zone was saved")
                }
            }
        }
        
        queryExpenses(completionHandler: nil)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        queryExpenses()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNewExpense(_ sender: Any) {
        performSegue(withIdentifier: "showExpense", sender: self)
    }
    
    func queryExpenses(completionHandler: (() -> Void)?) {
        let query = CKQuery(recordType: "Expense", predicate: NSPredicate(value: true))
        
        privateDatabase.perform(query, inZoneWith: zone.zoneID) { (records, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                } else {
                    self.records = records ?? []
                    
                    self.expensesTableView.reloadData()
                }
                
                completionHandler?()
            }
        }
    }
    
    @objc func refreshExpenses() {
        queryExpenses {
            self.refreshControl.endRefreshing()
        }
    }
    
    func deleteRecord(at indexPath: IndexPath) {
        let record = records[indexPath.row]
        
        privateDatabase.delete(withRecordID: record.recordID) { (recordID, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                } else {
                    print("Record was deleted")
                    
                    self.records.remove(at: indexPath.row)
                    
                    self.expensesTableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? SingleExpenseViewController else {
            return
        }
        
        destination.expensesDelegate = self
        
        if let selectedRow = expensesTableView.indexPathForSelectedRow?.row {
        
            destination.record = records[selectedRow]
        }
    }

}

extension ExpensesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.records.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteRecord(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expensesTableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath)
        let record = records[indexPath.row]
        
        cell.textLabel?.text = record.object(forKey: "name") as? String
        
        if let date = record.object(forKey: "date") as? Date {
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
        }
        
        return cell
    }
}

extension ExpensesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showExpense", sender: self)
    }
}

extension ExpensesViewController: ExpensesDelegate {
    func add(records: [CKRecord]) {
        self.records.append(contentsOf: records)
        
//        if let tableView = self.expensesTableView {
//            tableView.reloadData()
//        }
        
        self.expensesTableView?.reloadData()
    }
    
    func editedRecord() {
        self.expensesTableView?.reloadData()
    }
}
