/**
Author:         serhiivolynets
Date:           22.09.2022
Description:   
**/
@IsTest
public with sharing class SM099_FlowMappingTest
{
	@IsTest
	public static void testGetFlow()
	{

		Test.startTest();
		String sFlow = SM099_FlowMapping.getFlow('bbb','{{!!abc!!}}');
		Test.stopTest();
		System.assertEquals(sFlow,'flow1');
	}

	@IsTest
	public static void testGetFlow2()
	{

		Test.startTest();
		String sFlow = SM099_FlowMapping.getFlow('def',null);
		Test.stopTest();
		System.assertEquals(sFlow,'flow2');
	}

	@IsTest
	public static void testGetIntentFromText()
	{
		System.assertEquals(SM099_FlowMapping.getIntentFromText('{{!!abc!!}}'),'abc');
	}
}
