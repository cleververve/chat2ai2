/**
Author:         serhiivolynets
Date:           29.07.2022
Description:   
**/
@IsTest
public class SM097_GoogleSheetJobTest
{
	@TestSetup
	public static void prepareData()
	{
		Product2 prod = new Product2(Name = 'test product',CVCH__Google_Sheets_Synch_Required__c = true);
		insert prod;
	}

	@IsTest
	public static  void testIt()
	{
		Test.startTest();
SM097_GoogleSheet.initSheet();
		Test.stopTest();
	}

	@IsTest
	public static void testSchedule()
	{
		Test.startTest();
		System.schedule('test excel sync','0 0 * * * ?', new SM097_GoogleSheetSchedule());
		Test.stopTest();
	}
}
