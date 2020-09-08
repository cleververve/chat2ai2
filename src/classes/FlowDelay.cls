/**
Author:         serhiivolynets
Date:           27.08.2020
Description:   
**/

global class FlowDelay
{
	@InvocableMethod(label='Delay' description='Delays the flow in milliseconds')
	global static void pause(list<integer> milliseconds)
	{
		if(!milliseconds.isEmpty())
		{
			integer i = milliseconds[0];
			if(i == null)
				i = 1000;
			SM042_NexmoOut2.pause(i);
		}
	}
}