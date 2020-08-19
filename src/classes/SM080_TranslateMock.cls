/**
Author:         serhiivolynets
Date:           17.08.2020
Description:   
**/

global class SM080_TranslateMock implements HttpCalloutMock
{
	global static HTTPResponse respond(HTTPRequest req)
	{
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		String reqBody = '[{"detectedLanguage": {"language": "en","score": 1.0},"translations": [{"text": "Привет, как тебя зовут?","to": "ru"}]}]';
		res.setBody(reqBody);
		return res;
	}
}