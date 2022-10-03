/**
Author:         serhiivolynets
Date:           28.09.2022
Description:   
**/

trigger CalloutTrigger on CallOut__c (before insert, before update)
{

	if(Trigger.isBefore && Trigger.isInsert)
	{
		for(CallOut__c rec : Trigger.new)
		{
			String req = rec.Request__c;
			try
			{
				object payload = JSON.deserializeUntyped(req);
				rec.To__c = (String)JPath.get0(payload, '/to');
				rec.Template_Name__c = (String)JPath.get0(payload, '/custom/template/name');
				rec.Template_Namespace__c = (String)JPath.get0(payload, '/custom/template/namespace');
			}catch(Exception e){}
		}
	}
}
