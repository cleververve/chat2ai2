/**
Author:         serhiivolynets
Date:           07.09.2020
Description:   
**/
@isTest
public class SM081_AzureTokenTest
{
	@IsTest
	public static void testIt()
	{
		Test.startTest();
		SM081_AzureToken.getToken();
		Test.stopTest();
	}
}
