/**
Author:         serhiivolynets
Date:           28.04.2022
Description:   
**/
@RestResource(urlMapping='/nexmo2/*')
global class SM031_Nexmo2
{

	@HttpPost
	global static string getMessage()
	{

		string sBody = RestContext.request.requestBody.toString();
		system.debug('sBody='+sBody);
		SM031_Nexmo.getMessage();
		return '';
	}

	@Future(Callout = true)
	public static  void callAsync(string sBody)
	{
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();
		string sBaseURL = CVCH__Chat2ai__c.getInstance('Salesforce URL').CVCH__Value__c;
		req.setEndpoint(sBaseURL + '/services/apexrest/CVCH/nexmo');

		req.setMethod('POST');
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setBody(sBody);
		req.setTimeout(120000);
		system.debug('sBody='+sBody);
		res = http.send(req);
		system.debug(res);
		system.debug('finished the call to nexmo');

	}
}
