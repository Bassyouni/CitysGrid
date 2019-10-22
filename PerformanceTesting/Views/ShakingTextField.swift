//
//  ShakingTextField.swift
//  CoreAnimation
//
//  Created by MacBook Pro on 5/1/18.
//  Copyright © 2018 Bassyouni. All rights reserved.
//

import UIKit

class ShakingTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        borderStyle = .roundedRect
        addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
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
        if let text = textField.text, let _ = Double(text)
        {
            textField.textColor = .black
        }
        else
        {
            textField.textColor = .red
        }
    }

}
