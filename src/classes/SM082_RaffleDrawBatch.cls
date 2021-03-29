/**
Author:         serhiivolynets
Date:           23.03.2021
Description:   
**/

global class SM082_RaffleDrawBatch
		implements Database.Batchable<sObject>
{
	id drawId;
	Integer itickets;
	string stype;
	integer actualTicket;
	set<integer>sWinners = new set<integer>();
	Ruffle_Draw__c rec;
	integer winnersCreated =0;
	global SM082_RaffleDrawBatch(id drawId)
	{
		actualTicket = 0;
		this.drawId = drawId;
		rec =
		[
				SELECT Id,CVCH__Winners__c,CVCH__Number_of_Winers_Created__c,CVCH__Type__c
				from Ruffle_Draw__c
				where Id = :drawId
		];
		List<AggregateResult> lres = null;
		sType = rec.CVCH__Type__c;
		if (sType == 'Global')
		{
			lres =
			[
					SELECT count(Id)
					from Ruffle_Draw_Ticket__c
					where
					CVCH__Won_Flag__c <> true and
					CVCH__Status__c = 'Valid'
			];
		}
		else
		{
			lres =
			[
					SELECT count(Id)
					from Ruffle_Draw_Ticket__c
					where Ruffle_Draw__c = :drawId and CVCH__Won_Flag__c <> true and CVCH__Status__c = 'Valid'
					group by Ruffle_Draw__c
			];
		}
		itickets = (Integer) lres[0].get('expr0');


		Integer cnt = Integer.valueOf(rec.CVCH__Winners__c) - Integer.valueOf(rec.CVCH__Number_of_Winers_Created__c);
		if(itickets < cnt)
			throw new MyException('Not enough candidates');
		while (cnt > 0)
		{
			if (itickets <= 0)
				throw new MyException('Not enough candidates');
			Integer ind = Integer.valueOf((Math.random() * itickets));
			if (!sWinners.contains(ind))
			{
				sWinners.add(ind);
				itickets -= 1;
				cnt -= 1;
			}
		}
		System.debug(sWinners);
		System.debug('sWinners');
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		string sQuery = 'SELECT Id from Ruffle_Draw_Ticket__c where CVCH__Won_Flag__c <> true and CVCH__Status__c = \'Valid\'';

		if (sType != 'Global')
			sQuery = sQuery + ' AND  Ruffle_Draw__c = :drawId';
		return Database.getQueryLocator(sQuery);

	}

	global void execute(Database.BatchableContext BC, List<sobject> lRec)
	{
		map<id,Ruffle_Draw_Ticket__c>mUpd = new map<id,Ruffle_Draw_Ticket__c>();

		for (sobject obj : lRec)
		{
			Ruffle_Draw_Ticket__c ticket = (Ruffle_Draw_Ticket__c) obj;
			if (sWinners.contains(actualTicket))
			{
				ticket.Won_Flag__c = true;
				ticket.Winner_Number__c = (++winnersCreated) + Integer.valueOf(rec.CVCH__Number_of_Winers_Created__c);
				ticket.Ruffle_Draw_Won__c  = rec.Id;
				mUpd.put(ticket.Id,ticket);

			}
			actualTicket++;
		}
		if(!mUpd.isEmpty())
			update  mUpd.values();
	}

	global void finish(Database.BatchableContext BC)
	{
		rec.CVCH__Number_of_Winers_Created__c = rec.Winners__c;
		update rec;

	}
}
