@IsTest
public class SM031_NexmoTEST {
    @TestSetup
    static void createData()
    {
        list<chat2ai__c> lcust = new list<chat2ai__c>();
        chat2ai__c cust1 = new chat2ai__c();
        cust1.name = 'Chat2ai Flow';
        cust1.value__c = 'send_options';
        
        chat2ai__c cust2 = new chat2ai__c();
        cust2.name = 'Response minimum score';
        cust2.value__c = '50';
        
        chat2ai__c cust3 = new chat2ai__c();
        cust3.name = 'Default Flow';
        cust3.value__c = 'send_options';
        
        chat2ai__c cust4 = new chat2ai__c();
        cust4.name = 'GDPR Flow';
        cust4.value__c = 'send_options';
        
        chat2ai__c cust5 = new chat2ai__c();
        cust5.name = 'Main Menu Flow';
        cust5.value__c = 'send_options';

        chat2ai__c cust6 = new chat2ai__c();
        cust6.name = 'Welcome Flow';
//        cust6.value__c = 'send_options';
        
        lcust.add(cust1);
        lcust.add(cust2);
        lcust.add(cust3);
        lcust.add(cust4);
        lcust.add(cust5);
        lcust.add(cust6);
        insert lcust;
        
        
    }
    static Visitor__c createExistingVisitor(string GDPR)
    {
        CVCH__Visitor__c vis = new CVCH__Visitor__c();
        vis.gdpr_consent__c = gdpr;
        vis.Had_First_Interaction__c = true;
        vis.Chat_Number__c = '1234567890';
        vis.id__c = '009876543211';
        vis.chanel__c = 'whatsapp';
        vis.language__c = 'it';
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

        Visitor__c v = createExistingVisitor('Full Access');
        v.Context__c = getVisitorContext('options','');
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

        Visitor__c v = createExistingVisitor('Full Access');
        v.Context__c = getVisitorContext('options','');
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

        Visitor__c v = createExistingVisitor('Full Access');
        v.Next_Flow__c = 'send_options';
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
        req.requestBody = getRequestBody('male');
        RestContext.request = req;
        RestContext.response = res;

        Visitor__c v = createExistingVisitor('Full Access');
        v.Context__c = getVisitorContext('Input','gender__c');

        update v;
        CVCH__Visitor__c vv;
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

        Visitor__c v = createExistingVisitor('No Access');
        v.Context__c = getVisitorContext('options','');
        update v;
        Test.startTest();
        SM031_Nexmo.getMessage();
        Test.stopTest();
    }
    
}
