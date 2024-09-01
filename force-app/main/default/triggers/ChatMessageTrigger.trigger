/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-19-2024
 * @last modified by  : Hanyeong Choi 
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-19-2024   Hanyeong Choi   Initial Version
**/
trigger ChatMessageTrigger on ChatMessage__c (after insert) {
    List<ChatMessageEvent__e> events = new List<ChatMessageEvent__e>();
    
    for (ChatMessage__c msg : Trigger.new) {
        ChatMessageEvent__e event = new ChatMessageEvent__e(
            Content__c = msg.Content__c,
            Sender__c = msg.Sender__c
        );
        events.add(event);
    }
    
    if (!events.isEmpty()) {
        EventBus.publish(events);
    }
}