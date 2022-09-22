/**
Author:         serhiivolynets
Date:           29.07.2022
Description:   
**/

global class SM097_GoogleSheetSchedule implements Schedulable
{

	global void execute(SchedulableContext param1)
	{
		SM097_GoogleSheet.initSheet();
	}
}
