@IsTest
public class SM031_NexmoTEST {
    @TestSetup
    static void createData()
    {
        list<CVCH__chat2ai__c> lcust = new list<CVCH__chat2ai__c>();
        CVCH__chat2ai__c cust1 = new CVCH__chat2ai__c();
        cust1.name = 'Chat2ai Flow';
        cust1.CVCH__value__c = 'send_options';

        CVCH__chat2ai__c cust2 = new CVCH__chat2ai__c();
        cust2.name = 'Response minimum score';
        cust2.CVCH__value__c = '50';

        CVCH__chat2ai__c cust3 = new CVCH__chat2ai__c();
        cust3.name = 'Default Flow';
        cust3.CVCH__value__c = 'send_options';

        CVCH__chat2ai__c cust4 = new CVCH__chat2ai__c();
        cust4.name = 'GDPR Flow';
        cust4.CVCH__value__c = 'send_options';

        CVCH__chat2ai__c cust5 = new CVCH__chat2ai__c();
        cust5.name = 'Main Menu Flow';
        cust5.CVCH__value__c = 'send_options';

        CVCH__chat2ai__c cust6 = new CVCH__chat2ai__c();
        cust6.name = 'Welcome Flow';
        cust6.CVCH__value__c = 'test';
        
        CVCH__chat2ai__c cust7 = new CVCH__chat2ai__c();
        cust7.name = 'Default Flow 2';
        cust7.CVCH__value__c = 'test';

        CVCH__chat2ai__c cust8 = new CVCH__chat2ai__c();
        cust8.name = 'CREATE VISITOR BEFORE FLOWS';
        cust8.CVCH__value__c = 'TRUE';
        
        lcust.add(cust1);
        lcust.add(cust2);
        lcust.add(cust3);
        lcust.add(cust4);
        lcust.add(cust5);
        lcust.add(cust6);
        lcust.add(cust7);
        lcust.add(cust8);
        insert lcust;
    }


    static CVCH__Visitor__c createExistingVisitor(string GDPR)
    {
        CVCH__Visitor__c vis = new CVCH__Visitor__c();
        vis.CVCH__gdpr_consent__c = gdpr;
        vis.CVCH__Had_First_Interaction__c = true;
        vis.CVCH__Chat_Number__c = '1234567890';
        vis.CVCH__id__c = '009876543211';
        vis.CVCH__chanel__c = 'whatsapp';
        vis.CVCH__language__c = 'it';
        insert vis;
        return vis;
    }
    
    @isTest
    static void TestNewVisitor()
    {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/nexmo/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf('{"message_uuid":"3315e684-4491-47b9-88a2-3990e543ce6e","to":{"type":"whatsapp","number":"1234567890"},"from":{"type":"whatsapp","number":"09876543211"},"timestamp":"2020-08-22T11:13:21.798Z","message":{"content":{"type":"text","text":"hi"}},"direction":"inbound"}');
        
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        SM031_Nexmo.getMessage();
        Test.stopTest();
    }

    @isTest
    static void TestGet()
    {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/nexmo/';
        req.httpMethod = 'GET';
        req.requestBody = Blob.ValueOf('{"message_uuid":"3315e684-4491-47b9-88a2-3990e543ce6e","to":{"type":"whatsapp","number":"1234567890"},"from":{"type":"whatsapp","number":"09876543211"},"timestamp":"2020-08-22T11:13:21.798Z","message":{"content":{"type":"text","text":"hi"}},"direction":"inbound"}');

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        SM031_Nexmo.testIt();
        Test.stopTest();
    }


