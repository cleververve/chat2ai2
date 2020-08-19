/**
Author:         serhiivolynets
Date:           08.07.2020
Description:   
**/
@IsTest
public with sharing class SM080_LUISTest
{
	@IsTest
	public static void testIt()
	{
		Test.startTest();
		SM080_LUIS.queryPhrase('Hi','it');
		Test.stopTest();
	}

}