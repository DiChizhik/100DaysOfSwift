//
//  Note.swift
//  Consolidation 19-21 notesApp
//
//  Created by Diana Chizhik on 17/06/2022.
//

import Foundation

struct Note: Codable {
    var name: String
    var details: String?
    
    init?(with string: String) {
        guard !string.isEmpty else { return nil }
        
        let stringArray = string.components(separatedBy: "\n")
        print(stringArray.count)
        
        switch stringArray.count {
        case 1:
            self.name = stringArray[0]
            self.details = nil
        case 2...stringArray.count:
            self.name = stringArray[0]
            
            let initialDescription = ""
            var finalDescription = ""
            stringArray[1..<stringArray.count].forEach{ paragraph in
                finalDescription = initialDescription.appending(paragraph)
            }
            self.details = finalDescription
        default:
            print("Failed to initialize")
            return nil
        }
    }
}

