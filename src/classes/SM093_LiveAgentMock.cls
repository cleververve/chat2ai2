/**
Author:         serhiivolynets
Date:           03.09.2021
Description:   
**/

global class SM093_LiveAgentMock implements HttpCalloutMock
{
	global static HTTPResponse respond(HTTPRequest req)
	{
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		String reqBody =
				'{"affinityToken": "aaaa","key": "aaaa"}';
		res.setBody(reqBody);
		return res;
	}
}
