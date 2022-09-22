/**
Author:         serhiivolynets
Date:           06.07.2022
Description:   
**/

global class DM013_Cleaner_Job implements Schedulable
{

	public void execute(SchedulableContext param1)
	{
		Database.executeBatch(new CVCH.DM013_Cleaner('SELECT id from CVCH__CallOut__c where CreatedDate <  LAST_N_DAYS:'+CVCH.DM013_Cleaner_Job.getInteger('Callout lifetime',7)),200);
		Database.executeBatch(new CVCH.DM013_Cleaner('SELECT id from CVCH__NexmoMessage__c where CreatedDate <  LAST_N_DAYS:'+CVCH.DM013_Cleaner_Job.getInteger('NexmoMessage lifetime',7)),200);
		Database.executeBatch(new CVCH.DM013_Cleaner('SELECT id from CVCH__Conversation__c where CreatedDate <  LAST_N_DAYS:'+CVCH.DM013_Cleaner_Job.getInteger('Conversation lifetime',7)),200);
		Database.executeBatch(new CVCH.DM013_Cleaner('SELECT id from CVCH__Ruffle_Draw_Ticket__c where CreatedDate <  LAST_N_DAYS:'+CVCH.DM013_Cleaner_Job.getInteger('Ruffle_Draw_Ticket lifetime',365)),200);
		Database.executeBatch(new SM096_runSurveyFlow(),1);
	}


	public static Integer getInteger(String sSettingName,Integer iDef)
	{

		Integer iVal = iDef;
		try
		{
			String sVal = SM010_Utils.getChat2aiValue2(sSettingName);
			if(sVal != '' && sVal != null)
				iVal = Integer.valueOf(sVal);
		}catch(Exception e){ }
		return iVal;
	}
}
