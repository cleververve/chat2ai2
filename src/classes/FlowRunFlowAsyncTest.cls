/**
Author:         serhiivolynets
Date:           26.05.2022
Description:   
**/
@IsTest
public with sharing class FlowRunFlowAsyncTest
{
	@IsTest
	public static void testrunflowAsync()
	{
		id visitorId = SM031_NexmoTEST.createExistingVisitor('Full Access').Id;
		FlowRunFlowAsync.runFlowInput inp = new FlowRunFlowAsync.runFlowInput();
		inp.delay = 30;
		inp.flowName = 'Option_to_JSON';
		inp.paramName1 = 'visitorId';
		inp.paramName2 = 'bbb';
		inp.paramName3 = 'ccc';
		inp.paramName4 = 'ddd';
		inp.paramValue1 = visitorId;
		inp.paramValue2 = 'bbbb';
		inp.paramValue3 = 'cccc';
		inp.paramValue4 = 'dddd';
		Test.startTest();
		FlowRunFlowAsync.runFlows(new list<FlowRunFlowAsync.runFlowInput > {inp});
		test.stopTest();
	}
}
