@isTest
public with sharing class CreateWarrantyRecordsTest {

    //static 변수로 Record Type ID 변수 생성
    static Id engineRecordTypeId;
    static Id bodyRecordTypeId;
    static Id otherPartsRecordTypeId;

    @TestSetup
    static void setupData(){
        //Product 데이터 생성 (모델: G70, G80, G90)
        Product2 productG70 = new Product2(Name = 'Genesis G70', Model__c = 'G70');
        Product2 productG80 = new Product2(Name = 'Genesis G80', Model__c = 'G80');
        Product2 productG90 = new Product2(Name = 'Genesis G90', Model__c = 'G90');
        insert new List<Product2>{ productG70, productG80, productG90 };

        //Account, Contact 데이터 생성
        Account account = new Account(Name = 'Private'); 
        insert account; 
        Contact contact = new Contact(LastName = 'Han', FirstName = 'A Eun', AccountId = account.Id); 
        insert contact;

        //Record Type Id 불러오기
        engineRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Warranty__c' AND Name = 'Engine' LIMIT 1].Id;
        bodyRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Warranty__c' AND Name = 'Body' LIMIT 1].Id;
        otherPartsRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Warranty__c' AND Name = 'Other Parts' LIMIT 1].Id;
    }
    
    @isTest
    static void testCreateWarrantyG70() {
        //G70의 Product레코드 가져와서 Asset생성
        Product2 productG70 = [SELECT Id FROM Product2 WHERE Model__c = 'G70' LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE Name = 'Private' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Han' LIMIT 1];

        Asset assetG70 = new Asset(
            Product2Id = productG70.Id,
            AccountId = account.Id, 
            ContactId = contact.Id,
            PurchaseDate = Date.today(),
            Name = 'G70 Asset'
        );
        insert assetG70;
        
        //G70 Warranty 레코드가 Engine, Body 총 2개 생성됐는지 확인
        List<Warranty__c> warranties = [SELECT RecordTypeId, Start_Date__c, End_Date__c, Name FROM Warranty__c WHERE Asset__c = :assetG70.Id];
        System.assertEquals(2, warranties.size(), 'G70의 Warranty 레코드는 Engine, Body 총 2개여야 합니다.');

        //Engine(3년), Body(2년) 보증 기간 확인
        for (Warranty__c warranty : warranties) {
            if (warranty.RecordTypeId == engineRecordTypeId) {
                System.assertEquals(warranty.Start_Date__c.addYears(3), warranty.End_Date__c, 'G70 Engine Warranty 종료일이 올바르지 않습니다.');
            } else if (warranty.RecordTypeId == bodyRecordTypeId) {
                System.assertEquals(warranty.Start_Date__c.addYears(2), warranty.End_Date__c, 'G70 Body Warranty 종료일이 올바르지 않습니다.');
            }
        }
    }

    @isTest
    static void testCreateWarrantyG80() {
        //G80의 Product레코드 가져와서 Asset생성
        Product2 productG80 = [SELECT Id FROM Product2 WHERE Model__c = 'G80' LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE Name = 'Private' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Han' LIMIT 1];

        Asset assetG80 = new Asset(
            Product2Id = productG80.Id,
            AccountId = account.Id, 
            ContactId = contact.Id,
            PurchaseDate = Date.today(),
            Name = 'G80 Asset'
        );
        insert assetG80;
        
        //G80 Warranty 레코드가 Engine, Body 총 2개 생성됐는지 확인
        List<Warranty__c> warranties = [SELECT RecordTypeId, Start_Date__c, End_Date__c, Name FROM Warranty__c WHERE Asset__c = :assetG80.Id];
        System.assertEquals(2, warranties.size(), 'G80의 Warranty 레코드는 Engine, Body 총 2개여야 합니다.');

        //Engine(4년), Body(5년) 보증 기간 확인
        for (Warranty__c warranty : warranties) {
            if (warranty.RecordTypeId == engineRecordTypeId) {
                System.assertEquals(warranty.Start_Date__c.addYears(4), warranty.End_Date__c, 'G80 Engine Warranty 종료일이 올바르지 않습니다.');
            } else if (warranty.RecordTypeId == bodyRecordTypeId) {
                System.assertEquals(warranty.Start_Date__c.addYears(5), warranty.End_Date__c, 'G80 Body Warranty 종료일이 올바르지 않습니다.');
            }
        }
    }

    @isTest
    static void testCreateWarrantyG90() {
        //G90의 Product레코드 가져와서 Asset생성
        Product2 productG90 = [SELECT Id FROM Product2 WHERE Model__c = 'G90' LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE Name = 'Private' LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Han' LIMIT 1];

        Asset assetG90 = new Asset(
            Product2Id = productG90.Id,
            AccountId = account.Id, 
            ContactId = contact.Id,
            PurchaseDate = Date.today(),
            Name = 'G90 Asset'
        );
        insert assetG90;
        
        //G90 Warranty 레코드가 Engine, Body, Other Parts 총 3개 생성됐는지 확인
        List<Warranty__c> warranties = [SELECT RecordTypeId, Start_Date__c, End_Date__c, Name FROM Warranty__c WHERE Asset__c = :assetG90.Id];
        System.assertEquals(3, warranties.size(), 'G90의 Warranty 레코드는 Engine, Body, Other Parts 총 3개여야 합니다.');

        //Engine(10년), Body(7년), Other Parts(3년) 보증 기간 확인
        for (Warranty__c warranty : warranties) {
            if (warranty.RecordTypeId == engineRecordTypeId) {
                System.assertEquals(warranty.Start_Date__c.addYears(10), warranty.End_Date__c, 'G90 Engine Warranty 종료일이 올바르지 않습니다.');
            } else if (warranty.RecordTypeId == bodyRecordTypeId) {
                System.assertEquals(warranty.Start_Date__c.addYears(7), warranty.End_Date__c, 'G90 Body Warranty 종료일이 올바르지 않습니다.');
            } else if (warranty.RecordTypeId == otherPartsRecordTypeId) {
                System.assertEquals(warranty.Start_Date__c.addYears(3), warranty.End_Date__c, 'G90 Body Warranty 종료일이 올바르지 않습니다.');
            }
        }
    }
}