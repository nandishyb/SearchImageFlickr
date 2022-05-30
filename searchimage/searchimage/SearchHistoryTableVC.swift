//
//  SearchHistoryTableVC.swift
//  searchimage
//
//  Created by Nandish Bellad on 30/05/2022.
//

import UIKit

class SearchHistoryTableVC: UITableViewController {
    
    var searchHistoryArray:[String]?
    static var selectedSearchTerm:String?
    var onDoneBlock : (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchHistoryArray = UserDefaults.standard.array(forKey: "SearchHistory") as? [String]
        if let searchHistoryArray = self.searchHistoryArray {
            print("Count : \(searchHistoryArray.count)")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let searchHistoryArray = self.searchHistoryArray {
            return searchHistoryArray.count
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        if let searchHistoryArray = self.searchHistoryArray {
            print("\(searchHistoryArray[indexPath.row])")
            cell.textLabel?.text = searchHistoryArray[indexPath.row]
            cell.textLabel?.textAlignment = .center
        } else {
            cell.textLabel?.text = "No search history yet!!"
            cell.isUserInteractionEnabled = false
        }
        
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchHistoryArray = self.searchHistoryArray {
            SearchHistoryTableVC.selectedSearchTerm = searchHistoryArray[indexPath.row]
            NotificationCenter.default.post(name: NSNotification.Name("searchTermSelectedFromTable"), object: nil)
            self.dismiss(animated: true)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
