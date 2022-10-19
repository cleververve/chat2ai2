/**
Author:         serhiivolynets
Date:           09.10.2022
Description:   
**/

global with sharing class SM043_360DialogMock  implements HttpCalloutMock
{
	global static HttpResponse respond(HttpRequest req)
	{
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);

		res.setBody('{"contacts":[{"input":"919811696562","wa_id":"919811696562"}],"messages":[{"id":"test_d360"}],"meta":{"api_status":"stable","version":"2.41.2"}}');
		return res;
	}
}
