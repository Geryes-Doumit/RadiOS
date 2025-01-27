//
//  Radio.swift
//  RadiOS
//
//  Created by Geryes Doumit and Gauthier Cetingoz on 26/01/2025.
//

import Foundation

class Radio: Identifiable {
    let id : UUID
    let title: String
    let url: String
    let category: String
    
    // Pour créer une nouvelle radio, on passe un ID nil
    init(id: UUID?, title: String, url: String, category: String) {
        if id == nil {
            self.id = UUID()
        } else {
            self.id = id!
        }
        
        self.title = title
        self.url = url
        self.category = category
    }
    
    
    static func sortByCategory(_ orderedRadios: [Radio]) -> [CategoryRadios] {
        if (orderedRadios.isEmpty) {
            return []
        }
        
        var currentCategory: String = orderedRadios.first!.category
        var categoryRadios: [CategoryRadios] = []
        var tempRadioList: [Radio] = []
        for radio in orderedRadios {
            if radio.category.uppercased() == currentCategory.uppercased(){
                tempRadioList.append(radio)
            }
            else {
                categoryRadios.append(CategoryRadios(
                    category: currentCategory, radios: tempRadioList
                ))
                tempRadioList = [radio]
                currentCategory = radio.category
            }
        }
        categoryRadios.append(CategoryRadios(
            category: currentCategory, radios: tempRadioList
        ))
        
        return categoryRadios
    }
    
}
