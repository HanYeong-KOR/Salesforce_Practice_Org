/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 07-03-2024
 * @last modified by  : Hanyeong Choi
**/
@isTest
public with sharing class OpportunityImportController_Test {
    public class MockDML implements OpportunityImportController.DMLInterface {
        public void insertRecords(List<Opportunity> sObjectList) {
            System.debug('Mock insert executed for Opportunity: ' + sObjectList);
            System.debug('Mock insert executed for Opportunity: ' + sObjectList[0]);
            System.debug('Mock insert executed for Opportunity: ' + sObjectList[0].TESTTEST__c);
        }
    }

    @isTest
    static void insertOpportunityWithDML_Test() {
        List<Map<String, Object>> testData = new List<Map<String, Object>>();
        Map<String, Object> row1 = new Map<String, Object>{ 'Name' => 'Test Account 1', 'Amount' => '200' };
        Map<String, Object> row2 = new Map<String, Object>{ 'Name' => 'Test Account 2', 'Amount' => '500' };
        testData.add(row1);
        testData.add(row2);

        OpportunityImportController.DMLInterface mockDML = new MockDML();

        Test.startTest();
        OpportunityImportController.insertOpportunityWithDML(testData, mockDML);
        Test.stopTest();
    }

    @isTest
    static void getOpportunityFields_Test() {
        Test.startTest();
        OpportunityImportController.getOpportunityFields();
        Test.stopTest();
    }
}