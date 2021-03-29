/**
 * Author:         serhiivolynets
 * Date:           31.01.2021
 * Description:
 **/
@RestResource(urlMapping='/rafleDraw/*')
global class SM082_RuffleDraw
{
	global static void start(Id drawId)
	{
		start2(drawId);
	}
	global static String start2(Id drawId)
	{
		Savepoint sp;
		String sRet = '';
		try
		{
			Ruffle_Draw__c rec =
			[
					SELECT Id,CVCH__Winners__c,CVCH__Number_of_Winers_Created__c,CVCH__Type__c
					from Ruffle_Draw__c
					where Id = :drawId
			];
			List<AggregateResult> lres = null;

			if (rec.CVCH__Type__c == 'Global')
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
			Integer itickets = (Integer) lres[0].get('expr0');
			if (itickets > 45000)
			{
				Database.executeBatch(new SM082_RaffleDrawBatch(drawId));
			}
			else
			{
				List<Ruffle_Draw_Ticket__c> lTick ;

				if (rec.CVCH__Type__c == 'Global')
				{
					lTick =
					[
							SELECT Id
							from Ruffle_Draw_Ticket__c
							where
							CVCH__Won_Flag__c <> true and
							CVCH__Status__c = 'Valid'
					];
				}
				else
				{
					lTick =
					[
							SELECT Id
							from Ruffle_Draw_Ticket__c
							where Ruffle_Draw__c = :drawId and CVCH__Won_Flag__c <> true and CVCH__Status__c = 'Valid'
					];
				}
				sp = Database.setSavepoint();

				Integer itickets = lTick.size();

				Integer cnt = Integer.valueOf(rec.CVCH__Winners__c) - Integer.valueOf(rec.CVCH__Number_of_Winers_Created__c);
				if (cnt > 90)
					cnt = 90;
				for (Integer i = 0; i < cnt; i++)
				{
					if (itickets <= 0) throw new MyException('Not enough candidates');
					Integer ind = Integer.valueOf((Math.random() * itickets));

					Ruffle_Draw_Ticket__c ticket = null;
					ticket = lTick[ind];
					ticket.CVCH__Ruffle_Draw_Won__c = drawId;
					ticket.Won_Flag__c = true;
					ticket.Winner_Number__c = i + 1 + Integer.valueOf(rec.CVCH__Number_of_Winers_Created__c);
					update ticket;
					itickets -= 1;
				}
				rec.CVCH__Number_of_Winers_Created__c += cnt;
				update rec;
			}
		}
		catch (MyException me)
		{
			sRet = me.getMessage();if (sp != null)Database.rollback(sp);
		}
		catch (Exception e)
		{
			sRet = e.getMessage() + ' ' + e.getStackTraceString();if (sp != null)Database.rollback(sp);
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
			String sError = SM082_RuffleDraw.start2(drawId);
			if (sError != '')
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, sError));return null;
			}

		}
		catch (Exception e)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + ' ' + e.getStackTraceString()));return null;
		}
		return new PageReference('/' + drawId);
	}
}
