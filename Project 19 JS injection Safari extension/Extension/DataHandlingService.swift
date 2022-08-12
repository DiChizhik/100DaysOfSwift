//
//  DataHandlingService.swift
//  Extension
//
//  Created by Diana Chizhik on 13/06/2022.
//

import Foundation

struct Script: Codable {
    var name: String
    var scriptText: String
}

class DataHandlingService {
    func saveScriptToUserDefaults(_ object: String, withKey key: String) {
        guard !object.isEmpty else { return }
        
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(object) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: key)
            print("Successfully saved")
        } else {
            print("Failed to save data")
        }
    }
    
    func saveScriptsToUserDefaults(_ object: [Script], withKey key: String) {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(object) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: key)
            print("Successfully saved")
        } else {
            print("Failed to save data")
        }
    }
    
    func loadScriptFromUserDefaults(withKey key: String) -> String? {
        let userDefaults = UserDefaults.standard
        if let savedData = userDefaults.object(forKey: key) as? Data {
            let jsonDecoder = JSONDecoder()
            if let dataToLoad = try? jsonDecoder.decode(String.self, from: savedData ) {
                return dataToLoad
            }
        }
        return nil
    }
    
    func loadScriptsFromUserDefaults(withKey key: String) -> [Script]? {
        let userDefaults = UserDefaults.standard
        if let savedData = userDefaults.object(forKey: key) as? Data {
            let jsonDecoder = JSONDecoder()
            if let dataToLoad = try? jsonDecoder.decode([Script].self, from: savedData ) {
                return dataToLoad
            }
        }
        return nil
    }
}

class GetHostService {
    func getHost(urlString: String) -> String? {
        if let url = URL(string: urlString) {
            if let host = url.host {
                return host
            }
        }
        return nil
    }
}
