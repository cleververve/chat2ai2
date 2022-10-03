/**
Author:         serhiivolynets
Date:           28.09.2022
Description:   
**/
@IsTest
public with sharing class SM080_LearnTest
{
	@IsTest
	public static void testLearnCall()
	{
		Test.startTest();
		SM080_LUIS.LuisResponse resp = SM080_Learn.queryPhrase('aaaa','1111');

		Test.stopTest();
		system.assertEquals(resp.sIntent,'greetings');
		system.assertEquals(resp.dScore,99.7733700);
//		system.debug(resp.mParameters);
//		system.assertEquals(resp.mParameters.get('datetimeV2'),'tonight');
	}

}
