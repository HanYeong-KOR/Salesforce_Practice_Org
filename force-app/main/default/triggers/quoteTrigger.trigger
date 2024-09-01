/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 01-12-2024
 * @last modified by  : Hanyeong Choi
**/
trigger quoteTrigger on Quote (before insert, before update, before delete, after insert, after update, after delete) {
    TriggerManager.prepare()
    .bind(new QuoteTriggerController())
    .execute();
}