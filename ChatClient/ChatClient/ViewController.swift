//
//  ViewController.swift
//  ChatClient
//
//  Created by Kevin Greer on 5/29/16.
//  Copyright © 2016 KevinGreer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SocketDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var msgTextField: UITextField!
    @IBOutlet weak var joinView: UIView!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [String] = []
    
    var socket: Socket?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = Socket()
        socket!.connect("localhost", port: 80)
        socket!.delegate = self
        view.bringSubviewToFront(joinView)
        msgView.hidden = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func messageReceived(message: String) {
        messages.append(message)
        print(messages)
        tableView.reloadData()
        let topIndexPath = NSIndexPath(forRow: messages.count-1, inSection: 0)
        tableView.scrollToRowAtIndexPath(topIndexPath, atScrollPosition: .Middle, animated: true)
    }
    
    @IBAction func joinChat(sender: UIButton) {
        let response = "iam:\(nameTextField.text!)"
        socket?.sendData(response.dataUsingEncoding(NSUTF8StringEncoding)!)
        view.bringSubviewToFront(msgView)
        joinView.hidden = true
        msgView.hidden = false
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        let response = "msg:\(msgTextField.text!)"
        socket?.sendData(response.dataUsingEncoding(NSUTF8StringEncoding)!)
        msgTextField.text = ""
    }
    
    //MARK: - UITableView
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell")
        let message = messages[indexPath.row]
        cell!.textLabel?.text = message
        return cell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    //MARK: - SocketDelegate
    
    func receivedData(data: NSData) {
        let message = String(data: data, encoding: NSUTF8StringEncoding)
        messageReceived(message!)
    }
}

