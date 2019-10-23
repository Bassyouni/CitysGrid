//
//  AddCoordinatesViewController.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/22/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import UIKit
import RxCocoa


class AddCoordinatesViewController: UIViewController {
    
    var textFields = [ShakingTextField]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Add Region"
        
        view.backgroundColor = .white
        
        var arrangedSubViews = [UIView]()
        
        let leftLabel = UILabel(frame: .zero)
        leftLabel.text = "Latitude"
        leftLabel.textAlignment = .center
        
        let rightLabel = UILabel(frame: .zero)
        rightLabel.text = "Longitude"
        rightLabel.textAlignment = .center
        
        let labelStack = UIStackView(arrangedSubviews: [leftLabel, rightLabel])
        labelStack.axis = .horizontal
        labelStack.distribution = .fillEqually
        labelStack.spacing = 15
        arrangedSubViews.append(labelStack)
        
        for i in 1...4
        {
            let latTextField = ShakingTextField(placeholder: "Latitude \(i)")
            let longTextField = ShakingTextField(placeholder: "Longitude \(i)")
            
            let textFieldsStack = UIStackView(arrangedSubviews: [latTextField, longTextField])
            textFieldsStack.axis = .horizontal
            textFieldsStack.distribution = .fillEqually
            textFieldsStack.spacing = 15
            arrangedSubViews.append(textFieldsStack)
            
            textFields.append(contentsOf: [latTextField, longTextField])
        }
        
        let verticalStackView = UIStackView(arrangedSubviews: arrangedSubViews)
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 15
        view.addSubview(verticalStackView)
        verticalStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 15, bottom: 15, right: 15))
        
        
        let button = UIButton(frame: .zero)
        button.setTitle("Show On map", for: .normal)
        view.addSubview(button)
        
        button.anchor(top: verticalStackView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 25, bottom: 0, right: 25), size: .init(width: 0, height: 50))
        button.layer.cornerRadius = 25
        button.backgroundColor = .init(red: 66/255, green: 139/255, blue: 199/255, alpha: 1)
        button.titleLabel?.textColor = .white
        button.addTarget(self, action: #selector(openInMapPressed), for: .touchUpInside)
    }
    
    
    @objc func openInMapPressed() {
        
        var coordinatesMatrix = [[Double]]()
        var rowArray = [Double]()
        var hasError: Bool = false
        
        let showError: (_ textField: ShakingTextField) -> () = { textField in
            textField.shake()
            hasError = true
        }
        
        textFields.forEach { (textField) in
            if let text = textField.text, let number = Double(text)
            {
                if rowArray.count == 0
                {
                    rowArray.append(number)
                    
                    if abs(number) > 90
                    {
                        showError(textField)
                    }
                }
                else
                {
                    rowArray.append(number)
                    coordinatesMatrix.append(rowArray)
                    rowArray.removeAll()
                    
                    if abs(number) > 180
                    {
                        showError(textField)
                    }
                }
            }
            else
            {
                showError(textField)
            }
        }
        
        
        if !hasError
        {
            let coordinates = coordinatesMatrix.map { Coordinate(latitude: $0[0], longitude: $0[1]) }
            navigationController?.pushViewController(RegionShowerViewController(coordinates: coordinates), animated: true)
        }
//        else
//        {
//            let coordinates =  [Coordinate(latitude: 24.604503, longitude: 54.844086),
//                                Coordinate(latitude: 24.138950, longitude: 54.816490),
//                                Coordinate(latitude: 24.173921, longitude: 54.256488),
//                                Coordinate(latitude: 24.624247, longitude: 54.285306)]
//            navigationController?.pushViewController(RegionShowerViewController(coordinates: coordinates), animated: true)
//        }
    }
}

