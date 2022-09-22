/**
Author:         serhiivolynets
Date:           08.07.2022
Description:   
**/
@IsTest
public class FlowSetVisitorSurveyFlagTest
{
	@IsTest
	public static void testIt()
	{
		TestDataFactory data1 = new TestDataFactory();
		FlowSetVisitorSurveyFlag.SetVisitorSurveyFlagInput mess = new FlowSetVisitorSurveyFlag.SetVisitorSurveyFlagInput();
		mess.visitorId = data1.vis.id;
		mess.flag = true;

		Test.startTest();
		list<FlowSetVisitorSurveyFlag.SetVisitorSurveyFlagInput> linp = new list<FlowSetVisitorSurveyFlag.SetVisitorSurveyFlagInput>();
		linp.add(mess);
		FlowSetVisitorSurveyFlag.setFlag(linp);
		Test.stopTest();
	}
}
