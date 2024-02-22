//
//  LabelEditVC.swift
//  Alarm
//
//  Created by pinali gabani on 11/12/23.
//

import UIKit

protocol LabelDelegate : NSObjectProtocol
{
    func labelDidChange(label : String)
}

class LabelEditVC: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var labelTextField: UITextField!
    
    var label: String!
    var delegate : LabelDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTextField.placeholder = "Please enter a label"
        labelTextField.autocorrectionType = .no
        labelTextField.becomeFirstResponder()
        labelTextField.delegate = self
        labelTextField.text = label
        labelTextField.returnKeyType = UIReturnKeyType.done
        labelTextField.enablesReturnKeyAutomatically = true
        labelTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.labelDidChange(label: textField.text ?? "Alarm")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        label = textField.text!
        //This method can be used when no state passing is needed
        //navigationController?.popViewController(animated: true)
        return false
    }
}
