/**
Author:         serhiivolynets
Date:           31.01.2021
Description:
**/
global class SM085_ruffleDrawBatch implements
				Schedulable
{
	global void execute(SchedulableContext c)
	{
		CVCH__Ruffle_Draw__c d =
		[
				SELECT id
				from CVCH__Ruffle_Draw__c
				where CVCH__Draw_Date__c = TODAY and CVCH__Complete_Flag__c <> true limit 1
		];
		if(d != null)
			SM082_RuffleDraw.start(d.Id);
	}
}