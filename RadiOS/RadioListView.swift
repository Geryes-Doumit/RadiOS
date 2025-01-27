//
//  RadioListView.swift
//  RadiOS
//
//  Created by Geryes Doumit on 26/01/2025.
//

import SwiftUI

struct RadioListView: View {
    @State var radios: [CategoryRadios] = []
    var randomRadio: Radio?
    
    var body: some View {
        NavigationStack {
            List {
                if radios.isEmpty {
                    Text("No Radios Found")
                }
                else {
                    ForEach(radios) {
                        catRadios in
                        Section(catRadios.category) {
                            ForEach(catRadios.radios) {
                                radio in
                                NavigationLink(destination: RadioDetailsView(radio: radio)) {
                                    HStack {
                                        Text(radio.title)
                                    }
                                }
                            }
                        }
                    }
                }
            }.navigationTitle(Text("Radios"))
                .toolbar(content: {
                    HStack {
//                        Button(action: {
//                            goToRandomRadio()
//                        }) {
//                            Image(systemName: "shuffle")
//                        }
                        
                        NavigationLink(destination: AddRadioView()) {
                            Image(systemName: "plus")
                        }
                    }
                })
                .onAppear {
                    radios = getRadios()
                }
        }
    }
    
    private func goToRandomRadio() {
        guard !radios.isEmpty else { return }
        let randomIndex = Int.random(in: 0..<radios.count)
        let firstRadioOfCategory = radios[randomIndex].radios.first!
        
    }
}

private func getRadios() -> [CategoryRadios] {
    return Radio.sortByCategory(RadioDB.shared.fetchRadios())
}

#Preview {
    RadioListView()
}
