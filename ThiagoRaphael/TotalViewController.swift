//
//  TotalViewController.swift
//  ThiagoRaphael
//
//  Created by Usuário Convidado on 06/10/17.
//  Copyright © 2017 ThiagoRaphael. All rights reserved.
//

import UIKit
import CoreData

class TotalViewController: UIViewController {

    @IBOutlet weak var lbTotalDollar: UILabel!
    @IBOutlet weak var lbTotalReal: UILabel!
    
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        
        let iofSettings = UserDefaults.standard.string(forKey: "iofDefaults")
        let dollarSettings = UserDefaults.standard.string(forKey: "dollarDefaults")
        
        var iof: Double = 1
        var dollarRate: Double = 1
        var sumReal: Double = 0
        var sumDollar: Double = 0
        var tax: Double = 1
        
        if iofSettings != nil, !(iofSettings?.isEmpty)!{
            if let tmpIOF = Double(iofSettings!){
                iof = 1 + (tmpIOF / 100)
            }
            
        }
        
        if dollarSettings != nil, !(dollarSettings?.isEmpty)! {
            if let tmpDollarRate = Double(dollarSettings!) {
                dollarRate = tmpDollarRate
            }
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            let data = results as! [Product]
            
            for product in data {
                if let taxState = product.state?.tax {
                    tax = 1 + (Double(taxState) / 100)
                }
                
                var tmpReal = product.price * tax * dollarRate
                
                if product.card {
                    tmpReal = tmpReal * iof
                }
                
                sumDollar = sumDollar + product.price
                sumReal = sumReal + tmpReal
            }
        } catch {
            print(error.localizedDescription)
        }
        
        let priceDollar = String(format: "%.2f", sumDollar)
        let priceReal = String(format: "%.2f", sumReal)
        lbTotalDollar.text = priceDollar
        lbTotalReal.text = priceReal
        
    }
    
}
