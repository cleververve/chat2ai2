/**
Author:         serhiivolynets
Date:           26.05.2022
Description:   
**/

global class FlowRunFlowAsync
{

	global class runFlowInput
	{
		@AuraEnabled @InvocableVariable global string flowName;
		@AuraEnabled @InvocableVariable global integer delay;
		@AuraEnabled @InvocableVariable global string paramName1;
		@AuraEnabled @InvocableVariable global string paramValue1;
		@AuraEnabled @InvocableVariable global string paramName2;
		@AuraEnabled @InvocableVariable global string paramValue2;
		@AuraEnabled @InvocableVariable global string paramName3;
		@AuraEnabled @InvocableVariable global string paramValue3;
		@AuraEnabled @InvocableVariable global string paramName4;
		@AuraEnabled @InvocableVariable global string paramValue4;
	}

	@InvocableMethod(label='run flow asynchronously' description='run flow asyncronously')
	global static void runFlows(list<runFlowInput> lParam)
	{
		for(runFlowInput param : lParam)
		{
			string str = JSON.serialize(param);
			runFlowAsync(str);
		}
	}


	@Future(CallOut = true)
	public static void runFlowAsync(string str)
	{
		FlowRunFlowAsync.runFlowInput param = (FlowRunFlowAsync.runFlowInput)JSON.deserializeStrict(str,FlowRunFlowAsync.runFlowInput.class);
		Map<String, Object> params = new Map<String, Object>();
		if(param.paramName1 != '' && param.paramName1 != null)
			params.put(param.paramName1,param.paramValue1);
		if(param.paramName2 != '' && param.paramName2 != null)
			params.put(param.paramName2,param.paramValue2);
		if(param.paramName3 != '' && param.paramName3 != null)
			params.put(param.paramName3,param.paramValue3);
		if(param.paramName4 != '' && param.paramName4 != null)
			params.put(param.paramName4,param.paramValue4);
		if(param.delay >20)
			param.delay = 20;
		SM042_NexmoOut2.pause(param.delay *1000);
		Flow.Interview.createInterview(param.flowName, params).start();
	}


}
