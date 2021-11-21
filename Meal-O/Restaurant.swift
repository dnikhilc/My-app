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
    
    // CellFooter
    @IBOutlet weak var lblTotalPrice: UILabel!
    
}


class Restaurant: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableViewMenus: UITableView!
    
    
    var restaurantObj: Restaurants!
    var arrayNearbyRestaurant: [Restaurants]!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Navigation Bar Title
        self.title = self.restaurantObj.restaurantName
        
        // Navigation Bar Right Button
        let rightBarButton = UIBarButtonItem(image: UIImage(named: "Cart")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(btnCartClicked))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    
    // MARK: - Cart Button
    @objc func btnCartClicked() -> Void {
        // Navigate to Restaurant Screen
        let viewCTR = self.storyboard?.instantiateViewController(identifier: "Cart") as! Cart
        self.navigationController?.pushViewController(viewCTR, animated: true)
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
        
        // Show Quantity
        cell.lblQuantity.text = "\(model?.quantity ?? 0)"
        
        // Increase Cart Button
        cell.btnIncreaseQuantity.tag = indexPath.row
        cell.btnIncreaseQuantity.addTarget(self, action: #selector(btnIncreaseQuantityClicked), for: .touchUpInside)
        
        // Decrease Cart Button
        cell.btnDecreaseQuantity.tag = indexPath.row
        cell.btnDecreaseQuantity.addTarget(self, action: #selector(btnDecreaseQuantityClicked), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
    
    // MARK: - Increase Quantity
    @objc func btnIncreaseQuantityClicked(sender: UIButton) -> Void {
        let buttonPostion = sender.convert(sender.bounds.origin, to: self.tableViewMenus)
        
        if let indexPath = self.tableViewMenus.indexPathForRow(at: buttonPostion) {
            // Update Flag
            self.restaurantObj.isAddedInCart = true
            
            // Increase Quantity
            // Get Model first
            var model = self.restaurantObj.menus?[0].menuSections?[indexPath.section].menuItems?[indexPath.row]
            
            let menuQty = model?.quantity ?? 0
            let qty = menuQty + 1
            model?.quantity = qty
                        
            // This way, it works, above code is not working
            self.restaurantObj.menus?[0].menuSections?[indexPath.section].menuItems?[indexPath.row].quantity = qty
            
            // Reload TableView
            self.tableViewMenus.reloadData()
            
            
            // Check item is already there in the CART
            if let index = appDelegate.arrayCart.firstIndex(where: { $0.menuItemName?.lowercased() == model?.name?.lowercased() }) {
                // Just Increase Quantity
                let qty = appDelegate.arrayCart[index].quantity ?? 0
                let increasedQty = qty + 1
                appDelegate.arrayCart[index].quantity = increasedQty
                
            } else {
                
                // Add Object in Global Array of Cart
                let sectionName = self.restaurantObj.menus?[0].menuSections?[indexPath.section].sectionName ?? ""
                var cartItem = CartModel()
                cartItem.restaurantID = self.restaurantObj.restaurantID ?? 0.0
                cartItem.restaurantName = self.restaurantObj.restaurantName ?? ""
                cartItem.menuSectionName = sectionName
                cartItem.menuItemName = model?.name ?? ""
                cartItem.menuItemPrice = model?.price ?? 0.0
                cartItem.quantity = 1
                
                appDelegate.arrayCart.append(cartItem)
            }
        }
    }
    
    // MARK: - Increase Quantity
    @objc func btnDecreaseQuantityClicked(sender: UIButton) -> Void {
        let buttonPostion = sender.convert(sender.bounds.origin, to: self.tableViewMenus)
        
        if let indexPath = self.tableViewMenus.indexPathForRow(at: buttonPostion) {
            // Update Flag
            self.restaurantObj.isAddedInCart = true
            
            // Decrease Quantity
            // Get Model first
            var model = self.restaurantObj.menus?.first?.menuSections?[indexPath.section].menuItems?[indexPath.row]
            
            if model?.quantity ?? 0 <= 0 {
                // Do Nothing
            } else {
                let menuQty = model?.quantity ?? 0
                let qty = menuQty - 1
                model?.quantity = qty
                
                self.restaurantObj.menus?[0].menuSections?[indexPath.section].menuItems?[indexPath.row].quantity = qty
                
                // Reload TableView
                self.tableViewMenus.reloadData()
                
                // Decrease Quantity
                if let index = appDelegate.arrayCart.firstIndex(where: { $0.menuItemName?.lowercased() == model?.name?.lowercased() }) {
                    // Just Decraese Quantity
                    let qty = appDelegate.arrayCart[index].quantity ?? 1
                    let increasedQty = qty - 1
                    appDelegate.arrayCart[index].quantity = increasedQty
                    
                }
                
            }
        }
    }
    
    
}
