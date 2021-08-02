/**
Author:         serhiivolynets
Date:           20.04.2021
Description:   
**/
@IsTest
public with sharing class SM092_JPathTest
{
	@IsTest
	public static void testIt()
	{
		SM092_JPath.JPathInput inp = new SM092_JPath.JPathInput();
		inp.rawJson ='{"aaa":"aaa"}';
		inp.sPath= '/aaa';
		SM092_JPath.getValue(new list<SM092_JPath.JPathInput>{inp});
	}
}