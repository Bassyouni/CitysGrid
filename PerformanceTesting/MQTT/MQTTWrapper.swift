//
//  MQTTWrapper.swift
//  MQTT_Presnt
//
//  Created by Bassyouni on 7/13/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import RxSwift
import CocoaMQTT

enum MQTTError: Error {
    case PublishMessageFailure(message: String, topic: String)
    case UnSubscribeToTopicFailure(topic: String)
    case SubscribeToTopicFailure(topic: String)
}

class MQTTManager
{
    
    // MARK:- Constructors & destructors
    init()
    {
        
        constructor(url: "farmer.cloudmqtt.com", port: 15378)
    }
    
    deinit
    {
        mqtt.disconnect()
        print("mqtt deinit")
    }
    
    private func constructor(url:String , port:UInt16) {
        if mqtt == nil
        {
            let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
            
            mqtt = CocoaMQTT(clientID: clientID, host: url, port: port)
            mqtt.username = "ufbbcnhf"
            mqtt.password = "ua0S90YC4kyH"
            mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
            mqtt.keepAlive = 60
            addBindings()
        }
    }
    
    
    // MARK:- private variables
    private var mqtt: CocoaMQTT!
    static let sharedConnection = MQTTManager()
    
    private let recivedMessageSubject = PublishSubject<(message: String, topic: String)>()
    private let connectionStatusSubject = PublishSubject<Bool>()
    
    
    // MARK: - initilization
    fileprivate func addBindings() {
        mqtt.didConnectAck = { [unowned self] _, _ in
            self.connectionStatusSubject.onNext(true)
        }
        
        mqtt.didDisconnect = { [unowned self] _, error in
            if let error = error {
                self.connectionStatusSubject.onError(error)
            }
            self.connectionStatusSubject.onNext(false)
        }
        
        mqtt.didReceiveMessage = { [unowned self] _, cocoaMessage, _ in
            if let message = cocoaMessage.string {
                self.recivedMessageSubject.onNext((message, cocoaMessage.topic))
            }
        }
    }
    
    
    //MARK:- public functions
    public func connect()
    {
        _ = mqtt.connect()
    }
    
    public func ping()
    {
        mqtt.ping()
    }
    
    public func disconnect()
    {
        mqtt.disconnect()
    }
    
    public func subscribe(toTopic:String)
    {
        mqtt.subscribe(toTopic)
    }
    
    public func unSuscribe(toTopic:String)
    {
        mqtt.unsubscribe(toTopic)
    }
    
    public func publish(message: String, topic: String)
    {
        mqtt.publish(topic, withString: message)
    }
    
    
}

extension MQTTManager {
    
    var recivedMessage: Observable<(message: String, topic: String)> {
        return recivedMessageSubject.asObservable()
    }
    
    var connectionStatus: Observable<Bool> {
        return connectionStatusSubject.asObservable()
    }
    
}
