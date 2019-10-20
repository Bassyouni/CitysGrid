//
//  CustomerViewController.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/20/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift

class CustomerViewController: BaseViewController {
    
    var driverMarkers = [GMSMarker]()
    let myCoordinate = Coordinate(latitude: 25.123612, longitude: 55.179775)
    
    
    override func startOperation() {
        if let region = tree.nodeFor(value: myCoordinate)?.region {
            let topic = "tawseel/drivers/\(region.id)"
            MQTTManager.sharedConnection.subscribe(toTopic: topic)
            
            MQTTManager.sharedConnection.recivedMessage.subscribe(onNext: { (message, recivedTopic) in
                print(recivedTopic)
                print(message)
                guard topic == recivedTopic else { return }
                self.didReciveMessage(with: message)
            })
                .disposed(by: bag)
        }
    }
    
    func didReciveMessage(with message: String) {
        let jsonDecoder = JSONDecoder()
        
        do
        {
            let carObject = try jsonDecoder.decode(Car.self, from: Data(message.utf8))
            
            let index = driverMarkers.firstIndex { (marker) -> Bool in
                return marker.title == "\(carObject.carId)"
            }
            
            if let carCoordinate = carObject.coordinate
            {
                applyMarkerOnMap(index ?? nil, carCoordinate.coordinate2D, carObject.carId)
            }
            else
            {
                removeMarker(index)
            }
            
        }
        catch let error
        {
            print(error.localizedDescription)
        }
        
    }
    
    fileprivate func removeMarker(_ index: Int?) {
        if let index = index
        {
            driverMarkers[index].map = nil
            driverMarkers.remove(at: index)
        }
    }
    
    fileprivate func applyMarkerOnMap(_ index: Int?, _ coordinate2D: CLLocationCoordinate2D, _ carId: Int) {
        if let index = index
        {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.1)
            driverMarkers[index].position = coordinate2D
            CATransaction.commit()
        }
        else
        {
            let newMarker = GMSMarker(position: coordinate2D)
            newMarker.title = "\(carId)"
            newMarker.map = mapView
            driverMarkers.append(newMarker)
            newMarker.appearAnimation = .pop
        }
    }
    
}
