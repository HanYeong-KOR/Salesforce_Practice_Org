/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 01-04-2024
 * @last modified by  : Hanyeong Choi
**/
trigger opportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete) {
    TriggerManager.prepare()
    .bind(new OpportunityTriggerController())
    .execute();
}