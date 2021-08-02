/**
Author:         serhiivolynets
Date:           13.03.2021
Description:   
**/

global class SM090_UploadS3Mock implements HttpCalloutMock
{
	global static HTTPResponse respond(HTTPRequest req)
	{
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		String reqBody =
				'{"Error": "","URL": "aaaa"}';
		res.setBody(reqBody);
		return res;

	}
}