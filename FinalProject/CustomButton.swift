//
//  CustomButton.swift
//  FinalProject
//
//  Created by Saule on 10/04/2019.
//  Copyright © 2019 Saule. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        customizeButton()
    }

    func customizeButton(){
        backgroundColor = UIColor.lightGray
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
}
