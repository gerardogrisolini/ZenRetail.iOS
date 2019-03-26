//
//  BonjourController.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 04/06/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import Foundation
import UIKit

struct Device {
    public var name: String
    public var ip: String
}

class BonjourController: UIViewController, NetServiceBrowserDelegate, NetServiceDelegate {
    
    var nsb : NetServiceBrowser!
    var services = [NetService]()
    var devices = [Device]()
    
    @IBOutlet weak var server: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        findInterface()
    }
   
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.stopListening()
    }
    
    fileprivate func stopListening() {
        self.nsb.stop()
        self.nsb.delegate = nil
        self.nsb = nil
        self.services.removeAll()
        print("listening stopped")
    }
    
    @IBAction func refreshClicked (_ sender: Any!) {
        stopListening()
        findInterface()
    }
    
    @IBAction func saveClick(_ sender: UIButton) {
        Synchronizer.shared.registerServer(baseURL: "https://\(server!.text!)/")
        self.navigationController?.popViewController(animated: true)
    }
    
//    @IBAction func inputClicked(_ sender: UIBarButtonItem) {
//        let alertController = UIAlertController(title: "ServerAddress".locale, message: "ServerDomain".locale, preferredStyle: .alert)
//
//        var addressTextField: UITextField?
//        alertController.addTextField { (textField) -> Void in
//            // Enter the textfiled customization code here.
//            addressTextField = textField
//            addressTextField?.placeholder = "EnterAddress".locale
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel".locale, style: .cancel)
//        alertController.addAction(cancelAction)
//
//        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
//            Synchronizer.shared.registerServer(baseURL: "https://\(addressTextField!.text!)/")
//            self.navigationController?.popViewController(animated: true)
//        }
//        alertController.addAction(OKAction)
//
//        self.present(alertController, animated: true, completion:nil)
//    }
    
    func findInterface() {
        print("listening for services...")
        self.nsb = NetServiceBrowser()
        self.nsb.delegate = self
        self.nsb.searchForServices(ofType:"_ssh._tcp", inDomain: "local")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func updateInterface () {
        for service in self.services {
            service.delegate = self
            service.resolve(withTimeout:10)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    // MARK: - NSNetServiceDelegate

    public func netServiceDidResolveAddress(_ sender: NetService) {
        if let addresses = sender.addresses, addresses.count > 0 {
            for address in addresses {
                let data = address as NSData
                let inetAddress: sockaddr_in = data.castToCPointer()
                if inetAddress.sin_family == __uint8_t(AF_INET) {
                    if let ip = String(cString: inet_ntoa(inetAddress.sin_addr), encoding: .ascii) {
                        devices.append(Device(name: sender.hostName!, ip: ip))
                        DispatchQueue.main.async {
                            self.server.text = ip
                        }
                    }
                }
            }
        }
    }

    // MARK: - NSNetServiceBrowserDelegate

    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        self.services.append(service)
        if !moreComing {
            self.updateInterface()
        }
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if let ix = self.services.index(of:service) {
            self.services.remove(at:ix)
            print("removing a service")
            if !moreComing {
                self.updateInterface()
            }
        }
    }
    
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return devices.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath)
//
//        let device = devices[indexPath.row]
//        cell.imageView?.image = UIImage.init(named: "sync")
//        cell.textLabel?.text = device.name
//        cell.detailTextLabel?.text = device.ip
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let device = devices[indexPath.row]
//        let url = "https://\(device.ip)/"
//        Synchronizer.shared.registerServer(baseURL: url)
//
//        navigationController?.popViewController(animated: true)
//    }
}
