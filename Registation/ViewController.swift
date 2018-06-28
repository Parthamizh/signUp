//
//  ViewController.swift
//  Registation
//
//  Created by ev_mac18 on 27/06/18.
//  Copyright © 2018 ev_mac18. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications
import SystemConfiguration
class ViewController: UIViewController,UNUserNotificationCenterDelegate {
    var activeField: UITextField?
    let toolBar = UIToolbar()
    var segmentControl : UISegmentedControl! = nil
    var keyboardRect = CGFloat()
    var saveDetail = NSMutableDictionary()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lBLEmailError: UILabel!
    @IBOutlet weak var lBLPhoneError: UILabel!
    @IBOutlet weak var lBLnameError: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var txTEmail: UITextField!
    @IBOutlet weak var txTPhoneNo: UITextField!
    @IBOutlet weak var txTName: UITextField!
    let center = UNUserNotificationCenter.current()
    override func viewDidLoad() {
        super.viewDidLoad()
  
        // Do any additional setup after loading the view, typically from a nib.
        submitBtn.layer.cornerRadius = submitBtn.frame.size.height / 2
        submitBtn.layer.borderWidth = 0.5
        //submitBtn.layer.backgroundColor = UIColor.blue.cgColor
        //ToolBar
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.white
        toolBar.sizeToFit()
        toolBar.isUserInteractionEnabled = true
        segmentControl = UISegmentedControl(items: ["Previous", "Next"])
        segmentControl.isMomentary = true
        segmentControl.addTarget(self, action: #selector(changeTextField(_sender:)), for:.valueChanged)
        let barItem = UIBarButtonItem(customView: segmentControl)
        let barSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target:nil, action:nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismissKeybord))
        toolBar.setItems([barItem,barSpace,doneButton], animated: false)
        // Keyboard Notifications
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        center.delegate = self
       center.requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            //completionHandler(success)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.currentReachabilityStatus != .notReachable
        {
            print("upload to server")
            // Request Notification Settings
            center.getNotificationSettings { (notificationSettings) in
                switch notificationSettings.authorizationStatus {
                case .notDetermined:
                        self.scheduleLocalNotification()
                case .authorized:
                    self.scheduleLocalNotification()
                case .denied:
                    print("Application Not Allowed to Display Notifications")
                }
            }

        }
    }

    // MARK: - User Default
    @objc func changeTextField(_sender: UISegmentedControl){
        let index = _sender.selectedSegmentIndex
        print(index)
        if (index == 1){
            self.next()
        }else{
            self.previous()
        }
    }
    
    func next(){
        if let nextResponder : UIResponder = activeField?.superview?.viewWithTag((activeField?.tag)! + 1)
        {
            nextResponder.becomeFirstResponder()
        }
        else
        {
            activeField?.resignFirstResponder()
        }
    }
    
    func previous(){
        if let nextResponder : UIResponder = activeField?.superview?.viewWithTag((activeField?.tag)! - 1)
        {
            nextResponder.becomeFirstResponder()
        }
        else
        {
            activeField?.resignFirstResponder()
        }
    }
    
    @objc func dismissKeybord() {
        self.view.endEditing(true)
        toolBar.removeFromSuperview()
        activeField?.resignFirstResponder()
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @IBAction func submitBtnAction(_ sender: Any) {
        
        if validation()
        {
            saveDetail = ["name":txTName.text!, "phoneno":txTPhoneNo.text!, "email":txTEmail.text!] as NSMutableDictionary
        }
    }
    
    func validation()->Bool
    {
        lBLnameError.isHidden = true
        lBLPhoneError.isHidden = true
        lBLEmailError.isHidden = true
        lBLEmailError.isHidden = true
        if txTName.text == ""
        {
            lBLnameError.text = "Enter Name"
            lBLnameError.isHidden = false
            return false
        }
        if txTPhoneNo.text == ""
        {
            lBLPhoneError.text = "Enter Phone number"
            lBLPhoneError.isHidden = false
            return false
        }
        if txTEmail.text == ""
        {
            lBLEmailError.text = "Enter email"
            lBLEmailError.isHidden = false
            return false
        }
        if !self.emailValidate(str: txTEmail.text!)
        {
            lBLEmailError.text = "Enter valid email"
            lBLEmailError.isHidden = false
            return false
        }
        return true
    }
    
    func emailValidate(str:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: str)
        return result
    }
    
    
    func scheduleLocalNotification() {
        // Create Notification Content
        center.removeAllPendingNotificationRequests()
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "Info"
        //notificationContent.subtitle = "Local Notifications"
        notificationContent.body = "synchronizing...."
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
          self.center.add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    // MARK: - Keyboard Notifications
    
    @objc func keyboardWasShown(notification: NSNotification)
    {
        //Need to calculate keyboard exact size
        let userInfo = notification.userInfo!
        keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardRect, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification)
    {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
}

//MARK:- Textfield delegate
extension ViewController: UITextFieldDelegate
{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
      
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        textField.inputAccessoryView = toolBar
        // For previews/next
        if(activeField?.tag == 3){
            segmentControl.setEnabled(true, forSegmentAt: 0)
            
            segmentControl.setEnabled(false, forSegmentAt: 1)
        }
        else if(activeField?.tag == 1){
            segmentControl.setEnabled(true, forSegmentAt: 1)
            
            segmentControl.setEnabled(false, forSegmentAt: 0)
        }
        else
        {
            segmentControl.setEnabled(true, forSegmentAt: 1)
            
            segmentControl.setEnabled(true, forSegmentAt: 0)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newString: NSString!
        lBLPhoneError.isHidden = true
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField.tag == 2{
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            let currentString: NSString = textField.text! as NSString
            newString = currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length > 9{
                lBLPhoneError.text = "Enter Phone number"
                lBLPhoneError.isHidden = false
                return false
            }
            else
            {
                return allowedCharacters.isSuperset(of: characterSet)
            }
        }
        
        return true
    }
}

protocol Utilities {
}
extension NSObject:Utilities{
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }

}
