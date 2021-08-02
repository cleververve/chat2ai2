/**
Author:         serhiivolynets
Date:           20.04.2021
Description:   
**/
@IsTest
public with sharing class SM091_APITest
{
	@IsTest
	public static  void testIt()
	{
		SM091_API.CallInput inp = new SM091_API.CallInput();
		inp.sType = 'PATCH';
		inp.sBody = '{ "disqualified": true }';
		inp.sHeaders = '{"api_key":"3NX6AQ896ZVXSNESPFA2RXVX","partner_id":"f7c3b952-0a91-4445-9807-43026d0124fa","Content-Type": "application/json"}';
		inp.sType = 'CancelHerc';
		inp.sURL = 'https://prod-herc-gateway.herc.one/raffle-ticket/timestamp-reference/ticket/1234';
		test.startTest();

			Test.setMock(HttpCalloutMock.class, new SM089_HercMock());
		SM091_API.callIt(new list<SM091_API.CallInput > {inp});
		test.stopTest();
	}
}