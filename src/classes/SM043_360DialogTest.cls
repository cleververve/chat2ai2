/**
Author:         serhiivolynets
Date:           28.11.2021
Description:   
**/
@IsTest
public with sharing class SM043_360DialogTest
{
	@IsTest
	public static void testIt()
	{
		Test.startTest();
		SM043_360Dialog.sendTextMessage('111','1111','1111');
		SM043_360Dialog.sendCustom('111','1111','Interactive','111');
		SM043_360Dialog.sendImage('111','111','google.com','111');
		Test.stopTest();
	}
}
