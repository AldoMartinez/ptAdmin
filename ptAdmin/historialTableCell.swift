//
//  historialTableCell.swift
//  ptAdmin
//
//  Created by Aldo Aram Martinez Mireles on 6/20/18.
//  Copyright © 2018 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit

class historialTableCell: UITableViewCell {

    @IBOutlet var ventaTotal: UILabel!
    @IBOutlet var articulosVendidos: UILabel!
    @IBOutlet var fechaVenta: UILabel!
    @IBOutlet var promedioVenta: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
