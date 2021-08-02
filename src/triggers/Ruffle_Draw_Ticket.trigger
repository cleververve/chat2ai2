trigger Ruffle_Draw_Ticket on Ruffle_Draw_Ticket__c (after insert) {

	if(Trigger.isAfter && Trigger.isInsert)
	{
		list<Ruffle_Draw_Ticket__c>lUpdate = new list<Ruffle_Draw_Ticket__c>();
		for(Ruffle_Draw_Ticket__c tick : Trigger.new)
		{
			Ruffle_Draw_Ticket__c upd = new Ruffle_Draw_Ticket__c(id = tick.Id, CVCH__Short_Id__c =  SM010_Utils.encodeId(tick.Name));
			upd.CVCH__Hash__c = EncodingUtil.base64Encode(Crypto.generateDigest('SHA256', Blob.valueOf(upd.Short_Id__c+':'+tick.Visitor__c)));
			lUpdate.add(upd);
		}
		update lUpdate;
	}
}