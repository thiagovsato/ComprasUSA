//
//  UIViewController+CoreData.swift
//  ThiagoRaphael
//
//  Created by Usuario on 10/9/17.
//  Copyright © 2017 ThiagoRaphael. All rights reserved.
//

import CoreData
import UIKit

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
}
