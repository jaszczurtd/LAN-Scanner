//
//  ViewController.swift
//  LAN_Scanner
//
//  Created by Marcin Kielesinski on 08.07.2018.
//  Copyright © 2018 c&c. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var scanner : LanScan?
    var connectedDevices: [[AnyHashable: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.startScanningLAN))
        navigationItem.rightBarButtonItem = refreshBarButton
        
        progressBar.progress = 0.0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScanningLAN()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scanner?.stop()
    }

    @objc func startScanningLAN() {
        scanner?.stop()
        scanner = LanScan(delegate: self)
        
        connectedDevices = []
        progressBar.progress = 0.0
        tableView.reloadData() {
            self.navigationItem.title = self.scanner?.getCurrentWifiSSID()
            self.scanner?.start()
        }
    }
}

extension ViewController: LANScanDelegate {
    
    func lanScanHasUpdatedProgress(_ counter: Int, address: String!) {
        progressBar.progress = Float(counter) / Float(MAX_IP_RANGE)
    }
    
    func lanScanDidFindNewDevice(_ device: [AnyHashable : Any]!) {
        connectedDevices.append(device as! [AnyHashable: String])
        tableView.reloadData()
    }
    
    func lanScanDidFinishScanning() {
        presentAlert(title: "Scan Finished", message: "Number of devices connected to your Local Area Network: \(connectedDevices.count)")
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedDevices.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        let device = connectedDevices[indexPath.row]
        
        cell.address.text = device[DEVICE_IP_ADDRESS]
        cell.name.text = device[DEVICE_NAME]
        cell.mac.text = device[DEVICE_MAC]
        cell.brand.text = device[DEVICE_BRAND]
        cell.misc.text = ""
        
        return cell
    }
}

extension UIViewController {
    func presentAlert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true)
    }
}

extension UITableView {
    func reloadData(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

