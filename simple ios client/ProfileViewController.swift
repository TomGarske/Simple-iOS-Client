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
    @IBOutlet weak var dateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameLabel.text = "TomGarske"
        let formatt = DateFormatter()
        formatt.dateStyle = .long
        formatt.timeStyle = .none
        let timestamp = formatt.string(from: Date())
        dateLabel.text = String.init(format:"User Since: %@",timestamp)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    @IBAction func didTapDeleteAccount(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Delete",
                                      message: "Are you sure you want to DELETE your account?",
                                      preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil));
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action:UIAlertAction) in
            self.deleteAccount()
            self.dismiss(animated: true, completion: nil)
        }));
        present(alert, animated: true, completion: nil);
    }

    func deleteAccount()
    {

    }
}
