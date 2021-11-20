global class SM042_NexmoOut2 implements Queueable
{

	global id messId;

	global static string getNexmoURL()
	{
		string sRet = SM010_Utils.getChat2aiValue2('Nexmo URL');
		if (sRet == '' || sRet == null)
			sRet = 'https://api.nexmo.com/v0.1/messages';
		return sRet;
	}

	global static string getNexmoURLV1()
	{
		string sRet = SM010_Utils.getChat2aiValue2('Nexmo URLV1');
		if (sRet == '' || sRet == null)
			sRet = 'https://api.nexmo.com/v1/messages';
		return sRet;
	}


	global SM042_NexmoOut2(id messId0)
	{
		messId = messId0;
	}
	global static void pause(integer delayInMilliseconds)
	{
		Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
		while (System.now().getTime() - startingTime < delayInMilliseconds)
		{
			// Do nothing until desired delay has passed
		}
	}

	global void execute(QueueableContext context)
	{
		SM042_NexmoOut2.executeF(messId);
	}

	global static void send(CVCH__NexmoMessage__c mess)
	{
		system.debug(mess);

		if (mess.CVCH__Channel__c == 'Azure')
		{
			if (mess.CVCH__Type__c == 'Carousel')
			{
				MessageOptions mo = (MessageOptions) JSON.deserializeStrict(mess.CVCH__JSON__c, MessageOptions.class);
				SM081_Azure.sendCarousel(mess, mo.lItems);
			}
			else if (mess.CVCH__Type__c == 'Options')
			{
				MessageOptions mo = (MessageOptions) JSON.deserializeStrict(mess.CVCH__JSON__c, MessageOptions.class);
				SM081_Azure.sendOptions(mess, mo);
			}
			else
					SM081_Azure.sendText(mess);
		}
		else
		{
			if (mess.CVCH__Type__c == 'Carousel')
			{
				MessageOptions mo = (MessageOptions) JSON.deserializeStrict(mess.CVCH__JSON__c, MessageOptions.class);
				if (mo.sMessage != null && mo.sMessage != '')
				{
					SM042_nexmoOut4.sendText(mess.CVCH__To__c, mess.CVCH__From__c, mo.sMessage);
					SM042_NexmoOut2.pause(800);
				}
				for (CarouselItem it : mo.lItems)
				{
					if (it.imageURL != null && it.imageURL != '')
					{
						try
						{
							SM042_NexmoOut2.sendCarousel(mess.CVCH__To__c, mess.CVCH__From__c, it.imageURL, it.getBody());
							SM042_NexmoOut2.pause(800);
						}
						catch (Exception e)
						{
							SM042_nexmoOut4.sendText(mess.CVCH__To__c, mess.CVCH__From__c, e.getMessage());
						}
					}
				}
			}
			else if (mess.CVCH__Type__c == 'Custom')
				SM042_nexmoOut4.sendCustom(mess.CVCH__To__c, mess.CVCH__From__c, mess.CVCH__FullText__c);
			else if (mess.CVCH__Type__c == 'Custom2')
				SM042_nexmoOut4.sendCustom2(mess.CVCH__To__c, mess.CVCH__From__c, mess.CVCH__FullText__c);
			else
					SM042_nexmoOut4.sendText(mess.CVCH__To__c, mess.CVCH__From__c, mess.CVCH__FullText__c);
		}
	}

	@future(Callout =true)
	global static void executeF(id messId)
	{
		CVCH__NexmoMessage__c mess =
		[
				select id,CVCH__Text__c,CVCH__Status__c,CVCH__FullText__c,
						CVCH__JSON__c,CVCH__Type__c,
						CVCH__From__c,CVCH__From_Name__c,
						CVCH__To__c,CVCH__To_Name__c,
						CVCH__activityId__c,CVCH__conversationId__c,CVCH__conversationName__c,CVCH__Channel__c

				from CVCH__NexmoMessage__c
				where id = :messId
		];
		try
		{
			send(mess);
			mess.Status__c = 'Complete';
		}
		catch (Exception e)
		{
			if (Test.isRunningTest())
				throw e;
			mess.Error_Message__c = e.getMessage() + ' ' + e.getStackTraceString();
			mess.Status__c = 'Error';
		}
		finally
		{
			SM005_Logs.save();
			update mess;
		}
	}


	@future(Callout =true)
	global static void sendOrEnqueueF(id messId)
	{
		CVCH__NexmoMessage__c mess =
		[
				select id,CVCH__Text__c,CVCH__Status__c,CVCH__FullText__c,
						CVCH__JSON__c,CVCH__Type__c,
						CVCH__From__c,CVCH__From_Name__c,
						CVCH__To__c,CVCH__To_Name__c,
						CVCH__activityId__c,CVCH__conversationId__c,CVCH__conversationName__c,CVCH__Channel__c

				from CVCH__NexmoMessage__c
				where id = :messId
		];
		try
		{
			send(mess);
		}
		catch (Exception e)
		{
			SM042_NexmoOut2 job = new SM042_NexmoOut2(mess.id);
			System.enqueueJob(job);
		}
		finally
		{
			SM005_Logs.save();
			update mess;
		}
	}


	global static void sendOrEnqueue(CVCH__NexmoMessage__c mess, Boolean async)
	{
		SM010_Utils.addResponse(mess.FullText__c);
		system.debug(mess);
		if (async == true)
		{
			insert mess;
			sendOrEnqueueF(mess.id);
		}
		else
		{
			try
			{
				SM042_NexmoOut2.send(mess);
				insert mess;
			}
			catch (Exception e)
			{
				system.debug('Err: ' + e.getMessage() + ' ' + e.getStackTraceString());
				insert mess;
				sendOrEnqueueF(mess.id);
			}
		}
	}
	global static void sendText(string sTo, string sText, string sFrom)
	{
		sendText(sTo, sText, sFrom, false);
	}
	global static CVCH__NexmoMessage__c inboundMess;

	global static void setInboundMessage(CVCH__NexmoMessage__c mess)
	{
		inboundMess = mess;
	}
	global static CVCH__NexmoMessage__c initMessage(string sTo, string sFrom)
	{
		CVCH__NexmoMessage__c mess = new CVCH__NexmoMessage__c();
		if (inboundMess != null)
		{
			mess.CVCH__To__c = inboundMess.CVCH__From__c;
			mess.CVCH__To_Name__c = inboundMess.CVCH__From_Name__c;

			mess.CVCH__From__c = inboundMess.CVCH__To__c;
			mess.CVCH__From_Name__c = inboundMess.CVCH__To_Name__c;
			mess.CVCH__conversationId__c = inboundMess.CVCH__conversationId__c;
			mess.CVCH__conversationName__c = inboundMess.CVCH__conversationName__c;
			mess.CVCH__activityId__c = inboundMess.Name;
			mess.CVCH__Channel__c = inboundMess.CVCH__Channel__c;
			mess.CVCH__ChannelId__c = inboundMess.CVCH__ChannelId__c;
		}
		else
		{
			mess.CVCH__From__c = sFrom;
			mess.CVCH__To__c = sTo;
		}
		return mess;
	}
	global static string getInboundChannel()
	{
		if (inboundMess != null)
			return inboundMess.CVCH__Channel__c;
		return '';
	}
	global static void sendText(string sTo, string sText, string sFrom, boolean async)
	{
		CVCH__NexmoMessage__c mess = initMessage(sto, sFrom);

		mess.CVCH__Text__c = sText;
		if (mess.CVCH__Text__c != null && mess.CVCH__Text__c.length() > 254)
			mess.CVCH__Text__c = mess.CVCH__Text__c.substring(0, 254);
		mess.CVCH__FullText__c = sText;
		mess.CVCH__Status__c = 'Queued';
		sendOrEnqueue(mess, async);
	}


	global static void sendCustomText2(string sTo, string sText, string sFrom, boolean async)
	{
		sendCustomText(sTo, sText, sFrom, async, 'Custom2');
	}
	global static void sendCustomText(string sTo, string sText, string sFrom, boolean async)
	{
		sendCustomText(sTo, sText, sFrom, async, 'Custom');
	}


	global static void sendCustomText(string sTo, string sText, string sFrom, boolean async, string sType)
	{
		CVCH__NexmoMessage__c mess = initMessage(sto, sFrom);

		mess.CVCH__Text__c = sText;
		if (mess.CVCH__Text__c != null && mess.CVCH__Text__c.length() > 254)
			mess.CVCH__Text__c = mess.CVCH__Text__c.substring(0, 254);
		mess.CVCH__FullText__c = sText;
		mess.CVCH__Status__c = 'Queued';
		mess.CVCH__Type__c = sType;
		sendOrEnqueue(mess, async);
	}


	global static void sendComplexType(MessageOptions opt, string sto, string sFrom)
	{
		CVCH__NexmoMessage__c mess = initMessage(sto, sFrom);

		if (opt.sType == '' || opt.sType == null)
			mess.CVCH__Type__c = 'Carousel';
		else
				mess.CVCH__Type__c = opt.sType;
		string sText = opt.sMessage;
		if (mess.CVCH__Text__c != null && mess.CVCH__Text__c.length() > 254)
			mess.CVCH__Text__c = mess.CVCH__Text__c.substring(0, 254);
		mess.CVCH__FullText__c = sText;
		mess.CVCH__JSON__c = JSON.serializePretty(opt);
		mess.CVCH__Status__c = 'Queued';

		sendOrEnqueue(mess, opt.async);
	}

	global static map<string, string> getAuthHeader()
	{
		map<string, string> headers = new map <string, string>();
		string token = JWT.getAccessToken();
		string sAuth = 'Bearer ' + token;
		system.debug('sAuth=>' + sAuth);
		headers.put('Authorization', sAuth);
		headers.put('Content-Type', 'application/json');
		return headers;
	}

	global static string getBody(string sTo, string messageText, string sFrom)
	{
		map<string, object> mret = new map<string, object>();
		map<string, string> mFrom = new map<string, string>();
		mFrom.put('type', 'whatsapp');
		mFrom.put('number', sFrom);
		//       mFrom.put('number','447418342138');
		mret.put('from', mFrom);


		map<string, string> mTo = new map<string, string>();
		mTo.put('type', 'whatsapp');
		mTo.put('number', sTo);
		mret.put('to', mTo);

		map<string, object> mMess = new map<string, object>();
		map<string, string> mCont = new map<string, string>();
		mCont.put('type', 'text');
		mCont.put('text', messageText.replaceAll('\n', '%A9%'));
		mMess.put('content', mCont);
		mret.put('message', mMess);
		return JSON.serialize(mret);
	}


	global static void sendText(string sTo, string messageText)
	{
		sendText2(sTo, '97144099000', messageText);
	}

	global static void sendText2(string sTo, string sFrom, string messageText)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request(getNexmoURL(), 'POST', getAuthHeader(), getBody(sTo, messageText, sFrom), 'NexmoOut2', null);
	}


	@future(callout=true)
	global static void sendCarouselAsync(string sTo, string sFrom, string imageurl, string caption)
	{
//		sendCarousel(Sto, sFrom, imageurl, caption);
	}


	global static void sendCarousel(string sTo, string sFrom, string imageurl, string caption)
	{
		if (Test.isRunningTest())
			Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
		Object o = SM003_Http.request(getNexmoURL(), 'POST', getAuthHeader(), getBodyCarousel(sTo, sFrom, imageurl, caption), 'NexmoOut2', null);
	}

	global static string getBodyCarousel(string sTo, string sFrom, string imageURL, string sCaption)
	{
		map<string, object> mret = new map<string, object>();
		map<string, string> mFrom = new map<string, string>();
		mFrom.put('type', 'whatsapp');
		mFrom.put('number', sFrom);
		mret.put('from', mFrom);


		map<string, string> mTo = new map<string, string>();
		mTo.put('type', 'whatsapp');
		mTo.put('number', sTo);
		mret.put('to', mTo);

		map<string, object> mMess = new map<string, object>();
		map<string, object> mCont = new map<string, object>();
		mCont.put('type', 'image');
		map <string, object> mImage = new map<string, object>();
		mImage.put('url', imageURL);
		if (sCaption != null)
			mImage.put('caption', sCaption.replaceAll('/n/r', '\n'));
		mCont.put('image', mImage);
		mMess.put('content', mCont);
		mret.put('message', mMess);
		return JSON.serialize(mret).replaceAll('\\n', '\n');
	}
}
