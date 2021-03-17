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

	@IsTest
	public static void testIt2()
	{
		FlowUtils2 par = new FlowUtils2();
		par.sEntities = '{"aaa":"bbb"}';
		par.sEntityName = 'aaa';
		FlowUtils2.getEntityString(new list<FlowUtils2>{par});
	}


	@IsTest
	public static void testIt3()
	{
		FlowUtils2 par = new FlowUtils2();
		par.sEntities = '{"aaa":{"value":"Egypt"}}';
		par.sEntityName = 'aaa';
		FlowUtils2.getEntityString(new list<FlowUtils2>{par});
	}
}
