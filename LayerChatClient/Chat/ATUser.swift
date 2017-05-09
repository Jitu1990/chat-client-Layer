//
//  ATUser.swift
//  eDuru
//
//  Created by Jitendra Solanki on 4/27/17.
//  Copyright © 2017 Headerlabs. All rights reserved.
//

import UIKit
import Atlas
class ATUser: NSObject,ATLParticipant,ATLAvatarItem{

    var firstName: String = ""
    var lastName: String = ""
    var displayName: String = ""
    
    var participantIdentifier:String = ""
    //var email:String?
    var userID:String = ""
    var avatarPath:URL?
    var avatarImageURL: URL?
    var avatarImage: UIImage?
    var avatarInitials: String?
    
    override init() {
         
    }
    init(participantIdentifier:String,firstName:String,lastName:String,userID:String,avatarPath:String?) {
        
        self.participantIdentifier = participantIdentifier
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = firstName
        self.userID = userID
        
        if avatarPath != nil{
            let fullPath = AppConstant.baseUrl+avatarPath!
            self.avatarImageURL = URL(string: fullPath)
        }
        
        self.avatarInitials = self.firstName.substring(to: self.firstName.startIndex)
    }
    
    class func getUserFor(userID:Int, completion:@escaping (_ success:Bool,_ errorMsg:String?,_ userDetail:[String:Any]?)->Void){
        
        NetworkHandler().makeGateRequest(uri: "/users/\(userID).json") { (response, success) in
            if !success{
                if let msg = response as? String{
                    completion(false,msg,nil)
                    return
                }
                completion(false,"Unable to get user with \(userID)",nil)
                return
            }else{
                
                if let resp = response as? [String:Any]{
                    if let userDetail  = resp["user"] as? [String:Any] {
                        completion(true,nil,userDetail)
                        return
                    }
                completion(false,"Unable to get user with \(userID)",nil)
                return
                }
                completion(false,"Unable to get user with \(userID)",nil)
                return
                
            }
        }
    }
    
    //MARK:- Layer Conversation
    //MARK:- Chat Methods
    /*
    let Chat_Error_Msg = "Unable to start conversation with the owner of this item. Please try later."
    
    func startChatFor(item:Item,with authenticatedFirstUser:LYRIdentity){
        
        ATUser.getUserFor(userID: item.user_id) { (succes, errorMsg, userDict) in
            
            if errorMsg != nil{
                self.showAlertWith(message: errorMsg!, title: "Error", handler: nil)
                return
            }
            
            if userDict != nil{
                guard let name = userDict!["name"]as? String,
                    let avatarPath = userDict!["avatar_path_relative"]as? String,
                    let email = userDict!["email"] as? String,
                    let intID = userDict!["id"] as? Int
                    else{
                        self.showAlertWith(message: "Unable to start conversation with the owner of this item. Please try later.", title: "Error", handler: nil)
                        return
                }
                
                //create a ATLParticipant for the user
                let participant = ATUser(participantIdentifier: email, firstName: name, lastName: "", userID: email, avatarPath: avatarPath)
                //start conversation
                self.startConversationWithParticipant(participant: participant,and: authenticatedFirstUser)
                
            }
        }
        
    }
    
    private func startConversationWithParticipant(participant:ATLParticipant,and authenticatedFirstUser:LYRIdentity){
        
        //store the reference to participant
        User.sharedUser.otherSideParticipant = participant
        let pair:[String] =  [authenticatedFirstUser.userID,participant.userID]
        
        //check if conversation already exists with this participant
        let layerQuery:LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
        layerQuery.predicate = LYRPredicate(property: "participants", predicateOperator: .isEqualTo, value: pair)
        
        User.sharedUser.layerClient.execute(layerQuery) { (conversionSet, error) in
            
            if error != nil{
                self.showAlertWith(message: self.Chat_Error_Msg, title: "Error", handler: nil)
                return
            }else{
                if let setConversion = conversionSet, setConversion.count > 0{
                    
                    //if have previous conversation
                    if let lyrConversation = setConversion.firstObject as?LYRConversation{
                        self.presentChatViewControllerFor(conversation: lyrConversation)
                    }else{
                        //start a new conversation
                        self.startNewConversationWith(pair: pair)
                    }
                    
                }else{
                    //start a new conversation
                    self.startNewConversationWith(pair: pair)
                }
            }
        }
        
        
    }
    
    private func startNewConversationWith(pair:[String]){
        
        if let conversation =  try? User.sharedUser.layerClient.newConversation(withParticipants: Set(pair), options: nil){
            self.presentChatViewControllerFor(conversation: conversation)
        }else{
            self.showAlertWith(message: self.Chat_Error_Msg, title: "Error", handler: nil)
            return
        }
        
    }
    private func presentChatViewControllerFor(conversation:LYRConversation){
        
        let conversationView = ATChatViewController(layerClient: User.sharedUser.layerClient)
        conversationView.conversation = conversation
        conversationView.isPresented = false
        // conversationView.displaysAddressBar = true
        conversationView.shouldDisplayAvatarItemForOneOtherParticipant = true
        // conversationView.displaysAddressBar = true
        self.navigationController?.pushViewController(conversationView, animated: true)
        //     self.present(conversationView, animated: true, completion: nil)
    }
  */
}
