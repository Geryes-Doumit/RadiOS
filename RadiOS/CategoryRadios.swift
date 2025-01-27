//
//  CategoryRadios.swift
//  RadiOS
//
//  Created by Geryes Doumit and Gauthier Cetingoz on 26/01/2025.
//

import Foundation

class CategoryRadios : Identifiable {
    let category: String
    let radios: [Radio]
    
    init(category: String, radios: [Radio]) {
        self.category = category
        self.radios = radios
    }
}
