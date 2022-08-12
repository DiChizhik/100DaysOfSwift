//
//  GetDataService.swift
//  Consolidation 13-15
//
//  Created by Diana Chizhik on 12/06/2022.
//

import Foundation

final class DataService {
    func getData() -> [Country] {
        var countriesData = Data()
        var countriesList = [Country]()
        
        if let url = Bundle.main.url(forResource: "data", withExtension: "json") {
            if let data = try? Data(contentsOf: url) {
                countriesData = data
                assert(!countriesData.isEmpty, "Countries data is empty")
            }
        }
        
        let jsonDecoder = JSONDecoder()
        if let countries = try? jsonDecoder.decode([Country].self, from: countriesData) {
            countriesList = countries
            assert(!countriesList.isEmpty, "Countries list is empty")
        }
        return countriesList
    }
}
