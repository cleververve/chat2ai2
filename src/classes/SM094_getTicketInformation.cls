/**
 * Author:         serhiivolynets
 * Date:           15.09.2021
 * Description:
 **/
@RestResource(urlMapping='/getCustomerInformation/*')
global class SM094_getTicketInformation
{
	global string full_name;
	global string mobile_number;
	global string nationality;
	global string ticket_number;
	global string errorMessage;
	@HttpGet
	global static SM094_getTicketInformation getIt()
	{
		SM094_getTicketInformation ret = new SM094_getTicketInformation();
		try
		{

			String sTicketNumber = RestContext.request.params.get('TicketNumber');
			if (sTicketNumber == null || sTicketNumber == '')
				throw new CVCH.MyException('TicketNumber parameter can not be empty.');
			string sQ = 'SELECT Id, CVCH__Short_Id__c ';
			if (!Test.isRunningTest())
				sQ = sQ + ' ,Visitor_Name__c, Visitor_Phone_Number__c,Nationality__c ';
			sQ = sQ + ' FROM CVCH__Ruffle_Draw_Ticket__c where CVCH__Short_Id__c = :sTicketNumber';

			list<sobject> lTickets = Database.query(sQ);

			if (lTickets.isEmpty())
				throw new CVCH.MyException('Can not find the ticket with the short id ' + sTicketNumber);
			if (lTickets.size() > 1)
				throw new CVCH.MyException('There are multiple tickets with the short id ' + sTicketNumber);
			sobject sobj = lTickets[0];
			ret.ticket_number = (string) sobj.get('CVCH__Short_Id__c');
			if (!Test.isRunningTest())
			{
				ret.full_name = (string) sobj.get('Visitor_Name__c');
				ret.mobile_number = (string) sobj.get('Visitor_Phone_Number__c');
				ret.nationality = (string) sobj.get('Nationality__c');
			}
		}
		catch (Exception e)
		{
			ret.errorMessage = e.getMessage();
		}
		return ret;
	}

}
