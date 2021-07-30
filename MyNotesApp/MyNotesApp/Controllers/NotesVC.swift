//
//  NotesVC.swift
//  MyNotesApp
//
//  Created by David Todua on 25.07.21.
//

import UIKit
import CoreData

class NotesVC: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var myParentNote:Note?
    var note = [ReadNote]()
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNote()
        if note.count > 0 {
            textView.text = note[0].textNote
        }
}
    
}

extension  NotesVC: UITextViewDelegate {
    
    @IBAction func doneEditing(_ sender: UIBarButtonItem) {
        textView.delegate = self
        textView.resignFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let currNote = ReadNote(context: context)
        currNote.textNote = textView.text
        currNote.parentNote = myParentNote
        if(note.count > 0) {
            note[0] = currNote
            print("00")
        } else {
            note.append(currNote)
            print("0")

        }
        for x in 0...note.count-1 {
            print(note[x].textNote! + "JJ")
        }
        saveNote()
    }
}


extension NotesVC {
    
    func loadNote() {
        let request: NSFetchRequest<ReadNote> = ReadNote.fetchRequest()
        print(myParentNote!.name!)
        let predicate = NSPredicate(format: "parentNote.name MATCHES %@", myParentNote!.name!)
        
        request.predicate = predicate
        do {
            note = try context.fetch(request)
        } catch {
            print("cant load \(error)")
        }
    }
    
    func saveNote() {
        do {
            try context.save()
        } catch {
            print("cant save \(error)")
        }
    }
}
