/**
Author:         serhiivolynets
Date:           15.07.2020
Description:   
**/

global class MessageOptions implements iMessage
{
	@AuraEnabled @InvocableVariable global string sMessage;
	@AuraEnabled @InvocableVariable global id visitorId;
	@AuraEnabled @InvocableVariable global string content;
	@AuraEnabled @InvocableVariable global string sType;
	public string sFieldName;
	public string sFlow;
    public string sConfirmMessage;
	public list<CarouselItem> lItems = new list<CarouselItem>();
	public map<string, Option> mOptions = new map<string, Option>();
	public list<Option> lOptions = new list<Option>();

	public string getBody()
	{
		list<string> lRet = new list<string>();
		lRet.add(sMessage);
		for (Option opt : mOptions.values())
		{
			lRet.add(opt.getBody());
		}
		return string.join(lRet, '\n');
	}

	public void addNonEmpty(set<string>sVal, string val)
	{
		if (val != null && val != '')
		{
			sVal.add(val);
		}
	}
	public string translate(map<string, string>mTr, string val)
	{
		string tr = mTr.get(val);
		if (tr == '' || tr == null)
			return val;
		return tr;
	}
	public void translate(string slang)
	{
		if (slang == null || slang == '' || slang == 'en')
			return;

		set<string>sTr = new set<string>();
		addNonEmpty(sTr, sMessage);

		if (!lItems.isEmpty())
		{
			for (CarouselItem it : lItems)
			{
				addNonEmpty(sTr, it.title);
				addNonEmpty(sTr, it.subtitle);
				if (it.button1 != null)
					addNonEmpty(sTr, it.button1.sLabel);
				if (it.button2 != null)
					addNonEmpty(sTr, it.button2.sLabel);
				if (it.button3 != null)
					addNonEmpty(sTr, it.button3.sLabel);
			}
		}
		else if (!mOptions.isEmpty())
		{
			for (string sKey : mOptions.keySet())
			{
				Option opt = mOptions.get(sKey);
				if (opt != null)
					addNonEmpty(sTr, opt.sLabel);
			}
		}
		if (!sTr.isEmpty())
		{
			map<string, string> mTr = SM010_Utils.translateBatch(sTr, slang);
			if (!mTr.isEmpty())
			{
				sMessage = translate(mTr, sMessage);
				if (!lItems.isEmpty())
				{
					for (CarouselItem it : lItems)
					{
						it.title = translate(mTr, it.title);
						it.subtitle = translate(mTr, it.subtitle);
						if (it.button1 != null)
							it.button1.sLabel = translate(mTr, it.button1.sLabel);
						if (it.button2 != null)
							it.button2.sLabel = translate(mTr, it.button2.sLabel);
						if (it.button3 != null)
							it.button3.sLabel = translate(mTr, it.button3.sLabel);
					}
				}
				else if (!mOptions.isEmpty())
				{
					for (string sKey : mOptions.keySet())
					{
						Option opt = mOptions.get(sKey);
						if (opt != null)
							opt.sLabel = translate(mTr, opt.sLabel);
					}
				}
			}
		}
	}
	public static map<string,Option> addOptions(map<string,Option>mOptions, list<Option>lOptions)
	{
		integer i=1;
		for (Option opt : lOptions)
		{
			system.debug('sendWF.option = ' + opt);
			if (opt != null && opt.sLabel != null && opt.sLabel != '')
			{
				opt.iNumber = i;
				mOptions.put(''+i, opt);
				i += 1;
			}
		}
		return mOptions;
	}

	public void send(CVCH__Visitor__c v)
	{
		string sFrom = v.CVCH__Chat_Number__c;
		string sTo = v.CVCH__Id__c;
		if(mOptions.isEmpty() && !lOptions.isEmpty())
			mOptions = MessageOptions.addOptions(mOptions,lOptions);
		translate(v.CVCH__language__c);
		if (sType == 'Carousel')
		{
			integer i=1;
			if (mOptions.isEmpty())
			{
				for (CarouselItem it : lItems)
				{
					if (it.button1 != null && it.button1.sLabel != '' && it.button1.sLabel != null)
					{
						it.button1.iNumber = i;
						mOptions.put('' + i, it.button1);
						i += 1;
					}
					if (it.button2 != null && it.button2.sLabel != '' && it.button2.sLabel != null)
					{
						it.button2.iNumber = i;
						mOptions.put('' + i, it.button2);
						i += 1;
					}
					if (it.button3 != null && it.button3.sLabel != '' && it.button3.sLabel != null)
					{
						it.button3.iNumber = i;
						mOptions.put('' + i, it.button3);
						i += 1;
					}
				}
			}

			SM042_NexmoOut2.sendCarousel(this, sTo, sFrom);

//			SM042_NexmoOut2.sendText(v.Id__c, sMessage, sFrom);
//			for (string sKey : mOptions.keySet())
//			{
//				pause(800);
//				Option opt = mOptions.get(sKey);
//				SM042_NexmoOut2.sendImage(sTo, sFrom,  opt.getBody(),opt.sURL);
////				SM042_NexmoOut2.sendCarousel(sTo, sFrom, opt.sURL, opt.getBody());
//			}
		}
		else
		{
			system.debug('start MessageOptions.send ' + getBody());
			SM042_NexmoOut2.sendText(sTo, getBody(), sFrom);
		}

		if (!mOptions.isEmpty() || this.sFieldName != null)
		{
			system.debug('mOptions=' + mOptions);
			v.CVCH__Context__c = JSON.serialize(this);
			system.debug('Context__c= ' + v.CVCH__Context__c);
		}
		SM010_Utils.saveTran();
	}

	public MessageOptions(SM080_QnA.QnAResponse respQnA)
	{
		this.sMessage = respQnA.sAnswer;
		integer i = 1;
		for (SM080_QnA.QnAPrompt pro : respQnA.prompts)
		{
			this.mOptions.put('' + i, new Option(pro.displayText, i, 'QnA', '' + pro.qnaId));
		}
	}

	global MessageOptions()
	{
		this.sMessage = '';
	}

	global MessageOptions(id visitorId)
	{
		this.visitorId = visitorId;
		this.sMessage = '';
	}


	global class OptionsJSON
	{
		public string sType;
		public list<Option> a;
	}

	global class CarouselJSON
	{
		public list<CarouselItem> items;
	}

	@InvocableMethod(label='Send Message with Options' description='Send Message with Options')
	global static void sendWF(list<MessageOptions> messages)
	{
		system.debug('sendWF.messages=' + messages);
		set<id>sVisitorIds = new set<id>();

		for (MessageOptions req : messages)
		{

			sVisitorIds.add(req.visitorId);

			if (req.content != '' && req.content != null)
			{
				integer i = 1;
				if (req.sType == 'Carousel')
				{
					req.lItems = ((MessageOptions.CarouselJSON) JSON.deserialize(req.content, MessageOptions.CarouselJSON.class)).items;
					for (CarouselItem it : req.lItems)
					{
						if (it.button1 != null && it.button1.sLabel != '' && it.button1.sLabel != null)
						{
							it.button1.iNumber = i;
							req.mOptions.put('' + i, it.button1);
							i += 1;
						}
						if (it.button2 != null && it.button2.sLabel != '' && it.button2.sLabel != null)
						{
							it.button2.iNumber = i;
							req.mOptions.put('' + i, it.button2);
							i += 1;
						}
						if (it.button3 != null && it.button3.sLabel != '' && it.button3.sLabel != null)
						{
							it.button3.iNumber = i;
							req.mOptions.put('' + i, it.button3);
							i += 1;
						}
					}
				}
				else
				{
					MessageOptions.OptionsJSON msg = (MessageOptions.OptionsJSON) JSON.deserialize(req.content, MessageOptions.OptionsJSON.class);
					if (msg.sType != '' && msg.sType != null)
						req.sType = msg.sType;
					req.mOptions = MessageOptions.addOptions(req.mOptions,msg.a);
					system.debug('mOptions = ' + req.mOptions);
				}
			}
		}
		map<id, CVCH__Visitor__c> mUpdate = new map<id, CVCH__Visitor__c>();

		map<id, CVCH__Visitor__c> mVisitorsByIds = new map<id, CVCH__Visitor__c>(DM080_Visitor.getRecords(sVisitorIds));
		for (MessageOptions req : messages)
		{
			CVCH__Visitor__c vis = mVisitorsByIds.get(req.visitorId);
			if (vis != null)
				req.send(vis);
			mUpdate.put(vis.Id, vis);
		}
		system.debug('sendWF update = ' + mUpdate.values());
		update mUpdate.values();
	}

//	public static MessageOptions inputMessage(id visitorId, string sMessage, string sFlow, string sFieldName)
//	{
//		MessageOptions mo = new MessageOptions(visitorId);
//		mo.sType = 'Input';
//		mo.sMessage = sMessage;
//		mo.sFlow = sFlow;
//		mo.sFieldName = sFieldName;
//		return mo;
//	}

	public static MessageOptions message(id visitorId, string sMessage)
	{
		MessageOptions mo = new MessageOptions(visitorId);
		mo.sMessage = sMessage;
		return mo;
	}

}
