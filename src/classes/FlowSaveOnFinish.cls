/**
Author:         serhiivolynets
Date:           19.07.2022
Description:   
**/

global with sharing class FlowSaveOnFinish
{
	@InvocableMethod(label='Save on finish' description='Save on finish')
	global static void save()
	{
		SM005_Logs.save();
	}
}
