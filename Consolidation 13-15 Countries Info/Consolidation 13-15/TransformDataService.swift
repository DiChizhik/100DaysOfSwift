//
//  String.swift
//  Consolidation 13-15
//
//  Created by Diana Chizhik on 12/06/2022.
//

import Foundation

class TransformDataService {
    func makeLookLikeInt (floatLookingString: String) -> String {
        if let float = Float(floatLookingString) {
            let int = Int(float.rounded())
            let string = String(int)
            return string
        }
        
        return floatLookingString
    }
}
