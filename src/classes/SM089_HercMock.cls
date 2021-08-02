/**
Author:         serhiivolynets
Date:           03.03.2021
Description:   
**/

global class SM089_HercMock implements HttpCalloutMock
{
	global static HTTPResponse respond(HTTPRequest req)
	{
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		String reqBody =
				'{"statusCode": 200,"success": true,"errorCode": 0,"errorMessage": null, "hashString": "b04d89cb24261e1e46c3dc93a9727e22f0cd785431a8142c42cbb17d65e1c9aa" ,"data":{}}';
		res.setBody(reqBody);
		return res;

	}
}