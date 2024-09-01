/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 01-12-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class ConvertToContractController {
    @AuraEnabled
    public static String setConvert(String recordId) {
        
        try {
            List<QuoteLineItem> qItemList = [
                SELECT  Id,
                        Product2.Id,
                        Product2.Name,
                        Quote.AccountId
                FROM QuoteLineItem
                WHERE QuoteId = :recordId
            ];

            if(!qItemList.isEmpty()) {
                Contract insertContract     = new Contract();
                insertContract.AccountId    = qItemList[0].Quote.AccountId;
                insertContract.Status       = 'Draft';
                insertContract.StartDate    = System.today();
                insertContract.ContractTerm = 3;

                insert insertContract;

                List<Asset> insertAsset = new List<Asset>();
                for(QuoteLineItem qi : qItemList) {
                    insertAsset.add(new Asset(
                        Name        = qi.Product2.Name,
                        AccountId   = qi.Quote.AccountId,
                        Product2Id  = qi.Product2.Id,
                        Contract__c = insertContract.Id
                    ));
                }

                insert insertAsset;

                return 'SUCCESS';
            }

            return 'FAIL';
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }
}