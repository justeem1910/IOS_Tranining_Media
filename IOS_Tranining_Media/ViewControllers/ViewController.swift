//
//  ViewController.swift
//  IOS_Tranining_Media
//
//  Created by Hoang Long on 12/07/2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func TapOnBtnMap(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
