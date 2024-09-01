/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 06-10-2024
 * @last modified by  : Hanyeong Choi
**/
public with sharing class LookupController {
    public static final Map<String, String> classicIconToLightning = settingIconMap();
    public static final List<String> objectManagerList = settingObjectManagerList();

    @AuraEnabled
    public static List<ObjectInfoWrapper> obtainObjectList(String searchKeyWord) {
        try {
            List<ObjectInfoWrapper> obtainList = new List<ObjectInfoWrapper>();
    
            List<Schema.DescribeTabResult> trList;
    
            for (Schema.DescribeTabSetResult tsr : Schema.describeTabs()) {
                if (tsr.getLabel() == getAppName()) {
                    trList = tsr.getTabs();
                    break;
                }
            }
    
            for (Schema.SObjectType objType : Schema.getGlobalDescribe().values()) {
                if (obtainList.size() > 4) break;
    
                Schema.DescribeSObjectResult dsr = objType.getDescribe();
    
                if (dsr.getLabel().toLowerCase().startsWith(searchKeyWord.toLowerCase())) {
                    String getName = dsr.getName();
                    if (objectManagerList.contains(getName) || getName.contains('__c')) {
                        obtainList.add(getInfo(objType + '', classicIconToLightning, trList, dsr));
                    }
                }
            }
    
            List<ObjectInfoWrapper> matchCase = new List<ObjectInfoWrapper>();
            for (ObjectInfoWrapper info : obtainList) {
                if (searchKeyWord == info.objectLabel) {
                    matchCase.add(info);
                }
            }
    
            if (!matchCase.isEmpty()) {
                return matchCase;
            }
    
            return obtainList;

        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<RecordInfoWrapper> obtainRecordList(String searchKeyWord, Integer pageNumber, Integer pageSize) {
        try {
            List<RecordInfoWrapper> obtainList = new List<RecordInfoWrapper>();
            Integer offsetSize = (pageNumber - 1) * pageSize;

            List<Account> accountList = [
                SELECT Id, Name , Phone, FM_Address__c
                FROM Account 
                WHERE Name LIKE :('%' + searchKeyWord + '%')
                ORDER BY CreatedDate DESC
                LIMIT :pageSize OFFSET :offsetSize
            ];
            
            for (Account acc : accountList) {
                obtainList.add(new RecordInfoWrapper(acc.Id, acc.Name, acc.Phone, acc.FM_Address__c));
            }

            return obtainList;

        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<FieldInfoWrapper> getFieldInfo(String objectAPI) {
        List<FieldInfoWrapper> result = new List<FieldInfoWrapper>();

        try {
            Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectAPI).getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        
            for (Schema.SObjectField field : fieldsMap.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

                if (isSpecialField(fieldDescribe)) {
                    continue;
                }

                FieldInfoWrapper fieldInfo = new FieldInfoWrapper();
                fieldInfo.fieldLabel = fieldDescribe.getLabel();
                fieldInfo.fieldName = fieldDescribe.getName();
                fieldInfo.fieldType = fieldDescribe.getType().name();
                
                result.add(fieldInfo);
                
            }
            
            return result;

        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Boolean isSpecialField(Schema.DescribeFieldResult fieldDescribe) {
        Schema.DisplayType fieldType = fieldDescribe.getType();
        return  fieldType == Schema.DisplayType.REFERENCE || 
                fieldType == Schema.DisplayType.ANYTYPE ||
                fieldType == Schema.DisplayType.DATACATEGORYGROUPREFERENCE ||
                fieldType == Schema.DisplayType.ID ||
                fieldType == Schema.DisplayType.DATETIME;
    }


    public static Map<String, String> settingIconMap(){
        Map<String, String> classicIconToLighting = new Map<String, String>();
        try {
            classicIconToLighting.put('plane32.png',         'custom20');
            classicIconToLighting.put('books32.png',         'custom55');
            classicIconToLighting.put('can32.png',           'custom59');
            classicIconToLighting.put('circle32.png',        'custom12');
            classicIconToLighting.put('dice32.png',          'custom66');
            classicIconToLighting.put('hammer32.png',        'custom44');
            classicIconToLighting.put('hotairBalloon32.png', 'custom74');
            classicIconToLighting.put('padlock32.png',       'custom77');
            classicIconToLighting.put('pda32.png',           'custom29');
            classicIconToLighting.put('redcross32.png',      'custom86');
            classicIconToLighting.put('shoppingCart32.png',  'custom93');
            classicIconToLighting.put('telescope32.png',     'custom39');
            classicIconToLighting.put('tvWidescreen32.png',  'custom100');
            classicIconToLighting.put('alarmClock32.png',    'custom25');
            classicIconToLighting.put('bottle32.png',        'custom56');
            classicIconToLighting.put('car32.png',           'custom31');
            classicIconToLighting.put('compass32.png',       'custom64');
            classicIconToLighting.put('factory32.png',       'custom32');
            classicIconToLighting.put('hands32.png',         'custom14');
            classicIconToLighting.put('insect32.png',        'custom34');
            classicIconToLighting.put('mail32.png',          'custom23');
            classicIconToLighting.put('pencil32.png',        'custom83');
            classicIconToLighting.put('sack32.png',          'custom17');
            classicIconToLighting.put('square32.png',        'custom7');
            classicIconToLighting.put('thermometer32.png',   'custom97');
            classicIconToLighting.put('umbrella32.png',      'custom60');
            classicIconToLighting.put('apple32.png',         'custom51');
            classicIconToLighting.put('box32.png',           'custom13');
            classicIconToLighting.put('castle32.png',        'custom61');
            classicIconToLighting.put('computer32.png',      'custom21');
            classicIconToLighting.put('fan32.png',           'custom2');
            classicIconToLighting.put('handsaw32.png',       'custom70');
            classicIconToLighting.put('ipPhone32.png',       'custom75');
            classicIconToLighting.put('map32.png',           'custom78');
            classicIconToLighting.put('people32.png',        'custom15');
            classicIconToLighting.put('safe32.png',          'custom87');
            classicIconToLighting.put('cash32.png',          'custom41');
            classicIconToLighting.put('ticket32.png',        'custom45');
            classicIconToLighting.put('whistle32.png',       'custom82');
            classicIconToLighting.put('balls32.png',         'custom52');
            classicIconToLighting.put('bridge32.png',        'custom37');
            classicIconToLighting.put('cd32.png',            'custom49');
            classicIconToLighting.put('creditCard32.png',    'custom40');
            classicIconToLighting.put('flag32.png',          'custom26');
            classicIconToLighting.put('headset32.png',       'custom71');
            classicIconToLighting.put('jewel32.png',         'custom43');
            classicIconToLighting.put('measuringTape32.png', 'custom79');
            classicIconToLighting.put('phone32.png',         'custom22');
            classicIconToLighting.put('sailboat32.png',      'custom88');
            classicIconToLighting.put('star32.png',          'custom11');
            classicIconToLighting.put('train32.png',         'custom36');
            classicIconToLighting.put('wrench32.png',        'custom19');
            classicIconToLighting.put('bank32.png',          'custom16');
            classicIconToLighting.put('building32.png',      'custom24');
            classicIconToLighting.put('cellPhone32.png',     'custom28');
            classicIconToLighting.put('tvCTR32.png',         'custom99');
            classicIconToLighting.put('form32.png',          'custom18');
            classicIconToLighting.put('heart32.png',         'custom1');
            classicIconToLighting.put('keys32.png',          'custom76');
            classicIconToLighting.put('microphone32.png',    'custom35');
            classicIconToLighting.put('stamp32.png',         'custom46');
            classicIconToLighting.put('saxophone32.png',     'custom89');
            classicIconToLighting.put('stethoscope32.png',   'custom94');
            classicIconToLighting.put('chest32.png',         'custom42');
            classicIconToLighting.put('bell32.png',          'custom53');
            classicIconToLighting.put('buildingBlock32.png', 'custom57');
            classicIconToLighting.put('chalkboard32.png',    'custom18');
            classicIconToLighting.put('cup32.png',           'custom65');
            classicIconToLighting.put('gears32.png',         'custom67');
            classicIconToLighting.put('helicopter32.png',    'custom72');
            classicIconToLighting.put('laptop32.png',        'custom27');
            classicIconToLighting.put('moon32.png',          'custom10');
            classicIconToLighting.put('presenter32.png',     'custom84');
            classicIconToLighting.put('scales32.png',        'custom90');
            classicIconToLighting.put('stopwatch32.png',     'custom95');
            classicIconToLighting.put('triangle32.png',      'custom6');
            classicIconToLighting.put('bigtop32.png',        'custom50');
            classicIconToLighting.put('boat32.png',          'custom54');
            classicIconToLighting.put('caduceus32.png',      'custom58');
            classicIconToLighting.put('camera32.png',        'custom38');
            classicIconToLighting.put('knight32.png',        'custom47');
            classicIconToLighting.put('chip32.png',          'custom63');
            classicIconToLighting.put('desk32.png',          'custom33');
            classicIconToLighting.put('diamond32.png',       'custom8');
            classicIconToLighting.put('globe32.png',         'custom68');
            classicIconToLighting.put('guitar32.png',        'custom69');
            classicIconToLighting.put('hexagon32.png',       'custom4');
            classicIconToLighting.put('highwaySign32.png',   'custom73');
            classicIconToLighting.put('leaf32.png',          'custom5');
            classicIconToLighting.put('lightning32.png',     'custom9');
            classicIconToLighting.put('motorcycle32.png',    'custom80');
            classicIconToLighting.put('musicalNote32.png',   'custom81');
            classicIconToLighting.put('radarDish32.png',     'custom30');
            classicIconToLighting.put('realEstateSign32.png', 'custom85');
            classicIconToLighting.put('shield32.png',        'custom91');
            classicIconToLighting.put('ship32.png',          'custom92');
            classicIconToLighting.put('streetSign32.png',    'custom96');
            classicIconToLighting.put('sun32.png',           'custom3');
            classicIconToLighting.put('trophy32.png',        'custom48');
            classicIconToLighting.put('truck32.png',         'custom98');
            classicIconToLighting.put('plane32.png',         'custom20');
    
            return classicIconToLighting;
            
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<String> settingObjectManagerList(){
        List<String> objectManagerList = new List<String>();

        try {
            objectManagerList.add('Contract');
            objectManagerList.add('Order');
            objectManagerList.add('OrderItem');
            objectManagerList.add('Campaign');
            objectManagerList.add('CampaignMember');
            objectManagerList.add('Account');
            objectManagerList.add('Contact');
            objectManagerList.add('Lead');
            objectManagerList.add('Opportunity');
            objectManagerList.add('OpportunityContactRole');
            objectManagerList.add('OpportunityLineItem');
            objectManagerList.add('Period');
            objectManagerList.add('PricebookEntry');
            objectManagerList.add('Product2');
            objectManagerList.add('Asset');
            objectManagerList.add('Case');
            objectManagerList.add('Holiday');
            objectManagerList.add('ContentVersion');
            objectManagerList.add('Report');
            objectManagerList.add('Group');
            objectManagerList.add('GroupMember');
            objectManagerList.add('Task');
            objectManagerList.add('Event');
            objectManagerList.add('Topic');
            objectManagerList.add('User');
            objectManagerList.add('EmailMessage');
            objectManagerList.add('VoiceCall');
            objectManagerList.add('Individual');
            objectManagerList.add('Participant');
            objectManagerList.add('Pricebook2');
            objectManagerList.add('Macro');
            objectManagerList.add('WorkOrder');
            objectManagerList.add('WorkOrderLineItem');
            objectManagerList.add('ServiceAppointment');
            objectManagerList.add('WorkType');
            objectManagerList.add('ServiceResource');
            objectManagerList.add('ServiceTerritory');
            objectManagerList.add('ServiceTerritoryMember');
            objectManagerList.add('ServiceResourceSkill');
            objectManagerList.add('SkillRequirement');
            objectManagerList.add('AssignedResource');
            objectManagerList.add('OperatingHours');
            objectManagerList.add('ResourceAbsence');
            objectManagerList.add('TimeSlot');
            objectManagerList.add('ResourcePreference');
            objectManagerList.add('Entitlement');
            objectManagerList.add('EntitlementContact');
            objectManagerList.add('EntityMilestone');
            objectManagerList.add('ServiceContract');
            objectManagerList.add('ContractLineItem');
            objectManagerList.add('Location');
            objectManagerList.add('AssociatedLocation');
            objectManagerList.add('DandBCompany');
            objectManagerList.add('Skill');
            objectManagerList.add('QuickText');
            objectManagerList.add('UserProvisioningRequest');
            objectManagerList.add('DuplicateRecordSet');
            objectManagerList.add('DuplicateRecordItem');
            objectManagerList.add('AssetRelationship');
            objectManagerList.add('MessagingEndUser');
            objectManagerList.add('ListEmail');
            objectManagerList.add('ScorecardMetric');
            objectManagerList.add('Scorecard');
            objectManagerList.add('MessagingSession');
            objectManagerList.add('ReturnOrder');
            objectManagerList.add('ScorecardAssociation');
            objectManagerList.add('ReturnOrderLineItem');
            objectManagerList.add('ContactRequest');
            objectManagerList.add('ContactPointEmail');
            objectManagerList.add('ContactPointPhone');
            objectManagerList.add('WorkTypeGroup');
            objectManagerList.add('ConsumptionSchedule');
            objectManagerList.add('ConsumptionRate');
            objectManagerList.add('ProductConsumptionSchedule');
            objectManagerList.add('ServiceTerritoryWorkType');
            objectManagerList.add('CardPaymentMethod');
            objectManagerList.add('ContactPointAddress');
            objectManagerList.add('ContactPointConsent');
            objectManagerList.add('ContactPointTypeConsent');
            objectManagerList.add('DataUseLegalBasis');
            objectManagerList.add('DataUsePurpose');
            objectManagerList.add('Image');
            objectManagerList.add('PaymentAuthorization');
            objectManagerList.add('PaymentGroup');
            objectManagerList.add('Recommendation');
            objectManagerList.add('SalesStore');
            objectManagerList.add('WebStore');
            objectManagerList.add('WorkTypeGroupMember');
            objectManagerList.add('AuthorizationForm');
            objectManagerList.add('AuthorizationFormConsent');
            objectManagerList.add('AuthorizationFormDataUse');
            objectManagerList.add('AuthorizationFormText');
            objectManagerList.add('CartDeliveryGroup');
            objectManagerList.add('CartItem');
            objectManagerList.add('Invoice');
            objectManagerList.add('InvoiceLine');
            objectManagerList.add('Payment');
            objectManagerList.add('PaymentGateway');
            objectManagerList.add('PaymentLineInvoice');
            objectManagerList.add('PaymentMethod');
            objectManagerList.add('Promotion');
            objectManagerList.add('Refund');
            objectManagerList.add('Shift');
            objectManagerList.add('WebCart');
            objectManagerList.add('AssetStatePeriod');
            objectManagerList.add('CreditMemo');
            objectManagerList.add('CreditMemoLine');
            objectManagerList.add('RefundLinePayment');
            objectManagerList.add('AssetAction');
            objectManagerList.add('AssetActionSource');
            objectManagerList.add('CartTax');
            objectManagerList.add('CommSubscription');
            objectManagerList.add('CommSubscriptionChannelType');
            objectManagerList.add('CommSubscriptionConsent');
            objectManagerList.add('CommSubscriptionTiming');
            objectManagerList.add('CredentialStuffingEvent');
            objectManagerList.add('CredentialStuffingEventStore');
            objectManagerList.add('CreditMemoInvApplication');
            objectManagerList.add('DigitalWallet');
            objectManagerList.add('EngagementChannelType');
            objectManagerList.add('FinanceBalanceSnapshot');
            objectManagerList.add('FinanceTransaction');
            objectManagerList.add('LegalEntity');
            objectManagerList.add('PartyConsent');
            objectManagerList.add('ReportAnomalyEvent');
            objectManagerList.add('ReportAnomalyEventStore');
            objectManagerList.add('SessionHijackingEvent');
            objectManagerList.add('SessionHijackingEventStore');
            objectManagerList.add('WorkPlan');
            objectManagerList.add('WorkPlanTemplate');
            objectManagerList.add('WorkPlanTemplateEntry');
            objectManagerList.add('WorkStep');
            objectManagerList.add('WorkStepTemplate');
            objectManagerList.add('ApiAnomalyEvent');
            objectManagerList.add('ApiAnomalyEventStore');
            objectManagerList.add('LocationGroup');
            objectManagerList.add('LocationGroupAssignment');
            objectManagerList.add('OperatingHoursHoliday');
            objectManagerList.add('ProcessException');
            objectManagerList.add('ProductAttribute');
            objectManagerList.add('ProductAttributeSet');
            objectManagerList.add('ProductAttributeSetProduct');
            objectManagerList.add('ReturnOrderItemAdjustment');
            objectManagerList.add('ReturnOrderItemTax');
            objectManagerList.add('AlternativePaymentMethod');
            objectManagerList.add('Coupon');
            objectManagerList.add('PaymentAuthAdjustment');
            objectManagerList.add('PromotionMarketSegment');
            objectManagerList.add('PromotionQualifier');
            objectManagerList.add('PromotionSegment');
            objectManagerList.add('PromotionSegmentSalesStore');
            objectManagerList.add('PromotionTarget');
            objectManagerList.add('AppointmentTopicTimeSlot');
            objectManagerList.add('CartItemPriceAdjustment');
            objectManagerList.add('WebCartAdjustmentGroup');
            objectManagerList.add('BusinessBrand');
            objectManagerList.add('CaseRelatedIssue');
            objectManagerList.add('ChangeRequest');
            objectManagerList.add('ChangeRequestRelatedIssue');
            objectManagerList.add('Customer');
            objectManagerList.add('Incident');
            objectManagerList.add('Problem');
            objectManagerList.add('ProblemIncident');
            objectManagerList.add('Seller');
            objectManagerList.add('ChangeRequestRelatedItem');
            objectManagerList.add('IncidentRelatedItem');
            objectManagerList.add('ProblemRelatedItem');
            objectManagerList.add('WebCartAdjustmentBasis');
            objectManagerList.add('AppointmentInvitation');
            objectManagerList.add('AppointmentInvitee');
            objectManagerList.add('EngagementChannelWorkType');
            objectManagerList.add('ShiftEngagementChannel');
            objectManagerList.add('ShiftWorkTopic');
            objectManagerList.add('PromotionTier');
            objectManagerList.add('AppointmentCategory');
            objectManagerList.add('Waitlist');
            objectManagerList.add('WaitlistParticipant');
            objectManagerList.add('WaitlistServiceResource');
            objectManagerList.add('WaitlistWorkType');
            objectManagerList.add('Encryption_Log__c');
            objectManagerList.add('Encryption_Value__c');
            objectManagerList.add('PlayerInfo__c');
    
    
            return objectManagerList;
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String getAppName() {
        try {
            UserAppInfo userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
            AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DurableId = :userAppInfo.AppDefinitionId LIMIT 1];
            return appDefinition.Label;
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static ObjectInfoWrapper getInfo(String objectType, Map<String, String> classicIconToLighting, List<Schema.DescribeTabResult> trList, Schema.DescribeSObjectResult objectDescribeResult) {
        ObjectInfoWrapper info = new ObjectInfoWrapper();
        
        try {
            
            info.objectName = objectDescribeResult.getName();
            info.objectLabel = objectDescribeResult.getLabel();
            info.objectPluralLabel = objectDescribeResult.getLabelPlural();
            info.iconPath = '';
            
            if (info.objectPluralLabel == 'Users') {
                info.iconPath = 'standard:user';
            } else {
                
                for (Schema.DescribeTabResult tr : trList) {
                    if (tr.getLabel() == info.objectPluralLabel) {
                        if (!tr.isCustom()) {
                            if (objectType.toLowerCase() == 'product2') {
                                info.iconPath = 'standard:product'; 
                            } else if (objectType.toLowerCase() == 'order' || objectType.toLowerCase() == 'orderitem') {
                                info.iconPath = 'standard:orders'; 
                            } else {
                                info.iconPath = 'standard:'+ objectType.toLowerCase(); 
                            }
                        }else{
                            List<Schema.DescribeIconResult> iconDesc = tr.getIcons();
                            info.iconPath = 'custom:' + classicIconToLighting.get(iconDesc[0].getUrl().substringAfterLast('/'));
                        }
                            
                        break;
                    }
                }

                if (info.iconPath == '' || info.iconPath == 'custom:') {
                    info.iconPath = 'standard:settings';
                }

            }
        } catch (Exception e) {
            System.debug('Error : '       + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            
            throw new AuraHandledException(e.getMessage());
        }
        
        return info;
    }

    public class ObjectInfoWrapper {
        @AuraEnabled public String objectLabel          { get; set; }
        @AuraEnabled public String objectName           { get; set; }
        @AuraEnabled public String objectPluralLabel    { get; set; }
        @AuraEnabled public String iconPath             { get; set; }
    }

    public class FieldInfoWrapper {
        @AuraEnabled public String fieldLabel   { get; set; }
        @AuraEnabled public String fieldName    { get; set; }
        @AuraEnabled public String fieldType    { get; set; }
    }

    public class RecordInfoWrapper {
        @AuraEnabled public String recordId     { get; set; }
        @AuraEnabled public String recordName   { get; set; }
        @AuraEnabled public String phone        { get; set; }
        @AuraEnabled public String billingAddress   { get; set; }

        public RecordInfoWrapper(String recordId, String recordName, String phone, String billingAddress) {
            this.recordId = recordId;
            this.recordName = recordName;
            this.phone = phone;
            this.billingAddress = billingAddress;
        }
    }
}