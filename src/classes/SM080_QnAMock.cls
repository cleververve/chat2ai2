/**
Author:         serhiivolynets
Date:           08.07.2020
Description:   
**/

global class SM080_QnAMock  implements HttpCalloutMock
{
	global static HTTPResponse respond(HTTPRequest req)
	{
		
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);
		String reqBody = '{"answers":[{"questions":["What is Viafone"],"answer":"VIAFONE TECHNOLOGIES part of CELS Group aims to foster the relationship with customers before, during and after every “touch point” with brands, allowing an elevated customer experience.","score":100.0,"id":91,"source":"Editorial","metadata":[],"context":{"isContextOnly":false,"prompts":[{"displayOrder":0,"qnaId":92,"qna":null,"displayText":"what we do"}]}}],"debugInfo":null,"activeLearningEnabled":false}';
		res.setBody(reqBody);
		return res;
	}
}