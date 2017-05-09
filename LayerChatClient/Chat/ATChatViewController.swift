//
//  ATChatViewController.swift
//  eDuru
//
//  Created by Jitendra Solanki on 4/27/17.
//  Copyright © 2017 Headerlabs. All rights reserved.
//

import UIKit
import Atlas

class ATChatViewController: ATLConversationViewController,ATLConversationViewControllerDataSource{

    var isPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        self.navigationController?.navigationBar.barTintColor =  eDuruColor.kBlue.colorFor()
        self.navigationController?.navigationBar.isTranslucent = false
        addLeftNavigationBarItem()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addLeftNavigationBarItem() -> () {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "back_btn_icon.png"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(leftBarButtonAction(sender:)), for: UIControlEvents.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 25, height: 25) //CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
    }
    //left bar button action
    func leftBarButtonAction(sender: UIBarButtonItem) -> () {
        if isPresented{
            self.dismiss(animated: true, completion: nil)
        }else{
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
//============================================================================
//============================================================================
    //MARK:- ATLConversationDataSource
    public func conversationViewController(_ conversationViewController: ATLConversationViewController, participantFor identity: LYRIdentity) -> ATLParticipant{
        
        let defaults = UserDefaults.standard
        //get first participant(authenticated user)
        
        if let name = defaults.object(forKey: AppConstant.KUserName)as? String, let email = defaults.object(forKey: AppConstant.kUserEmail)as? String{
        
            let avatarPath =  defaults.object(forKey: AppConstant.kUserAvatarPath)as? String
            if identity.userID == email {
                return ATUser(participantIdentifier: email, firstName: name, lastName: "", userID: email, avatarPath: avatarPath)
            }
        
        }
        
        //get second participant
        let participant = User.sharedUser.otherSideParticipant
        if participant != nil{
            
            if  participant?.userID == identity.userID{
                return participant!
            }
        }
        
        var userName = ""
        let userid =  identity.userID
        if let name =  userid?.components(separatedBy: "@").first {
            userName = name
        }
        return ATUser(participantIdentifier: identity.userID, firstName: userName, lastName: "", userID: identity.userID, avatarPath: "")
         
     }
    
    public func conversationViewController(_ conversationViewController: ATLConversationViewController, attributedStringForDisplayOf date: Date) -> NSAttributedString{
         return NSAttributedString(string: date.currentTimeZoneDate())
    }
    
    public func conversationViewController(_ conversationViewController: ATLConversationViewController, attributedStringForDisplayOfRecipientStatus recipientStatus: [AnyHashable : Any]) -> NSAttributedString
    {
        return NSAttributedString(string: "")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
