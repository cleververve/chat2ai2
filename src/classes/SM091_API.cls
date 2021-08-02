/**
Author:         serhiivolynets
Date:           19.04.2021
Description:   
**/

global class SM091_API
{

	global class CallInput
	{

		@AuraEnabled @InvocableVariable global string sURL;
		@AuraEnabled @InvocableVariable global string sMethod;
		@AuraEnabled @InvocableVariable global string sBody;
		@AuraEnabled @InvocableVariable global string sHeaders;
		@AuraEnabled @InvocableVariable global string sType;
	}

	global class CallOutput
	{
		@AuraEnabled @InvocableVariable global string sResponse;
		@AuraEnabled @InvocableVariable global string sError;
	}



	@InvocableMethod(label='Call Http Service' description='Call Http Service')
	global static list<CallOutput> callIt(list<CallInput> inputs)
	{
		list<CallOutput> lRet = new list<CallOutput>();
		for(CallInput inp : inputs)
		{
			CallOutput out = new CallOutput();
			try
			{
				map<string,string> mHeaders = new map<string,string>();
				if(inp.sHeaders != '' && inp.sHeaders != null)
				{
					map<string,object> mObj = (map<string,object>)JSON.deserializeUntyped(inp.sHeaders);
					for(string sKey : mObj.keySet())
					{
						mHeaders.put(sKey,''+mObj.get(sKey));
					}
				}

				HttpResponse resp = SM003_Http.request(inp.sURL, inp.sMethod, mHeaders,inp.sBody, inp.sType,null);

				out.sResponse = resp.getBody();
			} catch (Exception e)
			{
				out.sError = e.getMessage()+' '+e.getLineNumber();
			}
			lRet.add(out);
		}
		return lRet;
	}
}