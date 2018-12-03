//
//  ComicViewCell.swift
//  WebTests
//
//  Created by Dev1 on 29/11/2018.
//  Copyright © 2018 Dev1. All rights reserved.
//

import UIKit
//hemos quitado la constrains de la imagen abajo para que deje a la celda hacerse mas grande y no sea
//simpre mismo tamaño
class ComicViewCell: UITableViewCell {

   @IBOutlet weak var imagen: UIImageView!
   
   @IBOutlet weak var cabecera: UILabel!
   
   @IBOutlet weak var detalle: UILabel!
   override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
