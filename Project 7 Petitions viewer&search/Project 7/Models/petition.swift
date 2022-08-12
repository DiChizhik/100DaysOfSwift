//
//  petition.swift
//  Project 7
//
//  Created by Diana Chizhik on 17/05/2022.
//

import Foundation

struct Petition: Codable, Equatable {
    var title: String
    var body: String
    var signatureCount: Int
}
