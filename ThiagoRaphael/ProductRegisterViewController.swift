//
//  ProductRegisterViewController.swift
//  ThiagoRaphael
//
//  Created by Usuário Convidado on 06/10/17.
//  Copyright © 2017 ThiagoRaphael. All rights reserved.
//

import UIKit
import CoreData

class ProductRegisterViewController: UIViewController {

    @IBOutlet weak var tfProductName: UITextField!
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var tfState: UITextField!
    @IBOutlet weak var btAddState: UIButton!
    @IBOutlet weak var tfValue: UITextField!
    @IBOutlet weak var swCard: UISwitch!
    @IBOutlet weak var btRegister: UIButton!
    
    var product: Product!
    var state: State!
    var smallImage: UIImage!
    var pickerView: UIPickerView!
    var statePickerSource: [State] = [State]()
    var selectedState: State!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if product != nil {
            tfProductName.text = product.name
            tfValue.text = "\(product.price)"
            swCard.isOn = product.card
            tfState.text = product.state?.name
            selectedState = product.state
            
            if let image = product.photo as? UIImage {
                ivPhoto.image = image
                smallImage = image
            }
            btRegister.setTitle("ATUALIZAR", for: .normal)
        }
        
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.dataSource = self
        pickerView.delegate = self
        
        tfState.inputView = pickerView
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        let okButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [cancelButton, spaceButton, okButton]
        
        tfState.inputAccessoryView = toolbar
        tfState.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let stateRequest:NSFetchRequest<State> = State.fetchRequest()
        stateRequest.returnsObjectsAsFaults = false
        
        statePickerSource.removeAll()
        
        var states = [State]()
        
        do {
            states = try context.fetch(stateRequest)
        } catch {
            print(error.localizedDescription)
        }
        
        var doesStateStillExist = false
        
        for state in states {
            if tfState.text! == state.name! {
                doesStateStillExist = true
            }
            statePickerSource.append(state)
        }
        
        if !doesStateStillExist {
            tfState.text = nil
        }
        
        statePickerSource.sort { $0.name! < $1.name! }
    }
    

    func cancel() {
        tfState.resignFirstResponder()
    }
    
    func done() {
        if statePickerSource.count != 0 {
            selectedState = statePickerSource[pickerView.selectedRow(inComponent: 0)]
            tfState.text = selectedState.name
        }
        cancel()
    }

    
    func close () {
        if product != nil && product.name == nil {
            context.delete(product)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addUpdateProduct(_ sender: UIButton) {
        
        let nameCheck = tfProductName.text
        let priceCheck = tfValue.text
        let stateCheck = tfState.text
        
        if !(nameCheck?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)!, !(priceCheck?.isEmpty)!, !(stateCheck?.isEmpty)!, smallImage != nil {
            
            let priceString = priceCheck?.replacingOccurrences(of: ",", with: ".")
            if let tmpPrice = Double(priceString!) {
                if product == nil {
                    product = Product(context: context)
                } else if (product.managedObjectContext == nil) {
                    product = Product(context: context)
                }
                product.price = tmpPrice
                product.name = nameCheck
                product.card = swCard.isOn
                product.state = selectedState
                product.photo = smallImage
                
            } else {
                print ("Número não é válido.")
                redBorder(textField: tfValue)
                
                tfProductName.layer.borderWidth = 0.0
                ivPhoto.layer.borderWidth = 0.0
                tfState.layer.borderWidth = 0.0
                
                return
            }
            
        } else {
            if (nameCheck?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty)! {
                redBorder(textField: tfProductName)
            } else {
                tfProductName.layer.borderWidth = 0.0
            }
            if (priceCheck?.isEmpty)! {
                redBorder(textField: tfValue)
            } else {
                tfValue.layer.borderWidth = 0.0
            }
            if (stateCheck?.isEmpty)! {
                redBorder(textField: tfState)
            } else {
                tfState.layer.borderWidth = 0.0
            }
            if smallImage == nil {
                ivPhoto.layer.cornerRadius = 8.0
                ivPhoto.layer.masksToBounds = true
                ivPhoto.layer.borderColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
                ivPhoto.layer.borderWidth = 2.0
            } else {
                ivPhoto.layer.borderWidth = 0.0
            }
            
            return
        }

        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        close()
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "Selecionar foto", message: "De onde você quer escolher a foto?", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func redBorder (textField: UITextField){
        textField.layer.cornerRadius = 8.0
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        textField.layer.borderWidth = 2.0
    }

}

extension ProductRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        
        let smallSize = CGSize(width: 300, height: 300)
        
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        ivPhoto.image = smallImage
        UIGraphicsEndImageContext()
        
        dismiss (animated: true, completion: nil)
    }
}


extension ProductRegisterViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

extension ProductRegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statePickerSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statePickerSource[row].name
    }
}


extension SettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
