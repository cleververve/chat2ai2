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
    static void createExistingVisitor(string GDPR)
    {
        Visitor__c vis = new Visitor__c();
        vis.gdpr_consent__c = gdpr;
        vis.Had_First_Interaction__c = true;
        vis.Chat_Number__c = '1234567890';
        vis.id__c = '009876543211';
        vis.chanel__c = 'whatsapp';
        insert vis;
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
    
}
