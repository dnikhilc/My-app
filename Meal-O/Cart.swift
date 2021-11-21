//
//  Cart.swift
//  Meal-O
//
//  Created by MehulS on 08/11/21.
//

import UIKit



class Cart: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableViewCart: UITableView!
    
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Navigation Bar Title
        self.title = "Cart"
        
        // Reload Table View
        self.tableViewCart.reloadData()
    }
    
    
    // MARK: - Mix & Match Button
    @IBAction func btnMixMatchClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Mix & Match", message: "Do you want to order from another restaurant too?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            // Navigate to Payment
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            // Navigate to Dashboard
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}


// MARK: - UITableView Methods
extension Cart: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.arrayCart.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellFooter") as! CellMenu
        cell.backgroundColor = UIColor.white
        
        // Total Price
        var total = 0.0
        for item in appDelegate.arrayCart {
            let price = item.menuItemPrice ?? 0.0
            let qty = Double(item.quantity ?? 0)
            let totalPrice = price * qty
            total = total + totalPrice
        }
        cell.lblTotalPrice.text = String(format: "$%.2f", total)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellMenu") as! CellMenu
        
        // Get Model
        let model = appDelegate.arrayCart[indexPath.row]
        
        // Set Data
        cell.lblMenuItemName.text = model.menuItemName
        
        let price = model.menuItemPrice ?? 0.0
        let qty = Double(model.quantity ?? 0)
        let totalPrice = price * qty
        cell.lblProce.text = String(format: "$%.2f", totalPrice)
        
        // Show Quantity
        cell.lblQuantity.text = "\(model.quantity ?? 0)"
        
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
        let buttonPostion = sender.convert(sender.bounds.origin, to: self.tableViewCart)
        
        if let indexPath = self.tableViewCart.indexPathForRow(at: buttonPostion) {
            // Increase Quantity
            // Get Model first
            var model = appDelegate.arrayCart[indexPath.row]
            
            let menuQty = model.quantity ?? 0
            let qty = menuQty + 1
            model.quantity = qty
                        
            // This way, it works, above code is not working
            appDelegate.arrayCart[indexPath.row].quantity = qty
            
            // Reload TableView
            self.tableViewCart.reloadData()
        }
    }
    
    // MARK: - Increase Quantity
    @objc func btnDecreaseQuantityClicked(sender: UIButton) -> Void {
        let buttonPostion = sender.convert(sender.bounds.origin, to: self.tableViewCart)
        
        if let indexPath = self.tableViewCart.indexPathForRow(at: buttonPostion) {
            // Decrease Quantity
            // Get Model first
            var model = appDelegate.arrayCart[indexPath.row]
            
            if model.quantity ?? 0 <= 0 {
                // Do Nothing
            } else {
                let menuQty = model.quantity ?? 0
                let qty = menuQty - 1
                model.quantity = qty
                
                appDelegate.arrayCart[indexPath.row].quantity = qty
                
                // Reload TableView
                self.tableViewCart.reloadData()
            }
        }
    }
    
    
}
