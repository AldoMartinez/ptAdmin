//
//  historialVentasController.swift
//  ptAdmin
//
//  Created by Aldo Aram Martinez Mireles on 6/20/18.
//  Copyright © 2018 Aldo Aram Martinez Mireles. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import JGProgressHUD

class historialVentasController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    @IBOutlet var historialTable: UITableView!
    
    // Crea un mensaje flotante temporal
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    // Variables de Firebase
    var ref:DatabaseReference?
    var handleDias:DatabaseHandle?
    
    
    // Variables
    var historialVentasPorDia: [String] = []
    var numVentasPorDia: [Int] = []
    var sumaVenta:[Int] = []
    var numArticulos:Int = 0
    var promedioVenta:[Float] = []
    var fecha: String = ""
    var formatter = DateFormatter()
    var ventasTotales:[String] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Elimina las celdas extra
        historialTable.tableFooterView = UIView()
        
        formatter.dateStyle = .medium
        self.fecha = formatter.string(from: Date())
        ref = Database.database().reference()
        handleDias = ref?.observe(.childAdded, with: { (snapshot) in
            if self.fecha != String(snapshot.key){
                var suma = 0
                // Agregamos las fechas a la table View
                if let dia:String = snapshot.key {
                    self.historialVentasPorDia.append(dia)
                }
                
                for child in snapshot.children{
                    let hijo = child as! DataSnapshot
                    self.ventasTotales.append(hijo.key)
                    if let propiedades = hijo.value as? NSDictionary{
                        if (propiedades["precio"] as? Int) != nil{
                            suma += propiedades["precio"] as! Int
                        }
                    }
                }
                self.sumaVenta.append(suma)
                
                // Guardamos la cantidad de ventas por cada dia
                if let registros = snapshot.value as? NSDictionary{
                    self.numVentasPorDia.append(registros.allKeys.count)
                }
                // Sacamos el promedio de venta de cada dia
                self.promedioVenta.append(Float(suma)/Float(snapshot.childrenCount))
                
                self.historialTable.reloadData()
            }
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        print(self.ventasTotales)
    }
    // Funcion para ocultar keyboard al pulsar fuera del teclado
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Funciones de la historial Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historialVentasPorDia.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! historialTableCell
        cell.fechaVenta.text = self.historialVentasPorDia[indexPath.row]
        cell.ventaTotal.text = "$" + String(self.sumaVenta[indexPath.row])
        cell.promedioVenta.text = "Promedio de venta: $" + String(self.promedioVenta[indexPath.row])
        cell.articulosVendidos.text = "Articulos vendidos: " + String(self.numVentasPorDia[indexPath.row])
        return cell
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ventaDiaHistorialController{
            destination.diaSeleccionado = self.historialVentasPorDia[(historialTable.indexPathForSelectedRow?.row)!]
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
