//
//  FileSavingManager.swift
//  PerformanceTesting
//
//  Created by Bassyouni on 10/27/19.
//  Copyright © 2019 Bassyouni. All rights reserved.
//

import Foundation

class FileSavingManager
{
    static func save(jsony: [Region], toFileName fileName: String?) {
        let pathDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = fileName ?? "myJSON"
        let filePath = pathDirectory.appendingPathComponent("\(fileName).json")
        
        let json = try? JSONEncoder().encode(jsony)
        
        do {
            try json!.write(to: filePath, options: .atomic)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
        
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
    }
}
