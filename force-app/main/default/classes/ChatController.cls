/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-19-2024
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-16-2024   Hanyeong Choi   Initial Version
**/
public with sharing class ChatController {
    @AuraEnabled
    public static void saveChatMessage(String content, String sender) {
        ChatMessage__c message = new ChatMessage__c(
            Content__c = content,
            Sender__c = sender
        );
        insert message;
    }
}