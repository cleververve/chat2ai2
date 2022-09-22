/**
Author:         serhiivolynets
Date:           14.01.2020
Description:
**/
@isTest
public with sharing class SM000_PostInstallTest
{
	static testMethod void installTest()
	{
		SM000_PostInstall postinstall = new SM000_PostInstall();
		Version ver = new Version(1, 0);
		Test.testInstall(postinstall, null);
	}
}
