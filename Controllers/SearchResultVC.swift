//
//  SearchResultVC.swift
//  VrCloudinary
//
//  Created by Vrajan 001 on 23/05/19.
//  Copyright © 2019 VR. All rights reserved.
//

import UIKit
import Mapbox
import MapboxGeocoder


class PlacemarkCell: UITableViewCell {
    
    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var lblPlaceAddress: UILabel!
}

protocol SearchResultVCDelegate {
    func placeMarkSelected(placeMark:GeocodedPlacemark)
}

class SearchResultVC: UITableViewController {

    var delegate:SearchResultVCDelegate?
    
    var searchText = ""
    var arrResults = Array<GeocodedPlacemark>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.backgroundColor = .clear
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.arrResults.isEmpty {
            self.tableView.isHidden = true
        } else {
            self.tableView.isHidden = false
        }
        return self.arrResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlacemarkCell", for: indexPath) as! PlacemarkCell
        
        let placeMark = self.arrResults[indexPath.row]
        print(placeMark)
        cell.lblPlaceName.text = placeMark.name
        cell.lblPlaceAddress.text = placeMark.qualifiedName

        return cell
    }
    
     override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath){
        let placeMark = self.arrResults[indexPath.row]
        self.delegate?.placeMarkSelected(placeMark: placeMark)
        self.dismiss(animated: true, completion: nil)
//        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
//            self.tableView.isHidden = true
//        })

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
        
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
