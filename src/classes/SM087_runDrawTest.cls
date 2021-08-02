/**
Author:         serhiivolynets
Date:           10.02.2021
Description:   
**/
@IsTest
public class SM087_runDrawTest
{
	@TestSetup
	public static void prepareData()
	{
		CVCH__Ruffle_Draw__c draw = new CVCH__Ruffle_Draw__c();
		draw.Name = 'aaaa';
		draw.CVCH__Draw_Date__c = Datetime.now();
		draw.CVCH__Winners__c = 50;
		insert draw;
		list<CVCH__Ruffle_Draw_Ticket__c> lTick = new list<CVCH__Ruffle_Draw_Ticket__c>();
		for (Integer i = 0; i < 100; i++)
		{
			CVCH__Ruffle_Draw_Ticket__c tick = new CVCH__Ruffle_Draw_Ticket__c();
			tick.CVCH__Ruffle_Draw__c = draw.Id;
			lTick.add(tick);
		}
		insert lTick;
	}

	@IsTest
	public static void testIt4()
	{
		Test.startTest();
		RestRequest req = new RestRequest();
		req.requestBody = Blob.valueof('{"raffleDrawName":"aaaa"}"');
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/raffleDraw/';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;
		SM087_runDraw.runIt();
		Test.stopTest();
	}
}