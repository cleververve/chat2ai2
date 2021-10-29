/**
Author:         serhiivolynets
Date:           15.09.2021
Description:   
**/
@IsTest
public class SM094_getTicketInformationTest
{
	@IsTest
	public static void testIt()
	{
		CVCH__Ruffle_Draw_Ticket__c tick = new CVCH__Ruffle_Draw_Ticket__c();
		insert tick;
		tick = [SELECT id, CVCH__Short_Id__c from CVCH__Ruffle_Draw_Ticket__c where id = :tick.Id];

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/getCustomerInformation/';
		req.httpMethod = 'GET';
		req.params.put('TicketNumber', tick.CVCH__Short_Id__c);
		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		SM094_getTicketInformation.getIt();
		Test.stopTest();
	}
}
