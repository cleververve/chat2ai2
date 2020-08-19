/**
Author:         serhiivolynets
Date:           30.03.2020
Description:
**/

public with sharing class SM003_Http
{

    Public Static Integer TIMEOUT = 100000; // IMO-3716 // Default HTTP Timeout

	Public Static HttpRequest buildRequest(map<String, String> headers, String url, String method, String body)
	{
        HttpRequest request = new HttpRequest();
        request.setTimeout(TIMEOUT); // timeout in milliseconds 
		if (headers != null)
		{
			for (String hkey : headers.keySet())
			{
                request.setHeader(hkey, headers.get(hkey)); 
            }   
        }
        
        request.setEndpoint(url);
        request.setMethod(method);
		if (body != null && body.length() > 0)
            request.setBody(body);
		
        return request;
    }
    
	public static HttpResponse request(String url, String method, Map<String, String> headers, String body, string callType, string recId)
	{
		return request(url, method, headers, body, callType, recId,null);
	}

	Public static HttpResponse request(String url, String method, Map<String, String> headers, String body, string callType, string recId,string sMockName)
    {
		Http h = new Http();
		system.debug('request body is: '+body);
        HttpRequest request = buildRequest(headers, url, method.toUpperCase(), body);
		HttpCalloutMock mock;
		if (sMockName != null && (Test.isRunningTest() || SM010_Utils.getValue('MockEAI') == 'TRUE'))
		{
			mock = (HttpCalloutMock) (Type.forName(sMockName).newInstance());
			if (Test.isRunningTest())
				Test.setMock(HttpCalloutMock.class, mock);
		}
        HttpResponse response;
        string sStatus = '';
        string sStatusCode = '';
        DateTime dtBeg = DateTime.now();
        DateTime dtEnd;
        string sErrorMessage = '';
        try
        {
//            log('Request', request, getBodyForLog(request,callType));
            dtBeg = DateTime.now();
			if(	SM010_Utils.getValue('MockEAI') == 'TRUE' && mock != null)
				response = mock.respond(request);
			else
            response = h.send(request);


            dtEnd = DateTime.now();
			sStatusCode = '' + response.getStatusCode();
			if (response.getStatusCode() > 299)
			{
				system.debug('SM001_Rest_Client: Failed to receive a success code from remote. Code was: ' + response.getStatusCode() + ' request was ' + request + ' Response Body is: ' + response.getBody());
                throw new MyException(response.getBody());
            }
            sStatus = 'Success';
		}
		catch (Exception e)
        {
			if (dtEnd == null)
                dtEnd = DateTime.now();
            sStatus = 'Error';
            sErrorMessage = e.getMessage();
			if (sErrorMessage != null && sErrorMessage.length() > 254)
                sErrorMessage = sErrorMessage.substring(0, 253);
            throw e;
        }
        finally
        {
			string respBody = '', reqBody = '';
			if (response != null)
			{
                respBody = response.getBody();
				system.debug(callType + ' response:');
				system.debug(respBody);
			}

			if (request != null)
                reqBody = request.getBody();

			SM005_Logs.LogCallOut(recId, callType, reqBody, respBody, dtBeg, dtEnd, sErrorMessage, url, request.getHeader('Authorization'));
        }
        return response;    
    }
}