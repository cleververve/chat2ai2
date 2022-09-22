/**
Author:         serhiivolynets
Date:           08.07.2022
Description:   
**/
@IsTest
public class SM096_runSurveyFlowTest
{
	@TestSetup
	public static void initData()
	{
		CVCH__chat2ai__c cust6 = new CVCH__chat2ai__c();
		cust6.name = 'Survey Flow';
		cust6.CVCH__value__c = 'survey';
		insert cust6;
	}

	@IsTest
	public static void test1()
	{
		CVCH__Visitor__c v = SM031_NexmoTEST.createExistingVisitor('Full Access');
		v.Survey_Required_Flag__c = true;
		v.Last_Interaction_Date__c = DateTime.now().addDays(-5);
		update v;
		Test.startTest();
		Database.executeBatch(new SM096_runSurveyFlow(),1);
		Test.stopTest();
	}
}
