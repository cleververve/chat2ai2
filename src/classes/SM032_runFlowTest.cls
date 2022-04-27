/**
Author:         serhiivolynets
Date:           14.03.2022
Description:   
**/
@IsTest
public class SM032_runFlowTest
{
	@isTest
	public static void TestGet()
	{

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/runflow/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.ValueOf('{"flowName":"aaa","to":"aaaa"}');
		RestContext.request = req;
		RestContext.response = res;
		Test.startTest();
		SM032_runFlow.runFlow();
		Test.stopTest();
	}
}
