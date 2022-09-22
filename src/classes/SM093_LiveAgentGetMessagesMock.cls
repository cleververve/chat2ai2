/**
Author:         serhiivolynets
Date:           07.09.2022
Description:   
**/

global with sharing class SM093_LiveAgentGetMessagesMock implements HttpCalloutMock
{
	global static HTTPResponse respond(HTTPRequest req)
	{
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		String reqBody =
				'{"messages":[{"type":"ChatRequestSuccess","message":{"connectionTimeout":3640000,"estimatedWaitTime":230,"sensitiveDataRules":[],"transcriptSaveEnabled":false,"url":"","queuePosition":1,"customDetails":[],"visitorId":"de23d9c6-b253-4c87-8ef9-6279bdb529ff","geoLocation":{"organization":"Salesforce.com","region":"CT","city":"Norwalk","countryName":"United States","latitude":41.1271,"countryCode":"US","longitude":-73.4416}}},{"type":"ChatEnded","message":{"estimatedWaitTime":0,"position":0}},{"type":"ChatEstablished","message":{"name":"Agent 5 M","userId":"0058V00000DQyiT","items":[],"sneakPeekEnabled":true,"chasitorIdleTimeout":{"isEnabled":true,"warningTime":7000,"timeout":7200}}}],"sequence":2,"offset":690883944}';
		res.setBody(reqBody);
		return res;
	}
}
