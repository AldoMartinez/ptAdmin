//
//  ventaDiaHistorialController.swift
//  ptAdmin
//
//  Created by Aldo Aram Martinez Mireles on 6/22/18.
//  Copyright © 2018 Aldo Aram Martinez Mireles. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class ventaDiaHistorialController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var productoView: UILabel!
    @IBOutlet var precioView: UILabel!
    @IBOutlet var creadorView: UILabel!
    
    @IBOutlet var popUp: UIView!
    @IBOutlet var registroVentasTable: UITableView!
    
    @IBOutlet var dato: UILabel?
    
    var ref: DatabaseReference?
    var diaSeleccionado:String = ""
    var handleDia: DatabaseHandle = 0
    var contador = 0
    var ventas:[Venta] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popUp.layer.cornerRadius = 10
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(press:)))
        longPressRecognizer.minimumPressDuration = 1.0
        self.registroVentasTable.addGestureRecognizer(longPressRecognizer)
        self.dato?.text = diaSeleccionado
        ref = Database.database().reference()
        handleDia = (ref?.child(self.diaSeleccionado).observe(.childAdded, with: { (snapshot) in
            self.contador += 1
            let venta: Venta
            let ventaDelDia = snapshot.value as! NSDictionary
            if let creador = ventaDelDia["creado_por"] as? String{
                venta = Venta(producto: ventaDelDia["producto"] as! String, precio: ventaDelDia["precio"] as! Int, numeroVenta: self.contador, creadoPor: creador)
            }else{
                venta = Venta(producto: ventaDelDia["producto"] as! String, precio: ventaDelDia["precio"] as! Int, numeroVenta: self.contador, creadoPor: "Usuario Desconocido")
            }
            
            self.ventas.append(venta)
            self.registroVentasTable.reloadData()

        }))!
    }
    @objc func longPress(press: UILongPressGestureRecognizer){
        if press.state == UIGestureRecognizer.State.began{
            let touchPoint = press.location(in: self.registroVentasTable)
            if let indexPath = registroVentasTable.indexPathForRow(at: touchPoint){
                self.productoView.text = self.ventas[indexPath.row].Producto
                self.precioView.text = String(self.ventas[indexPath.row].Precio)
                self.creadorView.text = self.ventas[indexPath.row].creadoPor
                
                self.view.addSubview(popUp)
                popUp.center = self.view.center
            }
        }
        if press.state == UIGestureRecognizer.State.ended{
            self.popUp.removeFromSuperview()
        }
    }
    // Funciones Table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ventas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath) as! registroCell
        cell.producto.text = self.ventas[indexPath.row].Producto!
        cell.precio.text = "$" + String(self.ventas[indexPath.row].Precio!)
        cell.numeroVenta.text = String(self.ventas[indexPath.row].numeroVenta!)
        return cell
    }
    
    
}
