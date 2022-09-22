/**
Author:         serhiivolynets
Date:           29.07.2022
Description:   
**/

public class SM097_GoogleSheetJob implements Queueable
{
	public void execute(QueueableContext param1)
	{
		Database.executeBatch(new SM097_GoogleSheetsProdExportBatch());
	}

}
