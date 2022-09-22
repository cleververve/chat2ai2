/**
Author:         serhiivolynets
Date:           08.07.2022
Description:   
**/

public class SM096_runSurveyFlow implements Database.Batchable<SObject>, Database.AllowsCallouts
{

	public void execute(Database.BatchableContext param1, List<SObject> param2)
	{
		try
		{
			for (SObject obj : param2)
			{
				Visitor__c vis = (Visitor__c) obj;
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', vis.Id);
				String sFlow = SM010_Utils.getChat2aiValue2('Survey Flow');
				if (sFlow != '')
				{
					System.debug('Survey Flow: ' + JSON.serialize(params));
					SM010_Utils.getFlow(sFlow, vis.Chat_Number__c, params).start();
				}
			}
		}
		catch (Exception e)
		{
			system.debug('Error: ' + e.getMessage());
		}
		SM005_Logs.save();
	}

	public void finish(Database.BatchableContext param1)
	{
	}


	public Iterable<SObject> start(Database.BatchableContext param1)
	{
		String sQuery = 'SELECT Id FROM CVCH__Visitor__c where CVCH__Survey_Required_Flag__c = true and CVCH__Last_Interaction_Date__c <  LAST_N_DAYS:' + DM013_Cleaner_Job.getInteger('Survey days', 1);
		return Database.getQueryLocator(sQuery);
	}

}
