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
    let myCoordinate = Coordinate(latitude: 25.02553, longitude: 55.179775)
    var lastLocationDate: Date?
    
    
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
            CATransaction.setAnimationDuration(Date().timeIntervalSince(lastLocationDate!))
            driverMarkers[index].position = coordinate2D
            self.mapView.animate(toLocation: coordinate2D)
            CATransaction.commit()
            lastLocationDate = Date()
        }
        else
        {
            
            let newMarker = GMSMarker(position: coordinate2D)
            newMarker.title = "\(carId)"
            newMarker.map = mapView
            newMarker.appearAnimation = .pop
            newMarker.icon = imageWithImage(image: UIImage(named: "tawseelMarker")!, scaledToSize: CGSize(width: 60 , height: 60))
            self.mapView.animate(toLocation: coordinate2D)
            driverMarkers.append(newMarker)
            lastLocationDate = Date()
        }
    }
    
    
    // MARK: - helpers
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        //image.draw(in: CGRectMake(0, 0, newSize.width, newSize.height))
        image.draw(in: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: newSize.width, height: newSize.height))  )
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
