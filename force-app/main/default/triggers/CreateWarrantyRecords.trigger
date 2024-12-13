trigger CreateWarrantyRecords on Asset (after insert) {

    //저장할 Warranty 레코드를 담을 List 생성
    List<Warranty__c> insertWarranties = new List<Warranty__c>();

    // SOQL 쿼리를 통해 각 RecordType의 Id를 변수에 저장
    Id engineRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Warranty__c' AND Name = 'Engine' LIMIT 1].Id;
    Id bodyRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Warranty__c' AND Name = 'Body' LIMIT 1].Id;
    Id otherPartsRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Warranty__c' AND Name = 'Other Parts' LIMIT 1].Id;

    //Trigger.new를 통해 Asset객체에 대한 반복문 실행
    for (Asset asset : Trigger.new) {
        
        //관련 Product가 존재할 때, 해당 Product의 모델 이름 조회하여 가져오기
        String model = null;
        if(asset.Product2Id != null) {
            Product2 product = [SELECT Model__c FROM Product2 WHERE Id = :asset.Product2Id LIMIT 1];
            model = product.Model__c;
        }
        
        //필수 필드 여부 확인(구매 날짜, 모델명)
        if (asset.PurchaseDate == null || model == null) {
            //해당 필드 누락된 경우 에러 메세지 출력 후 해당 Asset건너뛰기
            System.debug('Error: Asset Id \'' + asset.Id + '\' 구매 날짜, 모델명 누락');
            continue;
        }

         //모델 유형별 부품 보증 년도 변수 생성
         Integer engineWarrantyYears;
         Integer bodyWarrantyYears;
         Integer otherPartsWarrantyYears;

         //모델별 보증 기간 값 변수에 대입
         if (model == 'G70') {
            engineWarrantyYears = 3;
            bodyWarrantyYears = 2;
        } else if (model == 'G80') {
            engineWarrantyYears = 4;
            bodyWarrantyYears = 5;
        } else if (model == 'G90') {
            engineWarrantyYears = 10;
            bodyWarrantyYears = 7;
            otherPartsWarrantyYears = 3;
        } else {
            //모델명이 G70, G80, G90가 아닌 경우 에러 메세지 출력 후 해당 Asset 건너뛰기
            System.debug('Error: Asset Id \'' + asset.Id + '\' 올바르지 않은 모델명');
            continue;
        }

        //보증기간 설정용 날짜 변수
        Date purchaseDate = asset.PurchaseDate;

        //Engine Warranty 레코드 생성
        insertWarranties.add(new Warranty__c(
            Asset__c = asset.Id,
            Name = asset.Id + ' Engine Warranty',
            RecordTypeId = engineRecordTypeId,
            Start_Date__c = purchaseDate,
            End_Date__c = purchaseDate.addYears(engineWarrantyYears)
        ));

        //Body Warranty 레코드 생성
        insertWarranties.add(new Warranty__c(
            Asset__c = asset.Id,
            Name = asset.Id + ' Body Warranty',
            RecordTypeId = bodyRecordTypeId,
            Start_Date__c = purchaseDate,
            End_Date__c = purchaseDate.addYears(bodyWarrantyYears)
        ));
        
        //모델이 G90일 경우에만 기타 부품에 대한 보증기간이 생성됨
        if(model == 'G90') {
            //Other Parts Warranty 레코드 생성
            insertWarranties.add(new Warranty__c(
                Asset__c = asset.Id,
                Name = asset.Id + ' Other Parts Warranty',
                RecordTypeId = otherPartsRecordTypeId,
                Start_Date__c = purchaseDate,
                End_Date__c = purchaseDate.addYears(otherPartsWarrantyYears)
            ));
        }
        //insertWarranties가 빈 List가 아닐 때, insert
        if (!insertWarranties.isEmpty()) {
            try {
                insert insertWarranties;
            } catch (DmlException e) {
                System.debug('Error: Warranty레코드 insert중 에러 발생: ' + e.getMessage());
            }
        }    
    }
}