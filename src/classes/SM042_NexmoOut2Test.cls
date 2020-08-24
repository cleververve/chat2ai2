/**
Author:         serhiivolynets
Date:           23.08.2020
Description:   
**/
@IsTest
public with sharing class SM042_NexmoOut2Test
{
	@IsTest
	public static void test()
	{
		Test.startTest();
		SM042_NexmoOut2.sendText('12345','12345');
		Test.stopTest();
	}

}