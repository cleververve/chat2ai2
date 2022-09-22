/**
Author:         serhiivolynets
Date:           01.08.2022
Description:   
**/
@IsTest
public class FacebookMessageTest
{
	@TestSetup
	public static void createData()
	{
		List<CVCH__Chat2ai__c> lcust = new List<CVCH__Chat2ai__c>();
		CVCH__Chat2ai__c cust16 = new CVCH__Chat2ai__c();
		cust16.Name = 'Facebook Message Flow';
		cust16.CVCH__Value__c = 'test';
		lcust.add(cust16);
		insert lcust;

	}
	@IsTest
	public static void testProductAdded()
	{

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		FacebookMessage mess;
		req.requestURI = '/services/apexrest/facebookmessaging/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"contacts":[{"profile":{"name":"Me"},"wa_id":"971501084679"}],"messages":[{"context":{"referred_product":{"catalog_id":"679615539743464","product_retailer_id":"tl8zro85g0"}},"from":"971501084679","id":"ABEGlxUBCEZ5Ago-sFeiVC2JHJq6","text":{"body":"hello"},"timestamp":"1654242139","type":"text"}]}');

		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		FacebookMessage.getMessage();
		mess = FacebookMessage.parse(req.requestBody.toString());
		Test.stopTest();
		System.assertEquals(mess.wa_id,'971501084679');
		System.assertEquals(mess.profile_name,'Me');
		System.assertEquals(mess.catalog_id,'679615539743464');
		System.assertEquals(mess.sku,'tl8zro85g0');
		System.assertEquals(mess.sFrom,'971501084679');
		System.assertEquals(mess.id,'ABEGlxUBCEZ5Ago-sFeiVC2JHJq6');
		System.assertEquals(mess.text,'hello');
		System.assertEquals(mess.timestamp,'1654242139');
		System.assertEquals(mess.type,'text');
		System.assertEquals(mess.items,null);
	}

	@IsTest
	public static void testOrderReceived()
	{

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		FacebookMessage mess;
		req.requestURI = '/services/apexrest/facebookmessaging/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf('{"contacts":[{"profile":{"name":"Me"},"wa_id":"971501084679"}],"messages":[{"from":"971501084679","id":"ABEGlxUBCEZ5Ago-sLHU3nt8DUkE","order":{"catalog_id":"679615539743464","product_items":[{"currency":"AED","item_price":20,"product_retailer_id":"tl8zro85g0","quantity":1},{"currency":"AED","item_price":20,"product_retailer_id":"ujootwm3or","quantity":4},{"currency":"AED","item_price":20,"product_retailer_id":"bvr32hajb6","quantity":8}],"text":"Please deliver this items"},"timestamp":"1654241486","type":"order"}]}');

		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		FacebookMessage.getMessage();
		mess = FacebookMessage.parse(req.requestBody.toString());
		Test.stopTest();
		System.assertEquals(mess.wa_id,'971501084679');
		System.assertEquals(mess.profile_name,'Me');
		System.assertEquals(mess.catalog_id,'679615539743464');
		System.assertEquals(mess.sku,null);
		System.assertEquals(mess.sFrom,'971501084679');
		System.assertEquals(mess.id,'ABEGlxUBCEZ5Ago-sLHU3nt8DUkE');
		System.assertEquals(mess.text,'Please deliver this items');
		System.assertEquals(mess.timestamp,'1654241486');
		System.assertEquals(mess.type,'order');
		System.assertEquals(mess.items[0].sCurrency,'AED');
		System.assertEquals(mess.items[0].dPrice,20);
	}
}
