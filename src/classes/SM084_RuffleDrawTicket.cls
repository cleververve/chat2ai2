/**
Author:         serhiivolynets
Date:           31.01.2021
Description:   
**/

global class SM084_RuffleDrawTicket
{
    global class TicketInput
    {
        @AuraEnabled @InvocableVariable global id visitorId;
        @AuraEnabled @InvocableVariable global date ticketDate;
        @AuraEnabled @InvocableVariable global integer numberOfTickets;
    }

    global class TicketOutput
    {
        @AuraEnabled @InvocableVariable global string ticketNumber;
        @AuraEnabled @InvocableVariable global date ticketDate;
    }


    @InvocableMethod(label='Ruffle Draw Ticket' description='Takes current/desired location and gives link to the google maps')
    global static list<TicketOutput> getTicket(list<TicketInput> lInput)
    {
        list<TicketOutput> lRet = new list<TicketOutput>();
        if (lInput.size() > 0)
        {
            list<CVCH__Ruffle_Draw_Ticket__c> lIns = new list<CVCH__Ruffle_Draw_Ticket__c>();
            Date dt = lInput[0].ticketDate;
            dt = Date.today();

            Datetime dt1 = Datetime.newInstance(dt.year(), dt.month(), dt.day());
            list<CVCH__Ruffle_Draw__c> lrd =

            [
                    SELECT id
                    from CVCH__Ruffle_Draw__c
                    where Draw_Date__c > :dt1
                    order by Draw_Date__c
                    limit 1
            ];

            if (lrd.isEmpty())
                throw new MyException('Can not find next ruffle draw for date ' + dt);
            CVCH__Ruffle_Draw__c rd =lrd[0];
            for (TicketInput inp : lInput)
            {
                if (inp.numberOfTickets == null || inp.numberOfTickets < 1)
                    inp.numberOfTickets = 1;
                for (integer i = 0; i < inp.numberOfTickets; i++)
                {
                    CVCH__Ruffle_Draw_Ticket__c ticket = new CVCH__Ruffle_Draw_Ticket__c();
                    ticket.Ruffle_Draw__c = rd.Id;
                    ticket.Visitor__c = inp.visitorId;
                    lIns.add(ticket);
                }
            }
            insert lIns;
            set<id> sIds = new map<id, CVCH__Ruffle_Draw_Ticket__c>(lIns).keySet();
            map<id, CVCH__Ruffle_Draw_Ticket__c> mIns = new map<id, CVCH__Ruffle_Draw_Ticket__c>([
                    select id,Short_Id__c,Ruffle_Draw__r.Draw_Date__c
                    from CVCH__Ruffle_Draw_Ticket__c
                    where id in :sIds
            ]);
            integer j = 0;
            for (TicketInput inp : lInput)
            {
                TicketOutput ret = new TicketOutput();
                ret.ticketNumber = '';
				list<string>ltickets = new list<string>();
                for (integer i = 0; i < inp.numberOfTickets; i++)
                {
                    CVCH__Ruffle_Draw_Ticket__c val = mIns.values()[j];
                    ret.ticketDate = Date.valueOf(val.Ruffle_Draw__r.Draw_Date__c);
					ltickets.add(val.Short_Id__c);
					j++;
                }
				ret.ticketNumber = string.join(ltickets,',');
                lRet.add(ret);
            }
        }
        return lRet;
    }
}
