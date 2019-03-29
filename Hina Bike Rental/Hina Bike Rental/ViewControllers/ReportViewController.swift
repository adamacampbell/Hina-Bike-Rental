//
//  ReportViewController.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 01/02/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        //Open url for support page.
        if let url = URL(string: "https://www.google.com")
        {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
