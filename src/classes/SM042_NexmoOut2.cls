global class SM042_NexmoOut2 implements Queueable
{
	global Id messId;

	global static String getNexmoURL()
	{
		String sRet = SM010_Utils.getChat2aiValue2('Nexmo URL');
		if (sRet == '' || sRet == null)
			sRet = 'https://api.nexmo.com/v0.1/messages';
		return sRet;
	}


	global static String getNexmoURLV1()
	{
		String sRet = SM010_Utils.getChat2aiValue2('Nexmo URLV1');
		if (sRet == '' || sRet == null)
			sRet = 'https://api.nexmo.com/v1/messages';
		return sRet;
	}


	global SM042_NexmoOut2(Id messId0)
	{
		messId = messId0;
	}
	global static void pause(Integer delayInMilliseconds)
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
		System.debug(mess);

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
					SM041_WhatsApp.sendText(mess.CVCH__To__c, mess.CVCH__From__c, mo.sMessage, mess.CVCH__Channel__c);
					SM042_NexmoOut2.pause(800);
				}
				for (CarouselItem it : mo.lItems)
				{
					try
					{
						if (it.imageURL != null && it.imageURL != '')
							SM041_WhatsApp.sendImage(mess.CVCH__To__c, mess.CVCH__From__c, it.imageURL, it.getBody(), mess.CVCH__Channel__c);
						else if (it.videoURL != null && it.videoURL != '')
						{
							if (it.contentType == 'file')
								SM041_WhatsApp.sendFile(mess.CVCH__To__c, mess.CVCH__From__c, it.videoURL, it.getBody(), mess.CVCH__Channel__c);
							else
								SM041_WhatsApp.sendVideo(mess.CVCH__To__c, mess.CVCH__From__c, it.videoURL, it.getBody(), mess.CVCH__Channel__c);
						}
						SM042_NexmoOut2.pause(800);
					}
					catch (Exception e)
					{
						SM041_WhatsApp.sendText(mess.CVCH__To__c, mess.CVCH__From__c, e.getMessage(), mess.CVCH__Channel__c);
					}
				}
			}
			else if (mess.CVCH__Type__c == 'Custom' || mess.CVCH__Type__c == 'Custom2')
				SM041_WhatsApp.sendCustom(mess.CVCH__To__c, mess.CVCH__From__c, mess.CVCH__FullText__c, mess.CVCH__Channel__c);
			else if (mess.CVCH__Type__c == 'Template')
				SM041_WhatsApp.sendTemplate(mess.CVCH__To__c, mess.CVCH__From__c, mess.CVCH__FullText__c, mess.CVCH__Locale__c, mess.CVCH__Channel__c);
			else
					SM041_WhatsApp.sendText(mess.CVCH__To__c, mess.CVCH__From__c, mess.CVCH__FullText__c, mess.CVCH__Channel__c);
		}
	}

	@Future(Callout =true)
	global static void executeF(Id messId)
	{
		CVCH__NexmoMessage__c mess =
		[
				SELECT Id,CVCH__Text__c,CVCH__Status__c,CVCH__FullText__c,
						CVCH__JSON__c,CVCH__Type__c,
						CVCH__From__c,CVCH__From_Name__c,
						CVCH__To__c,CVCH__To_Name__c,
						CVCH__activityId__c,CVCH__conversationId__c,CVCH__conversationName__c,CVCH__Channel__c

				FROM CVCH__NexmoMessage__c
				WHERE Id = :messId
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


	@Future(Callout =true)
	global static void sendOrEnqueueF(Id messId)
	{
		CVCH__NexmoMessage__c mess =
		[
				SELECT Id,CVCH__Text__c,CVCH__Status__c,CVCH__FullText__c,
						CVCH__JSON__c,CVCH__Type__c,
						CVCH__From__c,CVCH__From_Name__c,
						CVCH__To__c,CVCH__To_Name__c,
						CVCH__activityId__c,CVCH__conversationId__c,CVCH__conversationName__c,CVCH__Channel__c,CVCH__Locale__c
				FROM CVCH__NexmoMessage__c
				WHERE Id = :messId
		];
		try
		{
			send(mess);
		}
		catch (Exception e)
		{
			SM042_NexmoOut2 job = new SM042_NexmoOut2(mess.Id);
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
		System.debug(mess);
		if (async == true)
		{
			insert mess;
			sendOrEnqueueF(mess.Id);
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
				System.debug('Err: ' + e.getMessage() + ' ' + e.getStackTraceString());
				insert mess;
				sendOrEnqueueF(mess.Id);
			}
		}
	}

	global static CVCH__NexmoMessage__c inboundMess;

	global static void setInboundMessage(CVCH__NexmoMessage__c mess)
	{
		inboundMess = mess;
	}
	global static CVCH__NexmoMessage__c initMessage(String sTo, String sFrom)
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
			mess.Channel__c = SM010_Utils.getChat2aiValue2('Default Outbound Channel');
		}
		system.debug('initMessage.return');
		system.debug(mess);
		return mess;
	}
	global static String getInboundChannel()
	{
		if (inboundMess != null)
			return inboundMess.CVCH__Channel__c;
		return '';
	}
	global static void sendText(String sTo, String sText, String sFrom, Boolean async)
	{
		CVCH__NexmoMessage__c mess = initMessage(sTo, sFrom);

		mess.CVCH__Text__c = sText;
		if (mess.CVCH__Text__c != null && mess.CVCH__Text__c.length() > 254)
			mess.CVCH__Text__c = mess.CVCH__Text__c.substring(0, 254);
		mess.CVCH__FullText__c = sText;
		mess.CVCH__Status__c = 'Queued';
		sendOrEnqueue(mess, async);
	}
	global static void sendText(String sTo, String sText, String sFrom)
	{
		sendText(sTo, sText, sFrom, false);
	}


	global static void sendCustomText2(String sTo, String sText, String sFrom, Boolean async)
	{
		sendCustomText(sTo, sText, sFrom, async, 'Custom2');
	}
	global static void sendCustomText(String sTo, String sText, String sFrom, Boolean async)
	{
		sendCustomText(sTo, sText, sFrom, async, 'Custom');
	}


	global static void sendCustomText(String sTo, String sText, String sFrom, Boolean async, String sType)
	{
		CVCH__NexmoMessage__c mess = initMessage(sTo, sFrom);

		mess.CVCH__Text__c = sText;
		if (mess.CVCH__Text__c != null && mess.CVCH__Text__c.length() > 254)
			mess.CVCH__Text__c = mess.CVCH__Text__c.substring(0, 254);
		mess.CVCH__FullText__c = sText;
		mess.CVCH__Status__c = 'Queued';
		mess.CVCH__Type__c = sType;
		sendOrEnqueue(mess, async);
	}


	global static void sendComplexType(MessageOptions opt, String sto, String sFrom)
	{
		CVCH__NexmoMessage__c mess = initMessage(sto, sFrom);

		if (opt.sType == '' || opt.sType == null)
			mess.CVCH__Type__c = 'Carousel';
		else
				mess.CVCH__Type__c = opt.sType;
		String sText = opt.sMessage;
		if (mess.CVCH__Text__c != null && mess.CVCH__Text__c.length() > 254)
			mess.CVCH__Text__c = mess.CVCH__Text__c.substring(0, 254);
		mess.CVCH__FullText__c = sText;
		mess.CVCH__JSON__c = JSON.serializePretty(opt);
		mess.CVCH__Status__c = 'Queued';

		sendOrEnqueue(mess, opt.async);
	}

	global static Map<String, String> getAuthHeader()
	{
		Map<String, String> headers = new Map <String, String>();
		String token = JWT.getAccessToken();
		String sAuth = 'Bearer ' + token;
		System.debug('sAuth=>' + sAuth);
		headers.put('Authorization', sAuth);
		headers.put('Content-Type', 'application/json');
		return headers;
	}

	global static String getBody(String sTo, String messageText, String sFrom)
	{
		Map<String, Object> mret = new Map<String, Object>();
		Map<String, String> mFrom = new Map<String, String>();
		mFrom.put('type', 'whatsapp');
		mFrom.put('number', sFrom);
		//       mFrom.put('number','447418342138');
		mret.put('from', mFrom);


		Map<String, String> mTo = new Map<String, String>();
		mTo.put('type', 'whatsapp');
		mTo.put('number', sTo);
		mret.put('to', mTo);

		Map<String, Object> mMess = new Map<String, Object>();
		Map<String, String> mCont = new Map<String, String>();
		mCont.put('type', 'text');
		mCont.put('text', messageText.replaceAll('\n', '%A9%'));
		mMess.put('content', mCont);
		mret.put('message', mMess);
		return JSON.serialize(mret);
	}


	global static void sendText(String sTo, String messageText)
	{
		sendText2(sTo, '97144099000', messageText);
	}

	global static void sendText2(String sTo, String sFrom, String messageText)
	{
		SM003_Http.request(getNexmoURL(), 'POST', getAuthHeader(), getBody(sTo, messageText, sFrom), 'NexmoOut2', null, 'SM004_SMSMock');
	}

	@Future(Callout=true)
	global static void sendCarouselAsync(String sTo, String sFrom, String imageurl, String caption)
	{
	}

	global static void sendCarousel(String sTo, String sFrom, String imageurl, String caption)
	{
		//moved to SM042.sendImage
	}

	global static String getBodyCarousel(String sTo, String sFrom, String imageURL, String sCaption)
	{
		return null; //moved to SM042.getBodyImage
	}
}
