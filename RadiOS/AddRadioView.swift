//
//  AddRadioView.swift
//  RadiOS
//
//  Created by Geryes Doumit on 26/01/2025.
//

import SwiftUI

struct AddRadioView: View {
    @State private var radioName: String = ""
    @State private var radioCategory: String = ""
    @State private var radioURL: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Radio Details")) {
                    // Input for radio name
                    TextField("Radio Name", text: $radioName)
                        .textInputAutocapitalization(.words)

                    // Input for radio category
                    TextField("Category", text: $radioCategory)
                        .textInputAutocapitalization(.words)

                    // Input for radio URL
                    TextField("URL", text: $radioURL, axis: .vertical)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                // Submit button
                Section {
                    Button(action: {
                        handleAddRadio()
                    }) {
                        Text("Add Radio")
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                    }.disabled(!areFieldsCorrect())
                }
            }
            .navigationTitle("Add Radio")
        }
    }

    // Function to handle the "Add Radio" action
    private func handleAddRadio() {
        let radio = Radio(id:nil, title: radioName, url: radioURL, category: radioCategory)
        RadioDB.shared.insertRadio(radio)
        dismiss()
    }
    
    private func areFieldsCorrect() -> Bool {
        return !radioName.isEmpty && !radioCategory.isEmpty && !radioURL.isEmpty
    }
}

#Preview {
    AddRadioView()
}
