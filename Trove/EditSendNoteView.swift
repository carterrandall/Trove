//
//  EditSendNoteView.swift
//  Trove
//
//  Created by Carter Randall on 2020-06-04.
//  Copyright © 2020 Carter Randall. All rights reserved.
//
import UIKit

protocol EditSendNoteViewDelegate {
    func saveNote()
}

class EditSendNoteView: UIView, UITextFieldDelegate {
    
    var text: String?
    
    var delegate: EditSendNoteViewDelegate?
    
    let saveNoteButton: UIButton = {
        let button = SaveButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        return button
    }()
    
    let noteField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Edit Note"
        tf.textColor = UIColor.white
        tf.backgroundColor = .none
        tf.addTarget(self, action: #selector(handleChange), for: .editingChanged)
        return tf
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.mainGold().withAlphaComponent(0.5)
        
        
        addSubview(saveNoteButton)
        saveNoteButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 60)
        saveNoteButton.addTarget(self, action: #selector(handleSaveNote), for: .touchUpInside)
        
        addSubview(noteField)
        noteField.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: saveNoteButton.leftAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 60)
        
        let line = UIView()
        line.backgroundColor = UIColor.white
        addSubview(line)
        line.anchor(top: topAnchor, left: saveNoteButton.leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 1, height: 0)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleSaveNote() {
        delegate?.saveNote()
        saveNoteButton.isEnabled = false
        saveNoteButton.setTitle("Saving", for: [])
        noteField.isUserInteractionEnabled = false
    }
    
    @objc fileprivate func handleChange() {
        guard let txt = noteField.text else { return }
        self.text = txt
        
        if txt.count > 30 {
            noteField.deleteBackward()
        }
        
        
       
        
        
    }
    
}
