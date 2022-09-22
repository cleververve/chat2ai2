/**
 * @author: SEV@3cconsult.dk
 * @date: 2022-01-01
 * @functionality: class receives SOQL text, executes soql  and deletes all records which are in results
 * @bizpurpose: ---
 * @relatedobject: ---
 * */

global class DM013_Cleaner implements Database.Batchable<SObject>
{
	public String sQueryParam;
	/**
	 * @param sQuery - SOQL text
	 * @functionality: constructor
	 * @bizpurpose:
	 * @changeLog:
	 *
	 * @author vly@3cconsult.dk
	 * @status: done
	 *
	 * @date 2016-09-25
	 */
	global DM013_Cleaner(String sQuery)
	{
		sQueryParam = sQuery;
	}


	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		System.debug('starting DM013_Cleaner_Batch: '+sQueryParam);
		return Database.getQueryLocator(sQueryParam);
	}

	global void execute(Database.BatchableContext BC, List<SObject> lDelete)
	{
		Database.delete(lDelete,false);
		System.debug('finished DM013_Cleaner_Batch: deleted '+ lDelete.size()+ ' records');
	}

	global void finish(Database.BatchableContext BC)
	{
	}

}
