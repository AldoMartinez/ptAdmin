//
//  ventaActualController.swift
//  ptAdmin
//
//  Created by Aldo Aram Martinez Mireles on 6/12/18.
//  Copyright © 2018 Aldo Aram Martinez Mireles. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FacebookCore
import FacebookLogin
import JGProgressHUD

class ventaActualController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet var myTableSale: UITableView!
    
    @IBOutlet var ventaTotal: UILabel!
    
    // MARK: Properties
    
    var sumaVenta:Int = 0
    var handle: DatabaseHandle?
    var handleUpdate: DatabaseHandle?
    var handleFecha: DatabaseHandle?
    var handleDelete:DatabaseHandle?
    var producto: [String] = []
    var precio: [Int] = []
    var id:[String] = []
    var ref: DatabaseReference?
    let formatter = DateFormatter()
    var date = Date()
    var fecha:String = ""
    
    // Crea un mensaje flotante temporal
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    let handleUser = Auth.auth().addStateDidChangeListener { (auth, user) in
        if Auth.auth().currentUser != nil{
            let user = Auth.auth().currentUser
            if let user = user{
                let usuarioNombre = user.displayName
                let usuarioEmail = user.email
            }
        }else {
        }
    }
   
    
    // Boton agregar Venta
    @IBAction func addVenta(_ sender: Any) {
        let alerta = self.crearAlerta(titulo: "Agregar Venta")
        
        // Creamos la accion de agregar venta
        let cancelBoton = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
        let agregarVenta = UIAlertAction(title: "Agregar", style: .default) { (accion) in
            if alerta.textFields?[0].text != "" && alerta.textFields?[1].text != ""{
                self.ref?.child(self.fecha).childByAutoId().setValue(["producto": alerta.textFields?[0].text ?? "Producto sin descripcion","precio": Int((alerta.textFields?[1].text!)!) ?? 0,"creado_por": Auth.auth().currentUser?.displayName ?? "Desconocido" ])
                alerta.textFields?[0].text = ""
                alerta.textFields?[1].text = ""
            }
        }
        alerta.addAction(agregarVenta)
        alerta.addAction(cancelBoton)
        present(alerta, animated: true,completion: nil)
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        self.hud.textLabel.text = "Cerrando Sesion"
        self.hud.show(in: view, animated: true)
        self.hud.dismiss(afterDelay: 1, animated: true)
        perform(#selector(Logout), with: nil, afterDelay: 1)
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Se cerro sesion")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    @objc func Logout(){
        self.performSegue(withIdentifier: "logout", sender: self)
    }
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Elimina las celdas extra
        myTableSale.tableFooterView = UIView()
        
        formatter.dateStyle = .medium
        self.fecha = formatter.string(from: date)
        ref = Database.database().reference()
        // Handle Añadir
        // Llenamos el array tanto de precios como productos para mostrarlos en la tableView
        handle = ref?.child(self.fecha).observe(.childAdded, with: { (snapshot) in
            let venta = snapshot.value as? NSDictionary
            if let precio = venta?["precio"] as? Int? ?? 0{
                if let producto = venta?["producto"] as? String? ?? ""{
                    self.id.append(snapshot.key)
                    self.producto.append(producto)
                    self.precio.append(precio)
                    self.myTableSale.reloadData()
                    self.sumaVenta = 0
                    for precios in self.precio {
                        self.sumaVenta += precios
                    }
                    self.ventaTotal.text = "$" +  String(self.sumaVenta)
                }
            }
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        // Handle editar
        // Modificamos la tabla si es que se actualizo algun elemento
        handleUpdate = ref?.child(self.fecha).observe(.childChanged, with: { (snapshot) in
            let venta = snapshot.value as? NSDictionary
            let llave = snapshot.key
            let index = self.id.index(of: llave)
            let precioAnterior = Int(self.precio[index!])
            self.producto[index!] = (venta?["producto"] as? String? ?? "")!
            self.precio[index!] = (venta?["precio"] as? Int? ?? 0)!
            self.sumaVenta = self.sumaVenta - precioAnterior + self.precio[index!]
            self.ventaTotal.text = "$" + String(self.sumaVenta)
            self.myTableSale.reloadData()
        })
        
        // Handle Borrar
        // Modificamos la tabla si es que se llega a eliminar un elemento
        handleDelete = ref?.child(self.fecha).observe(.childRemoved, with: { (snapshot) in
            let llave = snapshot.key
            if let index = self.id.index(of: llave){
                let precioProducto = self.precio[index]
                self.sumaVenta -= precioProducto
                self.ventaTotal.text = "$" +  String(self.sumaVenta)
                self.precio.remove(at: index)
                self.producto.remove(at: index)
                self.id.remove(at: index)
                self.myTableSale.reloadData()
                print("Handle borrar")
                print(llave)
                self.ref?.child(self.fecha).child(llave).removeValue()
            }
        
        })
    }
    // Creamos la alerta
    func crearAlerta(titulo:String) -> UIAlertController{
        let alerta = UIAlertController(title: titulo, message: "", preferredStyle: .alert)
        alerta.addTextField { (textField) in
            textField.placeholder = "Nombre del producto"
            textField.borderStyle = .roundedRect
        }
        alerta.addTextField { (textField) in
            textField.placeholder = "Precio del producto"
            textField.keyboardType = .decimalPad
            textField.borderStyle = .roundedRect
        }
        alerta.textFields?[0].delegate = self
        alerta.textFields?[1].delegate = self
        return alerta
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return producto.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ventaCell
        cell.productoCell.text = self.producto[indexPath.row]
        cell.precioCell.text = "$"+String(self.precio[indexPath.row])
        cell.numeracionCell.text = String(indexPath.row + 1)
        
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Boton Borrar
        let deleteButton = UITableViewRowAction(style: .destructive, title: "Borrar") { (accion, indexPath) in
            // Borramos el nodo de la base de datos
            self.ref?.child(self.fecha).child(self.id[indexPath.row]).setValue(nil)
        }
        //Boton Editar
        let editarAccion = UITableViewRowAction(style: .default, title: "Editar") { (accion, indexPath) in
            let alerta = self.crearAlerta(titulo: "Editar venta")
            alerta.textFields?[0].text = self.producto[indexPath.row]
            alerta.textFields?[1].text = String(self.precio[indexPath.row])
            let cancelButton = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
            // Creamos la accion de editar venta
            let editarVenta = UIAlertAction(title: "Actualizar", style: .default) { (accion) in
                if alerta.textFields?[0].text != "" && alerta.textFields?[1].text != ""{
                    self.ref?.child(self.fecha).child(self.id[indexPath.row]).setValue(["producto": alerta.textFields?[0].text ?? "Producto sin descripcion","precio": Int((alerta.textFields?[1].text!)!) ?? 0])
                    alerta.textFields?[0].text = ""
                    alerta.textFields?[1].text = ""
                }
            }
            alerta.addAction(editarVenta)
            alerta.addAction(cancelButton)
            self.present(alerta, animated: true,completion: nil)
        }
        editarAccion.backgroundColor = UIColor.blue
        return [deleteButton,editarAccion]
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Productos"
        }else{
            return "Producto     Precio"
        }
    }
    // Oculta el teclado al darle clic a return
    func hideKeyboard(textfield:UITextField){
        textfield.resignFirstResponder()
    }
    
}
