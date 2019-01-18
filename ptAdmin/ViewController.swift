//
//  ViewController.swift
//  ptAdmin
//
//  Created by Aldo Aram Martinez Mireles on 6/12/18.
//  Copyright © 2018 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var nombreProducto: UITextField!
    @IBOutlet var precioProducto: UITextField!
    
    var ref:DatabaseReference?
    var handle: DatabaseHandle?
    var fechaActual:String = ""
    var producto: [String] = []
    var precio: [Int] = []
    var contador = 0
    
    @IBAction func agregarVenta(_ sender: Any) {
        _ = Date();
        
        //ref?.child("ventas").childByAutoId().setName(nombreProducto)
        if precioProducto.text != "" && nombreProducto.text != ""{
//            ref?.child("fecha").childByAutoId().child((nombreProducto.text)!).setValue(Int(precioProducto.text!))
            ref?.child("fecha").childByAutoId().setValue(["Producto": nombreProducto.text ?? "Producto sin descripcion","Precio": Int(precioProducto.text!) ?? 0])
            precioProducto.text = ""
            nombreProducto.text = ""
        }
        performSegue(withIdentifier: "unwindVentaActual", sender: sender)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        UIApplication.shared.statusBarStyle = .lightContent
//        nombreProducto.delegate = self
//        precioProducto.delegate = self
//        // Se crea el boton Done para cerra number Pad
//        //init toolbar
//        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
//        //create left side empty space so that done button set on right side
//        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
//        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
//        toolbar.setItems([flexSpace, doneBtn], animated: false)
//        toolbar.sizeToFit()
//        //setting toolbar as inputAccessoryView
//        self.precioProducto.inputAccessoryView = toolbar
//        
//        ref = Database.database().reference()
    }
    

    func hideKeyboard(textfield:UITextField){
        textfield.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard(textfield: nombreProducto)
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

