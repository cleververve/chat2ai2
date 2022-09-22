/**
Author:         serhiivolynets
Date:           06.07.2022
Description:   
**/

public with sharing class SM000_PostInstall implements InstallHandler
{
	@Future(Callout=true)
	public static void scheduleJobs()
	{
		try
		{
			String sJobName = 'chat2ai2 job';
			List<CronTrigger> lTr = [SELECT Id,CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = :sJobName];
			if (lTr.isEmpty())
			{
				System.schedule(sJobName, '0 0 * * * ?', new CVCH.DM013_Cleaner_Job());
			}

		}
		catch (Exception e)
		{
		}
	}

	public void onInstall(InstallContext context)
	{
		SM000_PostInstall.scheduleJobs();
	}
}
