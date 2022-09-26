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
		req.requestBody = Blob.valueOf('{"to":"971600555559", "from":"009876543211", "channel":"whatsapp", "message_uuid":"b30de73b-7c55-4a8b-963c-9d0e1fe0b10b", "timestamp":"2022-02-17T06:13:13Z", "message_type":"location", "location":{"address":"Dubai, Dubai", "name":"Cricket Stadium Bus Stop", "url":"https://foursquare.com/v/5a34e3a9bed4831f48b6700f", "lat":25.04334831237793, "long":55.21806335449219}, "profile":{"name":"Vika"}}');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new CVCH.SM004_SMSMock());
		SM031_Nexmo2.getMessage();
		Test.stopTest();
	}
}
