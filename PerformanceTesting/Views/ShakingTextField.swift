//
//  ShakingTextField.swift
//  CoreAnimation
//
//  Created by MacBook Pro on 5/1/18.
//  Copyright © 2018 Bassyouni. All rights reserved.
//

import UIKit

enum CoordinateType: String {
    case latitude = "Latitude"
    case longitude = "Longitude"
}

class ShakingTextField: UITextField {
    
    var coordinateType:CoordinateType = .latitude
    
    init(placeholder: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        borderStyle = .roundedRect
        addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        
        if let type = CoordinateType(rawValue: placeholder.components(separatedBy: " ").first ?? "")
        {
            coordinateType = type
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shake()
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.autoreverses = true
        animation.repeatCount = 5
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 4, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 4, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
    @objc func textChanged(_ textField: UITextField) {
    
        
        if let text = textField.text, let number = Double(text)
        {
            switch coordinateType {

            case .latitude:
                if abs(number) <= 90
                {
                    textField.textColor = .black
                }
                else
                {
                    textField.textColor = .red
                }
                
            case .longitude:
                if abs(number) <= 180
                {
                    textField.textColor = .black
                }
                else
                {
                    textField.textColor = .red
                }
            }
        }
        else
        {
            textField.textColor = .red
        }
    }

}
