//
//  ViewController.swift
//  Example
//
//  Created by SB 3 on 10/18/15.
//  Copyright © 2015 T4nhpt. All rights reserved.
//


import UIKit
import T4TextFieldValidator

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtEmailAddress:T4TextFieldValidator!
    @IBOutlet weak var txtPhoneNumber:T4TextFieldValidator!
    @IBOutlet weak var txtPassword:T4TextFieldValidator!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        txtEmailAddress.delegate = self
        txtPassword.delegate = self
        txtPhoneNumber.delegate = self
        
        txtEmailAddress.addRegx("(^[\\w\\.\\-]+@([\\w\\-]+\\.)+[a-zA-Z]+$)", withMsg: "Enter valid email")
        txtPhoneNumber.addRegx("[0-9]{3}\\-[0-9]{3}\\-[0-9]{4}", withMsg:"Phone number must be in proper format (eg. ###-###-####)")
        txtPassword.addRegx("^.{6,50}$", withMsg: "Password characters limit should be come between 6-20")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

