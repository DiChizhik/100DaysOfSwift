//
//  Files.swift
//  Consolidation 9-12
//
//  Created by Diana Chizhik on 29/05/2022.
//

import Foundation

struct Files {
    static func getDocumentDirectory() -> URL {
        let fm = FileManager.default
        let path = fm.urls(for: .documentDirectory, in: .userDomainMask)
        
        return path[0]
    }
    
    static func save(property: [Picture],forKey key: String) {
        let jsonEncoder = JSONEncoder()
        if let dataToSave = try? jsonEncoder.encode(property) {
            let defaults = UserDefaults.standard
            defaults.set(dataToSave, forKey: key)
        } else {
            print("Failed")
        }
    }
    
    static func loadSavedData(to property: inout [Picture], forKey key: String) {
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: key) as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                property = try jsonDecoder.decode([Picture].self, from: savedData)
            } catch {
                print("Failed to load.")
            }
        }
    }
}
