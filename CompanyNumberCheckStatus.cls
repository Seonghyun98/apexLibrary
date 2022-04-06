/**
 * Created by vit1 on 2022-01-13.
 */

public with sharing class CompanyNumberCheckStatus {
    
    
    //return arrCrn
    //List 형태로 사업자 등록번호를 담음
    public static List<String> makeCRNCode(){
        //도매사
        List<Account> listAccount = [
        SELECT 
        CRN__c 
        FROM Account];

        List<RetailStore> ListRetailStore = [
        SELECT
       	POCrgn__c
        from RetailStore];

        //사업자 등록번호 리스트
            //현재는 테스트용으로 도매사 모든 오브젝트의 
            //사업자 등록번호를 대상으로 select 해서 가져옴
        List<String> arrCrn = new List<String>();
        
        // 사업자 등록번호 1번에 최대 100개
        // String[] stt100 = new String[100];
   
        //==================================================================
        // test 사업자 등록번호 210 개 (지워도됨)
        //list 작성   arrCrn[i]
        // while(i < listAccount.size()){
        //     // arrCrn[i+(n*listAccount.size())] = listAccount[i].CRN__c;
        //     arrCrn.add(String.valueOf(listAccount[i].CRN__c));
        //     i++;
        // }
        for(integer i = 0; i < listAccount.size(); i++){
            arrCrn.add(String.valueOf(listAccount[i].CRN__c));
        }
        for(integer i = 0; i < ListRetailStore.size(); i++){
            arrCrn.add(String.valueOf(ListRetailStore[i].POCrgn__c));
        }
        return arrCrn;
    }
    //========================
    public static void getApiData(List<String> arrCrn){
        //사업자 등록번호 100개씩 보내는 로직

        List<String> stt = new List<String>();

        Integer a = 0;
        
        while(a < arrCrn.size() / 100 + 1){
            Integer b = 0;
            Integer c = 0;
            String crn =''; 
            // 100 개까지 혹은 size - a x 100 일때 (배열이 끝났을때)
            while(b < 100 && b < arrCrn.size() - a * 100){
                crn += '"' + arrCrn[a*100+b] + '"';
                if(b != 99 && b != arrCrn.size() - a * 100 - 1){
                    crn += ',';
                }
                b++;
            }
            List<String> Listcrn = basicAuthCallout(crn);
            
            while(c < 100 && c < arrCrn.size() - a * 100){
                stt.add(String.valueOf(Listcrn[c]));
                c++;
            }
            a++;
        }
        system.debug('==========================================');
        system.debug('사업자 등록번호'+arrCrn.size()+'개  폐업 체크'+stt.size() +'개');
        system.debug('===========================================');
        
        checkCode(arrCrn, stt);
        system.debug(arrCrn);
        system.debug(stt);
    }
    //===========
    @AuraEnabled
    public static void getAccountData(){
        
        List<String> arrCrn = makeCRNCode();
        
        getApiData(arrCrn);    

        
    }
    public static void checkCode(List<String> arrCrn, List<String> stt){
        Integer d = 0;
        while(d < arrCrn.size()){
            String stt_temp = '';
            
            if(stt[d] == '폐업자'){
                List<interface__c> infList  = new List<interface__c>();
                interface__c inf = new interface__c();
                inf.Name = '사업자 등록번호 테스트';
                inf.stt__c = '폐업';
                inf.CRN__c = arrCrn[d];
                infList.add(inf);

                insert infList;
                stt_temp = stt[d];
            }
            else if(stt[d] == null || stt[d] == ''){
                stt_temp =  '잘못된 사업자 등록번호거나 확인이 불가능합니다.';
            }
            else{
                stt_temp = stt[d];
            }
            system.debug('사업자 등록번호 :::::' + arrCrn[d] + ', 폐업 체크 :::::'+ stt_temp);
            d++;
        }
    }

    @AuraEnabled
    public static List<String> basicAuthCallout(String crn){

        Http http = new http();
        HttpRequest req = new HttpRequest();
        // String registrationNumber = '2063034217';
        String details = 'b_no';
        String headerValue = String.valueOf('{"'+ details + '":['+ crn +']}');

        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setEndpoint('http://api.odcloud.kr/api/nts-businessman/v1/status?' +
                'serviceKey=%2Fo5oMl0giYn%2BXNFmKXGWIYjvOKmRgpLDV9Xl7WIKskVyHj6JmXnN6k%2Fz%2FXWkNGc1iK2qXaXvdbrejI8%2FyGOp1g%3D%3D' +
                '&returnType=JSON');
        req.setBody(headerValue);

        system.debug(req);

        HttpResponse response = http.send(req);
        system.debug(response.getBody());

        JSONParser jsonP = JSON.createParser(response.getBody());

        ApiData apid;
        List<String> crnReturn = new List<String>();
        while(jsonP.nextToken() != null){
            // 배열에서 시작
            if (jsonP.getCurrentToken() == JSONToken.START_ARRAY) {
                while (jsonP.nextToken() != null) {
                    // 다음 토큰이 없을때 까지
                    if(jsonP.getCurrentToken() == JSONToken.START_OBJECT){
                        //Data d = (Data)persapier.readValueAs()
                        apid = (ApiData)jsonP.readValueAs(Apidata.class);
                        // 사업자 등록번호 체크
                        String s = Json.serialize(apid);

                        crnReturn.add(String.valueOf(apid.b_stt));   

                        jsonP.skipChildren();
                    }
                }
            }
        }
       return crnReturn;
    }


    public class ApiData {
        public String b_stt;  
        
        public ApiData(String num2) {
            b_stt = num2;
        }
    }
}