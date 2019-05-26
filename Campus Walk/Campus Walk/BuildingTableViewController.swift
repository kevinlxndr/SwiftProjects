//
//  BuildingTableViewController.swift
//  Campus Walk
//
//  Created by Kevin Ramsussen on 10/14/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class BuildingTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    let model = Model.sharedInstance
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    let searchController =  UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sectionIndexBackgroundColor = UIColor.white
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["Name", "Year Constructed"]
        searchController.searchBar.selectedScopeButtonIndex = 0
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text!
            model.updateFilter(filter: text)
            tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        if selectedScope == 0{
            searchBar.keyboardType = .default
        }
        else{
            searchBar.keyboardType = .numberPad
        }
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return model.numberOfInitials
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model.numberOfBuildings(at: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.initials[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return model.initials
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuildingCell", for: indexPath) as! BuildingTableViewCell
        let name = model.buildingName(at: indexPath)
        cell.buildingName.text = name
        let date = model.building(named: name).year_constructed
        if  date != 0{
            cell.builtLabel.text = "Year Constructed: " + date.description
        }
        else{
            cell.builtLabel.text = "Year Constructed: Unknown"
        }
        cell.favoriteButton.setImage(UIImage(named: "Unfavorite Star"), for: .normal)
        if model.isBuildingFavorited(indexPath: indexPath){
            cell.favoriteButton.setImage(UIImage(named:"Favorite Star"), for: .normal)
        }
        return cell
    }

    @IBAction func AddRemoveFavorite(_ sender: UIButton) {
        let currentCell = sender.superview?.superview as! BuildingTableViewCell
        let currentIndexPath = tableView.indexPath(for: currentCell)!
        model.invertFavorite(indexPath:currentIndexPath)
        let isFavorite = model.isBuildingFavorited(indexPath: currentIndexPath)
        if isFavorite{
            sender.setImage(UIImage(named: "Favorite Star"), for: .normal)
        }
        else{
            sender.setImage(UIImage(named: "Unfavorite Star"), for: .normal)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if model.currentTablePurpose == "Map"{
        model.selectedBuildingIndexPath = indexPath
        model.changePin = true
        dismiss(animated: true, completion: nil)
        }
        else{
            if model.currentDirectionChange == 1{
                model.Direction1 = model.buildingName(at: indexPath)
            }
            else{
                model.Direction2 = model.buildingName(at: indexPath)
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = UIColor.lightGray
            headerView.textLabel?.textColor = UIColor.black
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
