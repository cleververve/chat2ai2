/**
Author:         serhiivolynets
Date:           28.09.2022
Description:   
**/
@IsTest
public with sharing class FlowJPathTest
{
	@IsTest
	public static void testJPath()
	{
		FlowJPath jp = new FlowJPath();
		jp.Payload = '{"message_type":"custom","custom":{"template":{"components":[{"parameters":[{"text":"Customer","type":"text"}],"type":"body"}],"language":{"code":"en","policy":"deterministic"},"name":"digital_concierge","namespace":"73324c6e_6ca7_7cb7_9d30_36467e93db20"},"type":"template"},"channel":"whatsapp","from":"97144099000","to":"971507093835"}';
		jp.Path1 = '/custom/template/name';
		jp.Path2 = '/custom/template/namespace';
		jp.Path3 = '/to';

		Test.startTest();
		List<FlowJPath.FlowJPathReturn>lRet = FlowJPath.parse(new List<FlowJPath> {jp,new FlowJPath()});
		Test.stopTest();
		FlowJPath.FlowJPathReturn ret = lRet[0];
		System.assertEquals(ret.Value1,'digital_concierge' );
		System.assertEquals(ret.Value2,'73324c6e_6ca7_7cb7_9d30_36467e93db20' );
		System.assertEquals(ret.Value3,'971507093835' );
	}
}
