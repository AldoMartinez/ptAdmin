//
//  agregarVentaController.swift
//  ptAdmin
//
//  Created by Aldo Aram Martinez Mireles on 1/20/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FacebookCore
import FacebookLogin

class agregarVentaController: UITableViewController {
    
    var ref: DatabaseReference?
    let formatter = DateFormatter()
    var fecha:String = ""
    
    @IBOutlet weak var descripcion: UITextField!
    @IBOutlet weak var precio: UITextField!
    @IBAction func prestamo(_ sender: UISwitch) {
        if sender.isOn {
            self.localPrestadorCell.isHidden = false
            self.costoPrestamoCell.isHidden = false
        }else{
            self.localPrestadorCell.isHidden = true
            self.costoPrestamoCell.isHidden = true
        }
    }
    @IBOutlet weak var localPrestadorCell: UITableViewCell!
    @IBOutlet weak var costoPrestamoCell: UITableViewCell!
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        if self.descripcion.text != "" && self.precio.text != "" {
            // Pendiente guardar los datos en firebase
            
//            self.ref?.child(self.fecha).childByAutoId().setValue(["producto": self.descripcion.text ?? "Producto sin descripcion","precio": Int((self.precio.text!)!) ?? 0,"creado_por": "Aldo Mtz" ?? "Desconocido" ])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.localPrestadorCell.isHidden = true
        self.costoPrestamoCell.isHidden = true
        
        formatter.dateStyle = .medium
        self.fecha = formatter.string(from: Date())
        
        ref = Database.database().reference()

    }
    
    // Oculta el teclado al darle clic a return
    func hideKeyboard(textfield:UITextField){
        textfield.resignFirstResponder()
    }
}
