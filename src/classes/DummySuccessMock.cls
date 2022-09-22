/**
Author:         serhiivolynets
Date:           29.07.2022
Description:   
**/
global  class DummySuccessMock  implements HttpCalloutMock
{
	global static HTTPResponse respond(HTTPRequest req)
	{

		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		String reqBody = '';
		res.setBody(reqBody);
		return res;
	}
}
