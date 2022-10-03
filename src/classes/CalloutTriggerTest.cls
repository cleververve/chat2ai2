/**
Author:         serhiivolynets
Date:           28.09.2022
Description:   
**/
@IsTest
public with sharing class CalloutTriggerTest
{
	@IsTest
	public static void testCalloutTrigger()
	{
		CallOut__c call = new CallOut__c(Request__c='{"message_type":"custom","custom":{"template":{"components":[{"parameters":[{"text":"Customer","type":"text"}],"type":"body"}],"language":{"code":"en","policy":"deterministic"},"name":"digital_concierge","namespace":"73324c6e_6ca7_7cb7_9d30_36467e93db20"},"type":"template"},"channel":"whatsapp","from":"97144099000","to":"971507093835"}');
		Test.startTest();
		insert call;
				Test.stopTest();
		CallOut__c call2 = [select id,Template_Name__c,Template_Namespace__c,To__c from CallOut__c where id = :call.Id];
		System.assertEquals(call2.Template_Name__c,'digital_concierge' );
		System.assertEquals(call2.Template_Namespace__c,'73324c6e_6ca7_7cb7_9d30_36467e93db20' );
		System.assertEquals(call2.To__c,'971507093835' );
	}

}
