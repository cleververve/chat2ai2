/**
Author:         serhiivolynets
Date:           06.07.2022
Description:   
**/
@IsTest
public class DM013_Cleaner_Job_Test
{
	@IsTest
	public static void testSchedule()
	{
		System.schedule('test job','0 0 10 * * ?',new DM013_Cleaner_Job());

	}

}
