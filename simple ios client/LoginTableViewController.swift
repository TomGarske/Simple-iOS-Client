//
//  LoginTableViewController.swift
//  simple ios client
//
//  Created by Thomas Garske on 12/11/16.
//  Copyright © 2016 csci4211. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        confirmPassword.isHidden = true
        registerButton.isHidden = true
        isRegistering = false
    }

    var isRegistering = false
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var success : Bool = true
        if( identifier == "segue_login"){
            success = attemptLogin()
            if (!success) {
                registerButton.isHidden = false
            }
        }
        return success
    }

    func attemptLogin() -> Bool {
        var success =  false
        if(isRegistering){
            success = registerUser()
        }
        return success
    }

    func registerUser() -> Bool{
        return true
    }

    @IBAction func didTapRegisterUser(_ sender: Any) {
        confirmPassword.isHidden = false
        registerButton.isHidden = true
        isRegistering = true
    }
}
