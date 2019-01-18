//
//  Venta.swift
//  ptAdmin
//
//  Created by Aldo Aram Martinez Mireles on 7/10/18.
//  Copyright © 2018 Aldo Aram Martinez Mireles. All rights reserved.
//

import Foundation

class Venta {
    var Producto: String!
    var Precio: Int!
    var numeroVenta: Int!
    var creadoPor: String!
    
    init(producto: String, precio: Int, numeroVenta: Int, creadoPor: String) {
        self.Producto = producto
        self.Precio = precio
        self.numeroVenta = numeroVenta
        self.creadoPor = creadoPor
    }
    init() {
        self.Producto = "Producto desconocido"
        self.Precio = 0
        self.numeroVenta = 0
        self.creadoPor = "Admin"
    }
    
}
