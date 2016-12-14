//
//  ProfileViewController.swift
//  simple ios client
//
//  Created by Thomas Garske on 12/12/16.
//  Copyright © 2016 csci4211. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.text = "UserID: " + String(self.getUserId())
    }

    @IBAction func didTapLogout(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Logout",
                                      message: "Are you sure you want to log out?",
                                      preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil));
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action:UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }));
        present(alert, animated: true, completion: nil);
    }
}
