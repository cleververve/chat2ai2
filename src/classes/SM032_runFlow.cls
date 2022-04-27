/**
Author:         serhiivolynets
Date:           14.03.2022
Description:   
**/
@RestResource(urlMapping='/runflow/*')
global class SM032_runFlow
{
	@HttpPost
	global static string runFlow()
	{
		map<string,Object> mParameters = (map<string,Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
		string sFlowName = (string)mParameters.get('flowName');
		try{
			Flow.Interview flow = Flow.Interview.createInterview(sFlowName, mParameters);
			flow.start();
		}catch(Exception e)
		{
			return e.getMessage();
		}
		return '';
	}
}