    @isTest
    static void testAzure()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/nexmo/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf('{"type":"message","id":"bf3cc9a2f5de","timestamp":"2016-10-19T20:17:52.2891902Z","serviceUrl":"https://smba.trafficmanager.net/apis","channelId":"channel","from":{"id":"1234abcd","name":"username"},"conversation":{"id":"abcd1234","name":"conversation name"},"recipient":{"id":"12345678","name":"bot name"},"text":"Haircut on Saturday"}');

        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        SM031_Nexmo.getMessage();
        list<CVCH__NexmoMessage__c> lmess = [select id, CVCH__Channel__c from CVCH__NexmoMessage__c where CVCH__Channel__c = 'Azure'];
        system.assert(lmess.size()>1);
        list<CVCH__NexmoMessage__c> lmess2 = [select id, CVCH__Channel__c from CVCH__NexmoMessage__c where CVCH__Channel__c <> 'Azure'];
        system.assertEquals(lmess2.size(),0);
        Test.stopTest();
    }

    
    @isTest
    static void TestReturningVisitorGDPRNotAccepted()
    {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/nexmo/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf('{"message_uuid":"3315e684-4491-47b9-88a2-3990e543ce6e","to":{"type":"whatsapp","number":"1234567890"},"from":{"type":"whatsapp","number":"09876543211"},"timestamp":"2020-08-22T11:13:21.798Z","message":{"content":{"type":"text","text":"hi"}},"direction":"inbound"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        createExistingVisitor('No Access');
        Test.startTest();
        SM031_Nexmo.getMessage();
        Test.stopTest();
    }
    
    @isTest
    static void TestReturningVisitorGDPRAccepted()
    {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/nexmo/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf('{"message_uuid":"3315e684-4491-47b9-88a2-3990e543ce6e","to":{"type":"whatsapp","number":"1234567890"},"from":{"type":"whatsapp","number":"09876543211"},"timestamp":"2020-08-22T11:13:21.798Z","message":{"content":{"type":"text","text":"hi"}},"direction":"inbound"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        createExistingVisitor('Full Access');
        Test.startTest();
        SM031_Nexmo.getMessage();
        Test.stopTest();
    }
    public static Blob getRequestBody(string sText)
    {
        string sRet = '{"message_uuid":"3315e684-4491-47b9-88a2-3990e543ce6e","to":{"type":"whatsapp","number":"1234567890"},"from":{"type":"whatsapp","number":"09876543211"},"timestamp":"2020-08-22T11:13:21.798Z","message":{"content":{"type":"text","text":"'+sText+'"}},"direction":"inbound"}';
        return Blob.valueOf(sRet);
    }

    public static string getVisitorContext(string sType,string sFieldName)
    {
         string sRet = '{"visitorId":"a0e7E00000DhvqyQAB","sType":"'+sType+'","sMessage":"Seleziona la tua lingua: ","sFlow":"send_options","sFieldName":"'+sFieldName+'","sConfirmMessage":null,"mOptions":{"2":{"sValue3":"","sValue2":"","sValue":"it","sType":"","sName3":"","sName2":"","sName":"language","sLabel":"Italian","sFlow":"send_options","iNumber":2},"1":{"sValue3":"","sValue2":"","sValue":"111","sType":"QnA","sName3":"","sName2":"","sName":"language","sLabel":"English","sFlow":"send_options","iNumber":1}},"lOptions":[],"lItems":[],"content":"{\\"sType\\":\\"\\",\\"a\\":[{\\"sValue3\\":\\"\\",\\"sValue2\\":\\"\\",\\"sValue\\":\\"en\\",\\"sType\\":\\"\\",\\"sName3\\":\\"\\",\\"sName2\\":\\"\\",\\"sName\\":\\"language\\",\\"sLabel\\":\\"English\\",\\"sFlow\\":\\"send_options\\",\\"iNumber\\":null},{\\"sValue3\\":\\"\\",\\"sValue2\\":\\"\\",\\"sValue\\":\\"it\\",\\"sType\\":\\"\\",\\"sName3\\":\\"\\",\\"sName2\\":\\"\\",\\"sName\\":\\"language\\",\\"sLabel\\":\\"Italian\\",\\"sFlow\\":\\"send_options\\",\\"iNumber\\":null},{},{},{},{},{},{},{},{}]}"}';
        return sRet;
    }

    @isTest
    static void TestMessageWOptions()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/nexmo/';
        req.httpMethod = 'POST';
        req.requestBody = getRequestBody('2');
        RestContext.request = req;
        RestContext.response = res;

        CVCH__Visitor__c v = createExistingVisitor('Full Access');
        v.CVCH__Context__c = getVisitorContext('options','');
        update v;
        Test.startTest();
        SM031_Nexmo.getMessage();
        Test.stopTest();
    }

    @isTest
    static void TestMessageWOptionsQnA()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/nexmo/';
        req.httpMethod = 'POST';
        req.requestBody = getRequestBody('1');
        RestContext.request = req;
        RestContext.response = res;

        CVCH__Visitor__c v = createExistingVisitor('Full Access');
        v.CVCH__Context__c = getVisitorContext('options','');
        update v;
        Test.startTest();
        SM031_Nexmo.getMessage();
        Test.stopTest();
    }

    @IsTest
    static void TestMessageNextFlow()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/nexmo/';
        req.httpMethod = 'POST';
        req.requestBody = getRequestBody('1');
        RestContext.request = req;
        RestContext.response = res;

        CVCH__Visitor__c v = createExistingVisitor('Full Access');
        v.CVCH__Next_Flow__c = 'send_options';
        update v;
        Test.startTest();
        SM031_Nexmo.getMessage();
        Test.stopTest();
    }

    @IsTest
    static void TestMessageInput()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/nexmo/';
        req.httpMethod = 'POST';
        req.requestBody = getRequestBody('20/01/2022');
        RestContext.request = req;
        RestContext.response = res;

        CVCH__Visitor__c v = createExistingVisitor('Full Access');
        v.CVCH__Context__c = getVisitorContext('Input','CVCH__Date__c');

        update v;
        Test.startTest();
        SM031_Nexmo.getMessage();
        Test.stopTest();
    }


    @isTest
    static void TestMessageNoAccessWithOptions()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/nexmo/';
        req.httpMethod = 'POST';
        req.requestBody = getRequestBody('2');
        RestContext.request = req;
        RestContext.response = res;

        CVCH__Visitor__c v = createExistingVisitor('No Access');
        v.CVCH__Context__c = getVisitorContext('options','');
        update v;
        Test.startTest();
        SM031_Nexmo.getMessage();
        Test.stopTest();
    }


    @isTest
    static void TestButton()
    {
        Test.startTest();
        SM031_Nexmo.getMessage0('{"message_uuid":"5a6dbb4e-cde7-4664-a40f-81d5854a03c4","to":{"type":"whatsapp","number":"1234567890"},"from":{"type":"whatsapp","number":"380668657070"},"timestamp":"2021-05-19T09:12:44.151Z","message":{"content":{"type":"button","button":{"text":"Consent 1","payload":"Yes-Button-Payload"}}},"direction":"inbound"}');
        Test.stopTest();
    }
    
}