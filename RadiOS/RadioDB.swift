//
//  RadioDB.swift
//  RadiOS
//
//  Created by Geryes Doumit and Gauthier Cetingoz on 26/01/2025.
//

import Foundation
import SQLite3

class RadioDB {
    static let shared = RadioDB()
    
    // Pour faire fonctionner les requêtes
    fileprivate let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    private var db: OpaquePointer?
    private let dbName = "RadiosDatabase.sqlite"
    
    private init() {
        openDatabase()
        createTable()
        fillDataBaseIfEmpty()
    }
    
    // MARK: - Open Database
    private func openDatabase() {
        let filePath = getDatabasePath()
        if sqlite3_open(filePath, &db) != SQLITE_OK {
            print("Error opening database")
        } else {
            print("Database opened at \(filePath)")
        }
    }
    
    // MARK: - Get Database Path
    private func getDatabasePath() -> String {
        let fileManager = FileManager.default
        let documentsDir = try! fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        return documentsDir.appendingPathComponent(dbName).path
    }
    
    // MARK: - Create Table
    private func createTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS Radios (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            url TEXT NOT NULL,
            category TEXT NOT NULL
        );
        """
        executeQuery(query: createTableQuery)
    }
    
    // MARK: - Insert Radio
    func insertRadio(_ radio: Radio) {
        let insertQuery = "INSERT INTO Radios (id, title, url, category) VALUES (?, ?, ?, ?);"
        var statement: OpaquePointer?
        
        let urlString = radio.url.trimmingCharacters(in: .whitespaces)
        let categoryString = radio.category.trimmingCharacters(in: .whitespaces).lowercased().capitalized
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, radio.id.uuidString, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, radio.title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, urlString, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, categoryString, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Radio inserted successfully")
            } else {
                print("Failed to insert radio")
            }
        } else {
            print("Failed to prepare insert statement")
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Fetch All Radios
    func fetchRadios() -> [Radio] {
        let fetchQuery = "SELECT * FROM Radios ORDER BY category, title ASC;"
        var statement: OpaquePointer?
        var radios: [Radio] = []
        
        if sqlite3_prepare_v2(db, fetchQuery, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let idString = String(cString: sqlite3_column_text(statement, 0))
                let id = UUID(uuidString: idString) ?? UUID()
                let title = String(cString: sqlite3_column_text(statement, 1))
                let url = String(cString: sqlite3_column_text(statement, 2))
                let category = String(cString: sqlite3_column_text(statement, 3))
                
                let radio = Radio(id: id, title: title, url: url, category: category)
                radios.append(radio)
            }
        } else {
            print("Failed to prepare fetch statement")
        }
        sqlite3_finalize(statement)
        
        return radios
    }
    
    // MARK: - Fetch Radio by ID
    func fetchRadioById(_ id: UUID) -> Radio? {
        let fetchQuery = "SELECT * FROM Radios WHERE id = ?;"
        var statement: OpaquePointer?
        
        // Prepare the statement
        if sqlite3_prepare_v2(db, fetchQuery, -1, &statement, nil) == SQLITE_OK {
            // Bind the ID to the query
            sqlite3_bind_text(statement, 1, id.uuidString, -1, SQLITE_TRANSIENT)
            
            // Execute the query and check for results
            if sqlite3_step(statement) == SQLITE_ROW {
                // Extract the data for the radio
                let idString = String(cString: sqlite3_column_text(statement, 0))
                let title = String(cString: sqlite3_column_text(statement, 1))
                let url = String(cString: sqlite3_column_text(statement, 2))
                let category = String(cString: sqlite3_column_text(statement, 3))
                
                // Convert idString back to UUID
                if let radioId = UUID(uuidString: idString) {
                    // Create and return a Radio object
                    let radio = Radio(id: radioId, title: title, url: url, category: category)
                    sqlite3_finalize(statement)
                    return radio
                }
            } else {
                print("No radio found with ID: \(id.uuidString)")
            }
        } else {
            print("Failed to prepare fetch statement")
        }
        
        // Finalize the statement and return nil if no match
        sqlite3_finalize(statement)
        return nil
    }

    
    // MARK: - Delete Radio by ID
    func deleteRadio(by id: UUID) {
        let deleteQuery = "DELETE FROM Radios WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id.uuidString, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Radio deleted successfully")
            } else {
                print("Failed to delete radio")
            }
        } else {
            print("Failed to prepare delete statement")
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Update Radio by ID
    func updateRadio(id: UUID ,title: String, category: String, url: String) -> Bool {
        let updateQuery = """
        UPDATE Radios
        SET title = ?, category = ?, url = ?
        WHERE id = ?;
        """
        
        var success = false
        
        var statement: OpaquePointer?
        
        let categoryString = category.trimmingCharacters(in: .whitespaces).lowercased().capitalized
        let urlString = url.trimmingCharacters(in: .whitespaces)
        
        if sqlite3_prepare_v2(db, updateQuery, -1, &statement, nil) == SQLITE_OK {
            // Bind the values to the query
            sqlite3_bind_text(statement, 1, title, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, categoryString, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, urlString, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, id.uuidString, -1, SQLITE_TRANSIENT)
            
            // Execute the query
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Radio updated successfully")
                success = true
            } else {
                print("Failed to update radio")
            }
        } else {
            print("Failed to prepare update statement")
        }
        
        sqlite3_finalize(statement)
        return success
    }
    
    // MARK: - Execute Generic Query
    private func executeQuery(query: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Query executed successfully")
            } else {
                print("Query execution failed")
            }
        } else {
            print("Failed to prepare query")
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Fill database if empty
    private func fillDataBaseIfEmpty() {
            // Vérifier si la table est déjà remplie
            let existingRadios = fetchRadios()
            if existingRadios.isEmpty {
                let initialRadios = [
                    Radio(id: nil, title: "RTL", url: "http://streaming.radio.rtl.fr/rtl-1-44-128?listen=webCwsBCggNCQgLDQUGBAcGBg", category: "General"),
                    Radio(id: nil, title: "NRJ France", url: "http://cdn.nrjaudio.fm/adwz2/fr/30001/mp3_128.mp3?origine=fluxradios", category: "Musique"),
                    Radio(id: nil, title: "France Musique", url: "http://icecast.radiofrance.fr/francemusique-hifi.aac", category: "Musique"),
                    Radio(id: nil, title: "Skyrock", url: "http://icecast.skyrock.net/s/natio_aac_128k", category: "Musique"),
                    Radio(id: nil, title: "RTL2", url: "http://icecast.rtl2.fr/rtl2-1-44-128?listen=webCwsBCggNCQgLDQUGBAcGBg", category: "General"),
                    Radio(id: nil, title: "France Info", url: "http://icecast.radiofrance.fr/franceinfo-hifi.aac", category: "Infos"),
                    Radio(id: nil, title: "BFM Radio", url: "https://www.bfmtv.com/", category: "Infos")
                ]
                
                for radio in initialRadios {
                    insertRadio(radio)
                }
            }
        }
    
    // MARK: - Close Database
    func closeDatabase() {
        sqlite3_close(db)
    }
    
}
