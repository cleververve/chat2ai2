/**
Author:         serhiivolynets
Date:           15.09.2022
Description:   
**/

global class SM042_NexmoOutMock implements HttpCalloutMock
{
	global static HTTPResponse respond(HTTPRequest req)
	{
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);


		res.setBody('{"message_uuid":"111222333"}');
		return res;
	}
}

