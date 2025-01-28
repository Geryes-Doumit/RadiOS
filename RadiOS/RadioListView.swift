//
//  RadioListView.swift
//  RadiOS
//
//  Created by Geryes Doumit and Gauthier Cetingoz on 26/01/2025.
//

import SwiftUI

struct RadioListView: View {
    @State var radios: [CategoryRadios] = []
    
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
}

private func getRadios() -> [CategoryRadios] {
    return Radio.sortByCategory(RadioDB.shared.fetchRadios())
}

#Preview {
    RadioListView()
}
