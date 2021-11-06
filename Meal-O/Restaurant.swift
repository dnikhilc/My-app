//
//  Restaurant.swift
//  Meal-O
//
//  Created by MehulS on 03/11/21.
//

import UIKit


// Custom Cell
class CellMenu: UITableViewCell {
    // CellHeader
    @IBOutlet weak var lblSection: UILabel!
    
    // CellMenu
    @IBOutlet weak var lblMenuItemName: UILabel!
    @IBOutlet weak var lblProce: UILabel!
    @IBOutlet weak var btnDecreaseQuantity: UIButton!
    @IBOutlet weak var btnIncreaseQuantity: UIButton!
    @IBOutlet weak var lblQuantity: UILabel!
    
}


class Restaurant: UIViewController {
    
    var restaurantObj: Restaurants!

    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Navigation Bar Title
        self.title = self.restaurantObj.restaurantName
    }

}


// MARK: - UITableView Methods
extension Restaurant: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("Menu Section Count: \(self.restaurantObj.menus?.first?.menuSections?.count ?? 0)")
        return self.restaurantObj.menus?.first?.menuSections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Section's Menu Item Count: \(self.restaurantObj.menus?.first?.menuSections?[section].menuItems?.count ?? 0)")
        return self.restaurantObj.menus?.first?.menuSections?[section].menuItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cellHeader = tableView.dequeueReusableCell(withIdentifier: "CellHeader") as! CellMenu
        
        // Set Header Name
        cellHeader.lblSection.text = self.restaurantObj.menus?.first?.menuSections?[section].sectionName ?? "No Name"
        
        return cellHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellMenu") as! CellMenu
        
        // Get Model
        let model = self.restaurantObj.menus?.first?.menuSections?[indexPath.section].menuItems?[indexPath.row]
        
        // Set Data
        cell.lblMenuItemName.text = model?.name
        cell.lblProce.text = "$\(model?.price ?? 0.0)"
        
        cell.selectionStyle = .none
        return cell
    }
    
    
}
