//  CryptoViewController.swift
//  bazaar

import UIKit

//The CryptoViewController is a simple view controller which contains container views for the CryptoGraphViewController and
//CryptoTableViewController

class CryptoViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
