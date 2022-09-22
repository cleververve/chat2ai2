/**
Author:         serhiivolynets
Date:           30.03.2020
Description:
**/

global class SM003_Http
{

	Public Static Integer TIMEOUT = 100000; // IMO-3716 // Default HTTP Timeout

	Public Static HttpRequest buildRequest(Map<String, String> headers, String url, String method, String body)
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

	public static HttpResponse request(String url, String method, Map<String, String> headers, String body, String callType, String recId)
	{
		return request(url, method, headers, body, callType, recId, null);
	}

	@Future(Callout=true)
	global static void requestAsync(String url, String method, String sHeaders, String body, String callType, String recId, String sMockName)
	{
		try
		{
			Map<String, Object> mHead = (Map<String, Object>) JSON.deserializeUntyped(sHeaders);
			Map<String, String> mHeaders = new Map<String, String>();
			for (String sKey : mHead.keySet())
			{
				mHeaders.put(sKey, mHead.get(sKey).toString());
			}

			request(url, method, mHeaders, body, callType, recId, sMockName, false);
		}
		catch (Exception e)
		{
			SM005_Logs.save();
		}
	}

	global static HttpResponse request(String url, String method, Map<String, String> headers, String body, String callType, String recId, String sMockName)
	{
		return request(url, method, headers, body, callType, recId, sMockName, false);
	}
	global static HttpResponse request(String url, String method, Map<String, String> headers, String body, String callType, String recId, String sMockName, Boolean bSendAndForget)
	{
		Http h = new Http();
		System.debug('request body is: ' + body);
		System.debug('request URL is: ' + url);

		HttpRequest request = buildRequest(headers, url, method.toUpperCase(), body);
		HttpCalloutMock mock;
		if (sMockName != null && (Test.isRunningTest() || SM010_Utils.getChat2aiValue2('MockEAI') == 'TRUE'))
		{
			mock = (HttpCalloutMock) (Type.forName(sMockName).newInstance());
			if (Test.isRunningTest())
				Test.setMock(HttpCalloutMock.class, mock);
		}
		HttpResponse response;
		String sStatus = '';
		String sStatusCode = '';
		Datetime dtBeg = Datetime.now();
		Datetime dtEnd;
		String sErrorMessage = '';
		try
		{
//            log('Request', request, getBodyForLog(request,callType));
			dtBeg = Datetime.now();
			if (SM010_Utils.getChat2aiValue2('MockEAI') == 'TRUE' && mock != null)
				response = mock.respond(request);
			else
					response = h.send(request);


			dtEnd = Datetime.now();
			sStatusCode = '' + response.getStatusCode();
			if (response.getStatusCode() > 299)
			{
				String sErr = response.getBody();
				if (sErr == null || sErr == '')
					sErr = 'SM001_Rest_Client: Failed to receive a success code from remote. ' + response.getStatus() + ' ' + response.getStatusCode();
//				system.debug('SM001_Rest_Client: Failed to receive a success code from remote. Code was: ' + response.getStatusCode() + ' request was ' + request + ' Response Body is: ' + response.getBody());
				throw new MyException(sErr);
			}
			sStatus = 'Success';
		}
		catch (System.CalloutException e)
		{
			if (dtEnd == null)
				dtEnd = Datetime.now();
			sStatus = 'Error';
			sErrorMessage = e.getMessage();
			if (sErrorMessage != null && sErrorMessage.length() > 254)
				sErrorMessage = sErrorMessage.substring(0, 253);
			if (bSendAndForget && e.getMessage().indexOf('You have uncommitted work pending.') == 0 && !System.isFuture())
			{
				requestAsync(url, method, JSON.serialize(headers), body, callType, recId, sMockName);
			}
			else
			{
				throw e;
			}
		}
		catch (Exception e)
		{

			if (dtEnd == null)
				dtEnd = Datetime.now();
			sStatus = 'Error';
			sErrorMessage = e.getMessage();
			if (sErrorMessage != null && sErrorMessage.length() > 254)
				sErrorMessage = sErrorMessage.substring(0, 253);
			throw e;
		}
		finally
		{
			String respBody = '', reqBody = '';
			if (response != null)
			{
				respBody = response.getBody();
				System.debug(callType + ' response:');
				System.debug(respBody);
			}

			if (request != null)
				reqBody = request.getBody();

			SM005_Logs.LogCallOut(recId, callType, reqBody, respBody, dtBeg, dtEnd, sErrorMessage, url, request.getHeader('Authorization'), headers, method);
		}
		return response;
	}
}
