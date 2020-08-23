@IsTest
public class SM031_NexmoTEST {
    static void createData()
    {
        list<chat2ai__c> lcust = new list<chat2ai__c>();
        chat2ai__c cust1 = new chat2ai__c();
        cust1.name = 'Chat2ai Flow';
        cust1.value__c = 'LUIS';
        chat2ai__c cust2 = new chat2ai__c();
        cust2.name = 'Chat2ai Flow';
        cust2.value__c = 'LUIS';

        lcust.add(cust1);
        lcust.add(cust2);
    }
    @isTest
    static void TestNewVisitor()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/nexmo/';
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
    }
    
}