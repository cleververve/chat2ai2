/**
Author:         serhiivolynets
Date:           08.07.2020
Description:   
**/
@IsTest
public with sharing class SM080_QnATest
{
	@IsTest
	public static void testIt()
	{
		Test.startTest();
		SM080_QnA.queryPhrase('Hi!','en');
		Test.stopTest();
	}

}