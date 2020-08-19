/**
Author:         serhiivolynets
Date:           17.08.2020
Description:   
**/
@IsTest
public class SM080_TranslateTest
{
	@IsTest
	public static void testIt()
	{
		Test.startTest();
		system.debug(SM080_Translate.translate('Привет! Я - Сергей!'));
		
		SM010_Utils.saveTran();
		Test.stopTest();
	}

}