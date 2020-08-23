/**
Author:         serhiivolynets
Date:           23.08.2020
Description:   
**/
@IsTest
public with sharing class FlowUtilsTest
{
	@IsTest
	public static void testIt()
	{
		FlowUtils.getEntityParam par = new FlowUtils.getEntityParam();
		par.sEntities = '{"aaa":"bbb"}';
		par.sEntityName = 'aaa';
		FlowUtils.getEntityString(new list<FlowUtils.getEntityParam>{par});
	}
}