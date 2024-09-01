/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 06-11-2024
 * @last modified by  : Hanyeong Choi
**/
public without sharing class SignatureContainerController {
    
    @AuraEnabled
    public static boolean saveSignatureNew(String signatureBody, id parentId) {
        return saveSignatureNewWithDML(signatureBody, parentId, new RealDML());
    }

    @TestVisible
    static Boolean saveSignatureNewWithDML(String signatureBody, id parentId, DMLInterface dmlInterface) {
        try {
            // Create Salesforce File
            // Insert ContentVersion
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; // S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = 'Signature-'+System.now() +'.png';//File name with extention
            cVersion.Origin = 'H';// C-Content Origin. H-Chatter Origin.
            // cVersion.OwnerId = attach.OwnerId; // Owner of the file
            String Title = 'Signature-' + System.now();
            cVersion.Title = Title + '.png';// Name of the file
            cVersion.VersionData = EncodingUtil.base64Decode(signatureBody); // File content
            dmlInterface.insertContentVersion(cVersion);
            
            // After saved the Content Verison, get the ContentDocumentId
            Id conDocument;
            if(!Test.isRunningTest()) {
                conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            } else {
                conDocument = '069000000000000AAA';
            }
            
            // Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument; // Add ContentDocumentId
            cDocLink.LinkedEntityId = parentId; // Add attachment parentId
            cDocLink.ShareType = 'I'; // V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers'; // AllUsers, InternalUsers, SharedUsers
            dmlInterface.insertContentDocumentLink(cDocLink);
            
            return true;
        } catch (Exception e) {
            System.debug('[' + e.getLineNumber() + '] ' + e.getMessage());
            return false;
        }
    }
    
    @AuraEnabled
    public static String deleteSign(String documentId) {
        String result = '';
        
        try {
            Long startingTime = System.now().getTime(); 
            Integer delayInMilliseconds = 3000; 
            while (System.now().getTime() - startingTime < delayInMilliseconds) {}
            
            if (documentId != null) {
                List<ContentDocument> cd = [SELECT id FROM ContentDocument WHERE Id = :documentId];
                if (cd.size() == 0) result = 'ERROR :: ContentDocument가 없음 ';
                if (cd.size() > 0) { delete cd[0]; result = 'SUCCESS'; } 
            } else {
                result = 'ERROR';
            }

            return result;
        } catch (exception e) {
            return 'ERROR_MSG :: ' + '[' + e.getLineNumber() + '] ' + e.getMessage();
        }
    }
    
    @auraEnabled
    public static String getSignature(String recordId){
        Set<String> docSet = new Set<String>();
        Map<String, ContentDocumentLink> cdlMap = new Map<String, ContentDocumentLink>();
        String LastestVersionId;
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();

        cdlList = [SELECT id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, SystemModstamp FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        
        List<ContentDocumentLink> SignList = new List<ContentDocumentLink>();
        if(cdlList.size() > 0) { 
            for(ContentDocumentLink cdlSingle : cdlList) {
                docSet.add(cdlSingle.ContentDocumentId);
                cdlMap.put(cdlSingle.ContentDocumentId, cdlSingle);
            }
            Set<String> customerIds = new Set<String>();
            List<ContentDocument> cdList = new List<ContentDocument>();
            cdList = [SELECT Id,Title FROM ContentDocument WHERE Id IN :docSet];
            for(ContentDocument cd : cdList) {
                customerIds.add(cd.Id);
            }

            for(String ids : customerIds) {
                if(cdlMap.get(ids) != null) {
                    SignList.add(cdlMap.get(ids));
                }
            }
        }
        
        String strSign;
        if(SignList.size() > 1) { 
            Datetime LastestCreatedDate;
            for(ContentDocumentLink cdl : SignList) {
                if(LastestCreatedDate == null || cdl.SystemModstamp > LastestCreatedDate) {
                    LastestCreatedDate = cdl.SystemModstamp;
                    LastestVersionId = cdl.ContentDocument.LatestPublishedVersionId;
                }
            }    
        } else if(SignList.size() == 1){
            LastestVersionId = SignList[0].ContentDocument.LatestPublishedVersionId;
        } else {
            LastestVersionId = '';
        }
        if(SignList.size() > 0) { 
            strSign = '/sfc/servlet.shepherd/version/download/'+LastestVersionId;
        } else {
            strSign = '';
        }

        System.debug('strSign ::: ' + strSign);
        return strSign;

    }

    // DML 인터페이스
    public interface DMLInterface {
        void insertContentVersion(ContentVersion cv);
        void insertContentDocumentLink(ContentDocumentLink cdl);
    }

    // 실제 DML 작업 클래스
    public class RealDML implements DMLInterface {
        public void insertContentVersion(ContentVersion cv) {
            insert cv;
        }

        public void insertContentDocumentLink(ContentDocumentLink cdl) {
            insert cdl;
        }
    }
}