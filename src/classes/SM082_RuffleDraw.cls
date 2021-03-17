/**
 * Author:         serhiivolynets
 * Date:           31.01.2021
 * Description:
 **/
@RestResource(urlMapping='/rafleDraw/*')
global class SM082_RuffleDraw
{
	global static void start(id drawId)
	{
		start2(drawId);
	}
	global static string start2(id drawId)
	{

		Savepoint sp;
		string sRet = '';
		try
		{


			Ruffle_Draw__c rec =
			[
					SELECT id,CVCH__Winners__c,CVCH__Number_of_Winers_Created__c,CVCH__Type__c
					from Ruffle_Draw__c
					where id = :drawId
			];
			list<AggregateResult> lres = null;

			if (rec.CVCH__Type__c == 'Global')
			{
				lres =
				[

						SELECT count(id)
						from Ruffle_Draw_Ticket__c
						where
//							Ruffle_Draw__c = :drawId and
						CVCH__Won_Flag__c <> true and
						CVCH__Status__c = 'Valid'
				];
			}
			else
			{
				lres =
				[
						SELECT count(id)
						from Ruffle_Draw_Ticket__c
						where Ruffle_Draw__c = :drawId and CVCH__Won_Flag__c <> true and CVCH__Status__c = 'Valid'
						group by Ruffle_Draw__c
				];
			}

			sp = Database.setSavepoint();

			if (lres.size() > 0)
			{
				integer itickets = (integer) lres[0].get('expr0');
				integer cnt = integer.valueOf(rec.CVCH__Winners__c) - integer.valueOf(rec.CVCH__Number_of_Winers_Created__c);
				if (cnt > 90) cnt = 90;

				for (integer i = 0; i < cnt; i++)
				{
					if (itickets <= 0) throw new MyException('Not enough candidates');
					integer ind = Integer.valueof((Math.random() * itickets));
					Ruffle_Draw_Ticket__c ticket = null;
					if (rec.CVCH__Type__c == 'Global')
					{
						ticket =
						[
								select id
								from Ruffle_Draw_Ticket__c
								where
//							Ruffle_Draw__c = :drawId and
								Won_Flag__c <> true and
								CVCH__Status__c = 'Valid'
								limit 1
								offset :ind
						];
					}
					else
					{
						ticket =
						[
								select id
								from Ruffle_Draw_Ticket__c
								where
								Ruffle_Draw__c = :drawId and
								Won_Flag__c <> true and
								CVCH__Status__c = 'Valid'
								limit 1
								offset :ind
						];
					}
					ticket.CVCH__Ruffle_Draw_Won__c = drawId;
					ticket.Won_Flag__c = true;
					ticket.Winner_Number__c = i + 1 + integer.valueOf(rec.CVCH__Number_of_Winers_Created__c);
					update ticket;
					itickets -= 1;
//					if(true)
//						throw new MyException('ha-ha-ha!');
				}
				rec.CVCH__Number_of_Winers_Created__c += cnt;
				update rec;
			}
		}catch(MyException me)
		{
			sRet = me.getMessage();
			if(sp != null)
				Database.rollback(sp);
		}catch(Exception e)
		{
			sRet = e.getMessage()+ ' '+e.getStackTraceString();
			if(sp != null)
				Database.rollback(sp);
		}
		return sRet;
	}

	private Id drawId;

	global SM082_RuffleDraw(ApexPages.StandardController stdController)
	{
		drawId = stdController.getId();
	}

	global PageReference onRun() //controller for fixing transactions page
	{
		try
		{
			string sError = SM082_RuffleDraw.start2(drawId);
			if(sError != '')
			{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, sError));
				return null;
			}

		}
		catch (Exception e)
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));
			return null;
		}
		return new PageReference('/' + drawId);
	}
}
