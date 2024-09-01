/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 09-02-2024
 * @last modified by  : Hanyeong Choi
**/
@isTest
public with sharing class SignatureContainerController_Test {
    public class MockDML implements SignatureContainerController.DMLInterface {
        public void insertContentVersion(ContentVersion cv) {
            cv.Id = '068000000000000AAA';
            System.debug('Mock insert executed for ContentVersion: ' + cv);
        }

        public void insertContentDocumentLink(ContentDocumentLink cdl) {
            System.debug('Mock insert executed for ContentDocumentLink: ' + cdl);
        }
    }

    // 예외를 발생시키는 모킹된 DML 인터페이스 구현
    public class MockDML_Exception extends Exception implements SignatureContainerController.DMLInterface {
        public void insertContentVersion(ContentVersion cv) {
            throw new DmlException('Mock DML Exception for ContentVersion');
        }

        public void insertContentDocumentLink(ContentDocumentLink cdl) {
            throw new DmlException('Mock DML Exception for ContentDocumentLink');
        }
    }

    @isTest
    static void saveSignatureNew_Test() {
        String signatureBody = 'test';
        Id parentId = '001000000000000AAA'; // 가짜 Parent ID

        SignatureContainerController.DMLInterface mockDML = new MockDML();

        Test.startTest();
        SignatureContainerController.saveSignatureNewWithDML(signatureBody, parentId, mockDML);
        Test.stopTest();
    }

    @isTest
    static void saveSignatureNew_Exception_Test() {
        String signatureBody = 'testSignatureBody';
        Id parentId = '001000000000000AAA'; // 가짜 Parent ID

        // 예외 발생 테스트용 모킹된 DML 객체 생성
        SignatureContainerController.DMLInterface mockDML = new MockDML_Exception();

        Test.startTest();
        SignatureContainerController.saveSignatureNewWithDML(signatureBody, parentId, mockDML);
        Test.stopTest();
    }

    @isTest
    static void deleteSign_Test() {
        // 테스트용 ContentVersion 생성
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'Test.png',
            VersionData = Blob.valueOf('Test data'),
            ContentLocation = 'S',
            Origin = 'H'
        );
        insert cv;

        // ContentDocumentId 가져오기
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        // 테스트 메서드 실행
        Test.startTest();
        SignatureContainerController.deleteSign(contentDocumentId);
        Test.stopTest();
    }

    @isTest
    static void getSignature_Test() {
        // 테스트용 계정 및 관련된 ContentDocument와 ContentDocumentLink 생성
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        ContentVersion cv = new ContentVersion(
            Title = 'Test Signature',
            PathOnClient = 'Test.png',
            VersionData = Blob.valueOf('Test data'),
            ContentLocation = 'S',
            Origin = 'H'
        );
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
            LinkedEntityId = acc.Id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // 테스트 메서드 실행
        Test.startTest();
        SignatureContainerController.getSignature(acc.Id);
        Test.stopTest();
    }
}