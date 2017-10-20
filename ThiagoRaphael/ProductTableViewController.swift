//
//  ProductTableViewController.swift
//  ThiagoRaphael
//
//  Created by Usuário Convidado on 06/10/17.
//  Copyright © 2017 ThiagoRaphael. All rights reserved.
//

import UIKit
import CoreData

class ProductTableViewController: UITableViewController {

    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = "Sua lista está vazia!"
        label.textAlignment = .center
        label.textColor = .black
        
        loadProducts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            let vc = segue.destination as! ProductRegisterViewController
            
            var object = sender as? Product
            if object == nil {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    object = self.fetchedResultController.object(at: indexPath)
                }
            }
            vc.product = object
        }
    }
    
    
    func loadProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            print (error.localizedDescription)
        }
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.fetchedObjects?.count {
            tableView.backgroundView = (count == 0) ? label : nil
            return count
        } else {
            tableView.backgroundView = label
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        let product = fetchedResultController.object(at: indexPath)
        
        cell.lbProductName.text = product.name
        let price = String(format: "%.2f", product.price)
        cell.lbPrice.text = "U$"+price
        if let image = product.photo as? UIImage {
            cell.ivPhoto.image = image
        } else {
            cell.ivPhoto.image = nil
        }
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let product = self.fetchedResultController.object(at: indexPath)
            self.context.delete(product)
            do {
                try self.context.save()
            } catch {
                print (error.localizedDescription)
            }
            
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action: UITableViewRowAction, indexPath: IndexPath) in
            tableView.setEditing(false, animated: true)
            let object = self.fetchedResultController.object(at: indexPath)
            self.performSegue(withIdentifier: "edit", sender: object)
        }
        editAction.backgroundColor = .blue
        return [editAction, deleteAction]
    }

}

extension ProductTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
