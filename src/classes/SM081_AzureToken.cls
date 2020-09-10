/**
Author:         serhiivolynets
Date:           07.09.2020
Description:   
**/

public class SM081_AzureToken
{
	public static string token;
	public static string url = 'callout:Azure_bot_token';

	public static string getToken0()
	{
//		string sClientId = '1340ab55-ba59-46d9-a3c1-fe9d46b1954e';
//		string sClientSecret = 'KQn3-lR0Hd7TA4rEW~J3Bdly_86KDkI-v~';
		string sClientId  =  SM010_Utils.getChat2aiValue('Azure Bot ClientId');//'f0ecba54-e43d-45f0-b65c-96919a6bbdf5';
		string sClientSecret  =  SM010_Utils.getChat2aiValue('Azure Bot ClientSecret');//'6aD.-x.~YkkdZM9KLb582CR.3bhRg5xsT0';
		string sScope = 'https://api.botframework.com/.default';
		string sBody = 'grant_type=client_credentials&client_id='+EncodingUtil.urlEncode(sClientId, 'UTF-8')
				+'&client_secret='+EncodingUtil.urlEncode(sClientSecret, 'UTF-8')
				+'&scope='+EncodingUtil.urlEncode(sScope, 'UTF-8');
		map<string,string>mHeaders = new map<string,string>();
		mHeaders.put('Content-Type','application/x-www-form-urlencoded');
		HttpResponse resp = SM003_Http.request(url, 'POST', NULL, sBody, 'Azure auth', NULL, 'SM081_AzureTokenMock');
		map<string,object> mMap = (map<string,object>) JSON.deserializeUntyped(resp.getBody());
		return (string)mMap.get('access_token');
	}

	public static string getToken()
	{
		if(token == null)
			token = getToken0();
		return token;
	}


}
