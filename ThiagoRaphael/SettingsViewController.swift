//
//  SettingsViewController.swift
//  ThiagoRaphael
//
//  Created by Usuário Convidado on 06/10/17.
//  Copyright © 2017 ThiagoRaphael. All rights reserved.
//

import UIKit
import CoreData

enum AlertType {
    case add
    case edit
}

class SettingsViewController: UIViewController{

    @IBOutlet weak var tfDollar: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    @IBOutlet weak var btAddState: UIButton!
    @IBOutlet weak var statesTableView: UITableView!
    
        // MARK: - Properties
    var state: State!
    
    var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
    var fetchedResultController: NSFetchedResultsController<State>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "Lista de estados vazia."
        label.textAlignment = .center
        label.textColor = .black
        
        statesTableView.delegate = self
        statesTableView.dataSource = self
        
        loadStates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var tmptfDollar: String = UserDefaults.standard.string(forKey: "dollarDefaults")!
        var tmptfIOF: String = UserDefaults.standard.string(forKey: "iofDefaults")!

        let decimalPad = "0123456789.,"
        
        tmptfDollar = String(tmptfDollar.characters.filter {
            decimalPad.contains(String($0))
        })
        
        tmptfIOF = String(tmptfIOF.characters.filter {
        decimalPad.contains(String($0))
        })
        
        tfDollar.text = tmptfDollar
        tfIOF.text = tmptfIOF
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let _ = Double(tfDollar.text!.replacingOccurrences(of: ",", with: ".")) {
            let tmptfDollar = tfDollar.text!.replacingOccurrences(of: ",", with: ".")
            UserDefaults.standard.set(tmptfDollar,forKey: "dollarDefaults")
        } else {
            print ("Número não é válido.")
        }
        if let _ = Double(tfIOF.text!.replacingOccurrences(of: ",", with: ".")) {
            let tmptfIOF = tfIOF.text!.replacingOccurrences(of: ",", with: ".")
            UserDefaults.standard.set(tmptfIOF, forKey: "iofDefaults")
        } else {
            print ("Número não é válido.")
        }
        
    }
    
    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
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
    
    func showAlert(type: AlertType, state: State?) {
        let title = (type == .add) ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (tfName: UITextField) in
            tfName.placeholder = "Nome do estado"
            if let name = state?.name {
                tfName.text = name
            }
            
            tfName.addTarget(alert, action: #selector(alert.textDidChangeInAlert), for: .editingChanged)
        }
        
        alert.addTextField { (tfTax: UITextField) in
            tfTax.placeholder = "Imposto"
            tfTax.keyboardType = UIKeyboardType.decimalPad
            if let tax = state?.tax {
                tfTax.text = "\(tax)"
            }
            
            tfTax.addTarget(alert, action: #selector(alert.textDidChangeInAlert), for: .editingChanged)
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        let saveAction = UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let taxString = alert.textFields?.last?.text?.replacingOccurrences(of: ",", with: ".")
            if let tmpTax = Double(taxString!) {
                let state = state ?? State(context: self.context)
                
                state.name = alert.textFields?.first?.text
                state.tax = tmpTax
                
                do {
                    try self.context.save()
                    self.loadStates()
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print ("Número não é válido.")
                return
            }
            
        })
        
        if (state == nil) {
            saveAction.isEnabled = false
        } else {
            saveAction.isEnabled = true
        }
        
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func addState(_ sender: UIButton) {
        showAlert(type: .add, state: nil)
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultController.fetchedObjects?.count {
            tableView.backgroundView = (count == 0) ? label : nil
            return count
        } else {
            tableView.backgroundView = label
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stateCell", for: indexPath) as! StateTableViewCell
        let state = fetchedResultController.object(at: indexPath)
        
        cell.lbStateName.text = state.name
        cell.lbStateTax.text = "\(state.tax)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = self.fetchedResultController.object(at: indexPath)
        self.showAlert(type: .edit, state: state)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.fetchedResultController.object(at: indexPath)
            self.context.delete(state)
            do {
                try self.context.save()
            } catch {
                print (error.localizedDescription)
            }
        }

        return [deleteAction]
    }
}

extension SettingsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        statesTableView.reloadData()
    }
}

extension UIAlertController {
    
    func isValidName(name: String) -> Bool {
        return !name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
    }
    
    func isValidTax(tax: String) -> Bool {
        if let _ = Double(tax.replacingOccurrences(of: ",", with: ".")) {
            return true
        } else {
            return false
        }
        
    }
    
    func textDidChangeInAlert() {
        if let name = textFields?[0].text,
            let tax = textFields?[1].text,
            let action = actions.last {
            action.isEnabled = isValidName(name: name) && isValidTax(tax: tax)
        }
    }
}
