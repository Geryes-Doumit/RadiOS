//
//  RadioDetailsView.swift
//  RadiOS
//
//  Created by Geryes Doumit and Gauthier Cetingoz on 26/01/2025.
//

import SwiftUI
import AVKit

struct RadioDetailsView: View {
    var radio: Radio
    var playOnLaunch: Bool = false
    @State private var radioName: String = ""
    @State private var radioCategory: String = ""
    @State private var radioURL: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    @State private var isEditing = false
    @State private var showDeleteDialog: Bool = false
    
    @State private var isPlaying: Bool = false
    @State var player: AVPlayer?

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Title")) {
                    // Input for radio name
                    TextField("Tile", text: $radioName)
                        .textInputAutocapitalization(.words)
                        .disabled(!isEditing)
                }
                
                Section(header: Text("Category")) {
                    // Input for radio category
                    TextField("Category", text: $radioCategory)
                        .textInputAutocapitalization(.words)
                        .disabled(!isEditing)
                }
                
                Section(header: Text("URL")) {
                    // Input for radio URL
                    TextField("URL", text: $radioURL, axis: .vertical)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(!isEditing)
                }
            }
            .navigationTitle(radioName)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing, content: {
                    if (!isPlaying) {
                        HStack {
                            Button(action: {
                                showDeleteDialog = true
                            }) {
                                Text("Delete")
                            }.alert("Delete \"" + radioName + "\"?", isPresented: $showDeleteDialog,
                                    actions: {
                                VStack {
                                    Button(action: {
                                        showDeleteDialog = false
                                    }) {
                                        Text("Cancel")
                                    }
                                    Button(action: {
                                        onDelete()
                                    }) {
                                        Text("Delete")
                                    }
                                }
                            }
                            )
                            Button(action: {
                                toggleEdit()
                            }) {
                                if (!isEditing) {
                                    Text("Edit")
                                }
                                else {
                                    Text("OK")
                                }
                            }
                        }
                    }
                })
                ToolbarItem(placement: .bottomBar, content: {
                    VStack {
                        if (!isEditing) {
                            Button(action: {
                                toggleRadio()
                            }) {
                                if (isPlaying) {
                                    Image(systemName: "pause.fill")
                                }
                                else {
                                    Image(systemName: "play.fill")
                                }
                            }
                        }
                    }
                })
            })
            .onAppear{
                radioName = radio.title
                radioCategory = radio.category
                radioURL = radio.url
                player = AVPlayer(url: URL(string: radio.url)!)
            }
            .onDisappear{
                player?.pause()
            }
        }
    }
    
    private func updateRadio() -> Bool {
        if (radioName.isEmpty || radioCategory.isEmpty || radioURL.isEmpty) {
            return false
        }
        
        let success = RadioDB.shared.updateRadio(
            id: radio.id,
            title: radioName,
            category: radioCategory,
            url: radioURL
        )
        
        if (success) {
            let tempRadio = RadioDB.shared.fetchRadioById(radio.id)
            if (tempRadio != nil) {
                radioName = tempRadio!.title
                radioCategory = tempRadio!.category
                radioURL = tempRadio!.url
                
                let url = URL(string: radioURL)!
                player = AVPlayer(url: url)
            }
        }
        
        return success
    }
    
    private func toggleEdit() {
        if (!isEditing) {
            isEditing.toggle()
        }
        else {
            if (updateRadio()) {
                isEditing.toggle()
            }
        }
    }
    
    private func onDelete() {
        RadioDB.shared.deleteRadio(by: radio.id)
        dismiss()
    }
    
    private func toggleRadio() {
        if (radioURL.isEmpty) {
            return
        }
        
        if (isPlaying) {
            player?.pause()
        }
        else {
            player?.play()
        }
        
        isPlaying.toggle()
    }
}

#Preview {
    RadioDetailsView(radio: Radio(
        id: UUID(), title: "Test Radio", url: "https://www.google.com", category: "Test"
    ))
}
