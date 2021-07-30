//
//  ViewController.swift
//  MyNotesApp
//
//  Created by David Todua on 25.07.21.
//

import UIKit
import CoreData

class SelectorVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    

    @IBOutlet weak var notesTable: UITableView!
    
    var notesArray = [Note]()
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTable.dataSource = self
        notesTable.delegate = self
        searchBar.delegate = self
        loadNotes()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notesTable.dequeueReusableCell(withIdentifier: "RegularCell")!
        cell.textLabel?.text = notesArray[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "NoteContent", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let row = notesTable.indexPathForSelectedRow?.row {
            let myParentNote = notesArray[row]
            if segue.identifier == "NoteContent" {
                if let destination = segue.destination as? NotesVC {
                    destination.myParentNote = myParentNote
                }
            }
        }
    }
    
//MARK: FOR DELETING NODES
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let deleting = notesArray.remove(at: indexPath.row)
        deleteDependentNodes(deleting: deleting)
        context.delete(deleting)
        saveNotes()
    }

    func deleteDependentNodes(deleting:Note) {
        let request: NSFetchRequest<ReadNote> = ReadNote.fetchRequest()
        let predicate = NSPredicate(format: "parentNote.name MATCHES %@", deleting.name!)
        request.predicate = predicate
        do {
            let someArray = try context.fetch(request)
            let index = someArray.count-1
            if index < 0 {return}
            for x in 0...index {
                print("paka " + ((someArray[0] as? ReadNote)?.textNote)! ?? "nwu" + " esari")
                context.delete(someArray[0])
            }
        } catch {
            print("some errors + \(error)")
        }
    }
}

//MARK: Add New Note

extension SelectorVC {
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "New Note", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "add", style: .default) { UIAlertAction in
            if let text = textField.text {

                let newNote = Note(context: self.context)
                newNote.name = text
                newNote.readNote = ReadNote(context: self.context)
                newNote.readNote?.parentNote = newNote
                newNote.readNote?.textNote = ""
                self.notesArray.append(newNote)
                self.saveNotes()

            }
        }
        
        alert.addTextField { (alertTF) in
            textField = alertTF
            alertTF.placeholder = "Choose The Name"
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}

//MARK: LOAD AND SAVE

extension SelectorVC {
    
    func loadNotes(predicate:NSPredicate? = nil ){
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        if predicate != nil {
            request.predicate = predicate!
        }
        
        do {
            notesArray = try context.fetch(request)
        } catch {
            print("fetch request")
        }
        notesTable.reloadData()
    }
    
    func saveNotes(){
        do {
            try context.save()
        } catch {
            print("couldn't save context + \(error)")
        }
        notesTable.reloadData()
    }
}

extension SelectorVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "name CONTAINS %@", searchBar.text! )
        loadNotes(predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text == "") {
            loadNotes()
        }
    }
    
}


