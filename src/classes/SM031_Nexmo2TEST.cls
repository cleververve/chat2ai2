/**
Author:         serhiivolynets
Date:           28.04.2022
Description:   
**/
@IsTest
public with sharing class SM031_Nexmo2TEST
{
	@TestSetup
	public static void createData()
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


		CVCH__chat2ai__c cust9 = new CVCH__chat2ai__c();
		cust9.name = 'Salesforce URL';
		cust9.CVCH__value__c = 'google.com';

		lcust.add(cust1);
		lcust.add(cust2);
		lcust.add(cust3);
		lcust.add(cust4);
		lcust.add(cust5);
		lcust.add(cust6);
		lcust.add(cust7);
		lcust.add(cust8);
		lcust.add(cust9);
		insert lcust;
	}

	@IsTest public static  void testWS2()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/nexmo2/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('test1');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CVCH.SM004_SMSMock());
		SM031_Nexmo2.getMessage();
		Test.stopTest();
	}
}
