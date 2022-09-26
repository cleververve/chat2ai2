/**
Author:         serhiivolynets
Date:           23.09.2022
Description:   
**/

trigger FlowOrchEvent on FlowOrchestrationEvent (before insert, before update)
{

	for(FlowOrchestrationEvent rec: Trigger.new)
	{
		system.debug(JSON.serialize(rec));
	}

}
