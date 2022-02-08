/**
Author:         serhiivolynets
Date:           08.12.2021
Description:   
**/
@IsTest
public with sharing class SM044_NexmoV1Test
{
	@IsTest
	public static void testIt()
	{
		Test.startTest();
		SM044_NexmoV1.sendText('111','1111','1111');
		SM044_NexmoV1.sendCustom('111','1111','111');
		SM044_NexmoV1.sendLink('111','1111','google.com','111','image');
		Test.stopTest();
	}
}
