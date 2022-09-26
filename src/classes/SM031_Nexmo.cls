@RestResource(urlMapping='/nexmo/*')
global class SM031_Nexmo
{

	global static Boolean bContextChanged = false;
	global static Decimal scoreLUIS = 0;
	global static Decimal scoreQnA = 0;
	global static String intentLUIS = '';
	global static String triggeredFlow = '';
	global static SM080_LUIS.LuisResponse respLuis = null;
	global static Boolean triggeredLUIS = false;
	public static Visitor__c visUpdate = null;

	@HttpPost
	global static List<CVCH__NexmoMessage__c> getMessage()
	{
//		if(SM010_Utils.getChat2aiValue2('PROCEED ASYNC')=='TRUE' || Test.isRunningTest())
//			proceedAsync (RestContext.request.requestBody.toString());
//		else
		getMessage0 (RestContext.request.requestBody.toString());
		return new List<CVCH__NexmoMessage__c>();
	}


	@HttpGet
	global static String testIt()
	{
		SM005_Logs.LogCallOut('', 'NexmoGet', RestContext.request.requestBody.toString(), 'hello', Datetime.now(), Datetime.now(), '');
		SM005_Logs.save();
		return 'hello';
	}



	public static void updateVisitor(Visitor__c v)
	{
		if (visUpdate == null)
			visUpdate = v.clone();
		else
		{
			Map<String, Object> mFields = v.getPopulatedFieldsAsMap();
			for (String sFld : mFields.keySet())
			{
				visUpdate.put(sFld, mFields.get(sFld));
			}
		}
	}



	public static List<MessageOptions> getResponse(CVCH__NexmoMessage__c mess, CVCH__Visitor__c visr)
	{
		List<MessageOptions> lret = new List<MessageOptions>();
		Boolean bProceeded = false;
		Boolean TriggerDefaultFlow = false;
		String translatedText = '';
		MTranslation tran = new MTranslation();
		tran.detectedlang = 'en';
		Boolean TriggerDefaultFlowChangeLang = false;
		Boolean flowinput = false;

		if (visr.CVCH__Context__c != null && visr.CVCH__Context__c != '')
		{ //if we received input, dont have to translate it
			MessageOptions mo = (MessageOptions) JSON.deserialize(visr.Context__c, MessageOptions.class);
			if (mo.sType == 'Input')
			{
				if (mo.sInputType == 'Name' || mo.sInputType == 'Email')
				{
					flowinput = true;
				}
			}
		}

		SM080_QnA.QnAResponse respQnA = new SM080_QnA.QnAResponse();
		respQnA.dScore = 0;
		if (mess.CVCH__InputType__c == 'button')
		{
			respLuis = new SM080_LUIS.LuisResponse();
			respLuis.sIntent = mess.Text__c;
			respLuis.dScore = 100;
			respQnA = new SM080_QnA.QnAResponse();
			respQnA.dScore = 0;
			if (mess.CVCH__ImageURL__c != null && mess.CVCH__ImageURL__c != '')
				mess.CVCH__Text__c = mess.CVCH__ImageURL__c;
		}
		else if (mess.InputType__c == 'location')
		{
			respLuis = new SM080_LUIS.LuisResponse();
			respLuis.sIntent = 'location';
			respLuis.dScore = 100;
			respQnA = new SM080_QnA.QnAResponse();
			respQnA.dScore = 0;
			mess.CVCH__Text__c = Location.getLocation()[0].url;
		}
		else if (mess.Text__c != null)
		{
			if (visr.language__c != 'en' && !flowinput)
			{
				tran = SM080_Translate.translate0(mess.Text__c);
				translatedText = tran.translation;
			}
			else
			{
				translatedText = mess.Text__c;
			}


			//system.debug('Translated input: ' + translatedText);

			respLuis = SM080_LUIS.queryPhrase(translatedText, visr.CVCH__language__c, mess.To__c);
			if (visr.CVCH__GDPR_Consent__c != 'No Access')
			{
				respQnA = SM080_QnA.queryPhrase(translatedText, visr.CVCH__language__c, mess.To__c);
				scoreQnA = respQnA.dScore;
			}
			scoreLUIS = respLuis.dScore;

			intentLUIS = respLuis.sIntent;

			if (respLuis.dScore < SM010_Utils.getMinResponseScore() && respQnA.dScore < SM010_Utils.getMinResponseScore())
			{
				if (tran.detectedlang != visr.language__c)
					TriggerDefaultFlowChangeLang = true; // We will trigger Default Flow 2, if both scores are below set treshold and if user typed in different language
				else if (visr.language__c == 'en')
				{
					tran = SM080_Translate.translate0(mess.Text__c);
					if (tran.detectedlang != 'en')
						TriggerDefaultFlowChangeLang = true; // We will trigger Default Flow 2, if both scores are below set treshold and if user typed in different language
					else
							TriggerDefaultFlow = true; // We will trigger Default Flow, if both scores are below set treshold and if user typed in same language
				}
				else
						TriggerDefaultFlow = true; // We will trigger Default Flow, if both scores are below set treshold and if user typed in same language
			}
		}
		else
		{
			respLuis = new SM080_LUIS.LuisResponse();
			respLuis.sIntent = 'Image';
			respLuis.dScore = 100;
			respQnA = new SM080_QnA.QnAResponse();
			respQnA.dScore = 0;
			mess.CVCH__Text__c = mess.CVCH__ImageURL__c;
		}
		System.debug('mess=');
		System.debug(mess);
		if (visr.CVCH__Livechat_Session_Key__c != null && visr.CVCH__Livechat_Session_Key__c != '')
		{
			if (/*mess.Text__c == 'end chat' || */(respLuis != null && respLuis.sIntent == 'EndChat'))
			{
				LiveChatMonitor.Disconnect(visr);
			}
			else
			{
				if (respLuis.sIntent == 'Image' && mess.CVCH__Text__c != null && !mess.CVCH__Text__c.startsWith(CVCH.SM010_Utils.getChat2aiValue('S3URL')))
				{
					if (SM010_Utils.getChat2aiValue2('Skip LiveChat File S3 Upload') != 'TRUE')
					{
						SM090_UploadS3.S3Output ret = SM090_UploadS3.getS3URL(mess.CVCH__Text__c);
						if (ret.S3URL != null)
							mess.CVCH__Text__c = ret.S3URL;
						else
								throw new MyException('Error: ' + ret.Error);
					}
				}
				try
				{
					SM093_LiveAgent.ChatMessage(SM093_LiveAgent.getMessageText(mess), visr);
				}
				catch (Exception e)
				{
					String errorMess = e.getMessage();
					if (errorMess.indexOf(SM093_LiveAgent.sessionRequired) >= 0)
					{
						LiveChatStatusBatch.terminateChat(visr);
					}
				}
			}
		}
		else
		{
			if (visr.CVCH__Had_First_Interaction__c == false)
			{
				System.debug('CVCH__Had_First_Interaction__c=false');
				bProceeded = true;
				Map<String, Object> params = new Map<String, Object>();

				params.put('visphone', visr.CVCH__Id__c);
				params.put('visitorName', mess.From_Name__c);
				params.put('ChatNumber', visr.CVCH__Chat_Number__c);
				params.put('channel', visr.CVCH__Chanel__c);
				params.put('originalmessage', mess.CVCH__Text__c);

				if (visr.Id == null && (Test.isRunningTest() || SM010_Utils.getChat2aiValue2('CREATE VISITOR BEFORE FLOWS') == 'TRUE'))
				{
					insert visr;
					System.debug('inserted visr');
				}

				if (SM010_Utils.getChat2aiValue2('CREATE VISITOR BEFORE FLOWS') == 'TRUE' || visr.Id != null)
					params.put('visitorId', visr.Id);
				params.put('visitorName', mess.From_Name__c);
				System.debug('visitor=' + visr);

				String sFlow = SM010_Utils.getChat2aiValue2('Welcome Flow');
				if (sFlow != '')
				{
					System.debug('Welcome Flow: ' + JSON.serialize(params));
					SM010_Utils.getFlow(sFlow, mess.To__c, params).start();
					triggeredFlow = 'Welcome Flow';
				}
			}
			else if (apexGDPR() && visr.CVCH__GDPR_Consent__c == 'No Access' && (visr.CVCH__Context__c == '' || visr.CVCH__Context__c == null)) //Restrict Non-GDPR users
			{
				System.debug('No Access');
				bProceeded = true;
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.Id);
				params.put('visitorName', mess.From_Name__c);
				params.put('originalmessage', mess.CVCH__Text__c);

				Flow.Interview flow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue('GDPR Flow'), mess.To__c, params);
				flow.start();
			}
			else if (apexGDPR() && visr.CVCH__GDPR_Consent__c == 'No Access' && visr.CVCH__Context__c != '' && visr.CVCH__Context__c != null)
			{
				System.debug('start flow: GDPR Flow');
				bProceeded = true;
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.Id);
				params.put('visitorName', mess.From_Name__c);
				params.put('originalmessage', mess.CVCH__Text__c);

				MessageOptions mo = (MessageOptions) JSON.deserialize(visr.CVCH__Context__c, MessageOptions.class);
				System.debug('GDPR MessageOptions=' + mo);
				Option opt = mo.mOptions.get(mess.CVCH__Text__c);
				if (opt == null)
				{
					opt = SM010_Utils.getOption(mo.mOptions, mess.CVCH__Text__c); // if input wasnt valid number of option - try to get it with label
				}
				if (opt != null && opt.sFlow != null)
				{
					if (opt.sName != null)
						params.put(opt.sName, opt.sValue);
					if (opt.sName2 != null)
						params.put(opt.sName2, opt.sValue2);
					if (opt.sName3 != null)
						params.put(opt.sName3, opt.sValue3);
					Flow.Interview flow = SM010_Utils.getFlow(opt.sFlow, mess.To__c, params);
					flow.start();
					triggeredFlow = 'GDPR Flow';
				}
				else if (SM010_Utils.getChat2aiValue2('GDPR Flow') != '')
				{
					Flow.Interview flow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue('GDPR Flow'), mess.To__c, params);
					flow.start();
					triggeredFlow = 'GDPR Flow';
				}

			}
			else if (!TriggerDefaultFlow && !TriggerDefaultFlowChangeLang && respLuis.dScore > respQnA.dScore && respLuis.sIntent == 'exit' && SM010_Utils.getChat2aiValue2('Main Menu Flow') != '')
			{
				System.debug('start flow: Main Menu Flow');
				bProceeded = true;
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.Id);
				params.put('visitorName', mess.From_Name__c);
				params.put('originalmessage', mess.CVCH__Text__c);
				Flow.Interview flow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue2('Main Menu Flow'), mess.To__c, params);
				flow.start();
				CVCH__Visitor__c v = new CVCH__Visitor__c(Id = visr.Id, CVCH__Next_Flow__c = null);
				if (visr.Current_Flow__c != null && visr.Current_Flow__c != '')
				{
					EventBus.publish(new User_Input__e(Input__c = mess.Text__c, Exit_Flow__c = true, VisitorId__c = visr.Id));
					v.Current_Flow__c = null;
				}
				update v;
				triggeredFlow = 'Main Menu Flow';
			}
			else if (visr.Current_Flow__c != null && visr.Current_Flow__c != '')
			{
				System.debug('FIRE USER INPUT EVENT');
				bProceeded = true;
				Map<String, Object> mEntities = new Map<String, Object>();
				String visEmail = '';
				String visName = '';
				if (respLuis.getEntities() != null && respLuis.getEntities() != '')
				{
					mEntities = (Map<String, Object>) JSON.deserializeUntyped(respLuis.getEntities());
					if (mEntities.get('email') != null)
						visEmail = String.valueOf(mEntities.get('email'));
					if (mEntities.get('personName') != null)
						visName = String.valueOf(mEntities.get('personName'));
				}
				EventBus.publish(new User_Input__e(Input__c = mess.Text__c, Exit_Flow__c = false, VisitorId__c = visr.Id, Filtered_Email__c = visEmail, Filtered_Name__c = visName));
				triggeredFlow = visr.Current_Flow__c;
			}
			else if (visr.CVCH__Next_Flow__c != null && visr.CVCH__Next_Flow__c != '')
			{
				System.debug('start flow: CVCH__Next_Flow__c');
				bProceeded = true;
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.Id);
				params.put('visitorName', mess.From_Name__c);
				params.put('input', mess.CVCH__Text__c);

				Flow.Interview flow = SM010_Utils.getFlow(visr.CVCH__Next_Flow__c, mess.To__c, params);
				flow.start();
				triggeredFlow = visr.Next_Flow__c;
			}
			else if (mess.CVCH__Flow__c != null && mess.CVCH__Flow__c != '')
			{
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.Id);
				params.put('visitorName', mess.From_Name__c);
				params.put('originalmessage', mess.CVCH__Text__c);
				Flow.Interview flow = SM010_Utils.getFlow(mess.CVCH__Flow__c, mess.To__c, params);
				flow.start();
				triggeredFlow = visr.Next_Flow__c;
				bProceeded = true;
			}
			else if (visr.CVCH__Context__c != null && visr.CVCH__Context__c != '')
			{
				System.debug('start flow: CVCH__Context__c');
				MessageOptions mo = (MessageOptions) JSON.deserialize(visr.Context__c, MessageOptions.class);
				System.debug('MessageOptions=' + mo);
				if (mo.sType == 'Input')
				{
					bProceeded = true;
					Map<String, Object> mEntities = new Map<String, Object>();
					if (respLuis.getEntities() != null && respLuis.getEntities() != '')
					{
						mEntities = (Map<String, Object>) JSON.deserializeUntyped(respLuis.getEntities());
					}
					//input type check
					if (mo.sInputType == 'Email')
					{
						if (mEntities.get('email') != null)
							mess.Text__c = String.valueOf(mEntities.get('email'));
						else
						{
							Map<String, Object> params = new Map<String, Object>();
							params.put('visitorId', visr.Id);
							params.put('visitorName', mess.From_Name__c);
							params.put('type', 'Email');
							Flow.Interview flow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue('Input Validation Error Flow'), mess.To__c, params);
							flow.start();
							return lret;
						}
					}
					if (mo.sInputType == 'Name')
					{
						if (mEntities.get('personName') != null)
						{
							mess.Text__c = String.valueOf(mEntities.get('personName'));
						}
						else
						{
							Map<String, Object> params = new Map<String, Object>();
							params.put('visitorId', visr.Id);
							params.put('visitorName', mess.From_Name__c);
							params.put('type', 'Name');
							Flow.Interview flow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue('Input Validation Error Flow'), mess.To__c, params);
							flow.start();
							return lret;
						}
					}

					Visitor__c v = new Visitor__c(Id = visr.Id);

					Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
					//System.debug('schemaMap = ' + schemaMap);
					Schema.SObjectType leadSchema = schemaMap.get('CVCH__Visitor__c');
					//System.debug('leadSchema = ' + leadSchema);
					Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
					if (mo.sFieldName != '' && mo.sFieldName != null)
					{
						try
						{
							if (fieldMap.get(mo.sFieldName).getDescribe().getType() == Schema.DisplayType.DATE)
							{
								Pattern pat = Pattern.compile('^\\d{1,2}\\/\\d{1,2}\\/\\d{4}$');
								if (!pat.matcher(mess.Text__c).matches())
								{
									String dateEx = SM010_Utils.getChat2aiValue2('INVALID_DATE');
									if (dateEx == '')
										dateEx = 'Invalid date format. Please provide dd/MM/yyyy';
									throw new MyException(dateEx);
								}
								v.put(mo.sFieldName, Date.parse(mess.Text__c));
							}
							else
									v.put(mo.sFieldName, mess.Text__c);
						}
						catch (MyException ex)
						{
							throw ex;
						}
						catch (Exception e)
						{
							v.put(mo.sFieldName, mess.Text__c);
						}

						v.Context__c = '';
						update v;
					}
					if (mo.sFlow != null && mo.sFlow != '')
					{
						Map<String, Object> params = new Map<String, Object>();

						if (mo.flowParamsJSON != null && mo.flowParamsJSON != '')
						{
							try
							{
								Map<String, Object> mParams2 = (Map<String, Object>) JSON.deserializeUntyped(mo.flowParamsJSON);
								params.putAll(mParams2);
							}
							catch (Exception e)
							{

							}
						}
						params.put('visitorId', visr.Id);
						params.put('visitorName', mess.From_Name__c);
						if (mo.sParamName != '' && mo.sParamName != null)
						{
							params.put(mo.sParamName, mess.Text__c);
						}

						Flow.Interview flow = SM010_Utils.getFlow(mo.sFlow, mess.To__c, params);
						flow.start();
						triggeredFlow = mo.sFlow;
					}

					if (mo.sFieldName == '' || mo.sFieldName == null)
					{
						if (bContextChanged != true)
						{
							CVCH__Visitor__c vis = new CVCH__Visitor__c(Id = v.Id, CVCH__Context__c = '');
							update vis;
						}
					}
				}
				else
				{
					System.debug('getting option ' + mess.CVCH__Text__c + ' from ' + mo.mOptions);
					Option opt = mo.mOptions.get(mess.CVCH__Text__c);
					if (opt == null)
					{
						opt = SM010_Utils.getOption(mo.mOptions, mess.CVCH__Text__c); // if input wasnt valid number of option - try to get it with label
					}
					if (opt != null)
					{
						System.debug('found option ' + opt);
						if (opt.sType == 'QnA')
						{
							Integer qnaid = Integer.valueOf(opt.sValue);

							SM080_QnA.QnAResponse respQnA2 = SM080_QnA.getQNA(qnaid, visr.CVCH__language__c, mess.To__c);
							lret.add(new MessageOptions(respQnA2));
							bProceeded = true;
						}
						else
						{
							bProceeded = true;
							if (opt.sFlow != null)
							{
								Map<String, Object> params = new Map<String, Object>();
								params.put('visitorId', visr.Id);
								params.put('visitorName', mess.From_Name__c);
								params.put('originalmessage', mess.CVCH__Text__c);
								if (opt.sName != null)
									params.put(opt.sName, opt.sValue);
								if (opt.sName2 != null)
									params.put(opt.sName2, opt.sValue2);
								if (opt.sName3 != null)
									params.put(opt.sName3, opt.sValue3);
								Flow.Interview flow = SM010_Utils.getFlow(opt.sFlow, mess.To__c, params);
								flow.start();
								triggeredFlow = opt.sFlow;
							}
						}
					}
				}

			}
			if (!bProceeded && TriggerDefaultFlowChangeLang && SM010_Utils.getChat2aiValue2('Default Flow 2') != '')
			{
				System.debug('start flow: Default Flow 2');
				//if (respLuis.dScore < Decimal.valueOf(SM010_Utils.getChat2aiValue('Response minimum score')) || (respLuis.dScore >= Decimal.valueOf(SM010_Utils.getChat2aiValue('Response minimum score')) && !(respLuis.sIntent == 'directions' || respLuis.sIntent == 'category search' || respLuis.sIntent == 'outlet search' || respLuis.sIntent == 'special opening hours' || respLuis.sIntent == 'opt out' || respLuis.sIntent == 'ikea'))) {
				bProceeded = true;
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.Id);
				params.put('visitorName', mess.From_Name__c);
				params.put('originalmessage', mess.Text__c);
				params.put('language', tran.detectedlang);
				params.put('visitorlanguage', visr.language__c);
				Flow.Interview flow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue2('Default Flow 2'), mess.To__c, params);
				flow.start();// trigger default flow 2
				triggeredFlow = 'Default Flow 2';
//}

			}
			if (!bProceeded && TriggerDefaultFlow && SM010_Utils.getChat2aiValue2('Default Flow') != '')
			{
				System.debug('start flow: Default Flow');
				bProceeded = true;
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.Id);
				params.put('visitorName', mess.From_Name__c);
				params.put('originalmessage', mess.Text__c);
				Flow.Interview flow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue2('Default Flow'), mess.To__c, params);
				flow.start();// trigger default flow
				triggeredFlow = 'Default Flow';

			}
			if (!bProceeded)
			{
				System.debug('start flow: Chat2ai Flow');
				System.debug('LUIS score=' + respLuis.dScore + ',QnA score=' + respQnA.dScore);
				if (respLuis.dScore > respQnA.dScore)
				{
					Map<String, Object> params = new Map<String, Object>();
					params.put('visitorId', visr.Id);
					params.put('visitorName', mess.From_Name__c);
					params.put('intent', respLuis.sIntent);
					params.put('entities', respLuis.getEntities());
					params.put('originalmessage', mess.CVCH__Text__c);
					Flow.Interview chat2aiflow = SM010_Utils.getFlow(SM010_Utils.getChat2aiValue('Chat2ai Flow'), mess.To__c, params);
					chat2aiflow.start();
					triggeredFlow = intentLUIS;
					triggeredLUIS = true;
				}
				else
						lret.add(new MessageOptions(respQnA));
			}
		}
		return lret;
	}

	public static Boolean apexGDPR()
	{
		Boolean bRet = false;
		Chat2ai__c val = Chat2ai__c.getInstance('ApexGDPR');
		if (val != null)
		{
			bRet = (val.Value__c == 'TRUE');
		}
		if (Test.isRunningTest())
			bRet = true;
		return bRet;
	}

	global static CVCH__NexmoMessage__c getAzureMessage(Map<String, Object> m)
	{
		System.debug('getAzureMessage.start');
		CVCH__NexmoMessage__c mess = new CVCH__NexmoMessage__c();
		mess.Name = (String) m.get('id');
		mess.CVCH__Text__c = (String) m.get('text');

		if (mess.CVCH__Text__c == null || mess.CVCH__Text__c == '')
		{
			mess.CVCH__Text__c = (String) JPath.get0(m, '/channelData/message/text');
		}
		System.debug('mess.CVCH__Text__c=' + mess.CVCH__Text__c);

		if (mess.CVCH__Text__c == null || mess.CVCH__Text__c == '')
		{
			list<object>lAttachments = (list<object>) m.get('attachments');
			if (lAttachments != null && !lAttachments.isEmpty())
			{
				map<string, object> mAttachment = (map<string, object>) lAttachments[0];
				string contentType = (string) mAttachment.get('contentType');
				String sURL = (String) mAttachment.get('contentUrl');
				if (contentType.startsWith('image'))
					mess.CVCH__InputType__c = 'image';
				else
						mess.CVCH__InputType__c = 'file';
				mess.ImageURL__c = sURL;
			}
		}
		Map<String, Object> mFrom = (Map<String, Object>) m.get('from');
		mess.CVCH__From__c = (String) mFrom.get('id');
		mess.CVCH__From_Name__c = (String) mFrom.get('name');

		Map<String, Object> mTo = (Map<String, Object>) m.get('recipient');
		mess.CVCH__To__c = (String) mTo.get('id');
		mess.CVCH__To_Name__c = (String) mTo.get('name');
		mess.CVCH__ChannelId__c = (String) m.get('channelId');
		mess.CVCH__Channel__c = 'Azure';
		Map<String, Object> mConv = (Map<String, Object>) m.get('conversation');

		mess.CVCH__conversationId__c = (String) mConv.get('id');
		mess.CVCH__conversationName__c = (String) mConv.get('name');
		mess.CVCH__ExternalId__c = mess.Name;
		if (mess.name.length() > 80)
			mess.name = mess.name.substring(0, 79);
		mess.ReplyToId__c = (String) JPath.safeGet(m,'/context/message_uuid');

		System.debug('getAzureMessage.return');
		System.debug(mess);
		return mess;
	}

	private static NexmoMessage__c D360Message(Map<String, Object> mObj)
	{
		System.debug('D360Message.start');
		List<Object> lMess = (List<Object>) mObj.get('messages');
		Map<String, Object> m = (Map<String, Object>) lMess[0];
		CVCH__NexmoMessage__c mess = new CVCH__NexmoMessage__c();
		mess.Name = (String) m.get('id');
		mess.CVCH__Channel__c = 'D360';
		mess.CVCH__From__c = (String) m.get('from');
		mess.From_Name__c = (String) JPath.get0(mObj, '/contacts/[1]/profile/name');
		mess.To__c = (String)mObj.get('to');
		mess.CVCH__InputType__c = (String) m.get('type');

		if (mess.CVCH__InputType__c == 'text')
			mess.CVCH__Text__c = (String) ((Map<String, Object>) m.get('text')).get('body');
		else if (mess.CVCH__InputType__c == 'image')
		{
			mess.ImageURL__c = (String) ((Map<String, Object>) m.get('image')).get('url');
			if (mess.ImageURL__c == null || mess.ImageURL__c == '')
			{
				String sURL = SM010_Utils.getChat2aiValue2('D360URL') + '/media/' + ((String) ((Map<String, Object>) m.get('image')).get('id'));
				mess.ImageURL__c = SM090_UploadS3.getS3URL(sURL,mess.CVCH__Channel__c,mess.To__c).S3URL;
			}
		}

		else if (mess.CVCH__InputType__c == 'file')
			mess.ImageURL__c = (String) ((Map<String, Object>) m.get('file')).get('url');
		else if (mess.CVCH__InputType__c == 'button')
		{
			String sId = (String) ((Map<String, Object>) m.get('button')).get('payload');
			String sTitle = (String) ((Map<String, Object>) m.get('button')).get('text');
			if (sId.startsWith('flow_'))
			{
				mess.CVCH__Flow__c = sId.replaceFirst('flow_', '');
				mess.CVCH__Text__c = sTitle;
			}
			else
			{
				mess.CVCH__Text__c = sId;
			}
		}
		else if (mess.CVCH__InputType__c == 'interactive')
		{
			String sId = null;
			String sTitle = null;
			try
			{
				sId = (String) JPath.get0(m, '/interactive/button_reply/id');
				sTitle = (String) JPath.get0(m, '/interactive/button_reply/title');
			}
			catch (Exception e)
			{
			}
			if (sId == null || sId == '')
			{
				sId = (String) JPath.get0(m, '/interactive/list_reply/id');
				sTitle = (String) JPath.get0(m, '/interactive/list_reply/title');
			}

			if (sId.startsWith('flow_'))
			{
				mess.CVCH__Flow__c = sId.replaceFirst('flow_', '');
				mess.CVCH__Text__c = sTitle;
			}
			else
			{
				mess.CVCH__Text__c = sId;
			}
		}

		mess.CVCH__ExternalId__c = mess.Name;
		if (mess.name.length() > 80)
			mess.name = mess.name.substring(0, 79);
		mess.ReplyToId__c = (String) JPath.safeGet(m,'/context/message_uuid');
		System.debug('D360Message.return');
		System.debug(mess);
		return mess;
	}

	private static NexmoMessage__c NexmoV1Message(Map<String, Object> m)
	{
		CVCH__NexmoMessage__c mess = new CVCH__NexmoMessage__c();
		System.debug('NexmoV1Message.start');

		mess.Name = (String) m.get('message_uuid');
		mess.CVCH__Channel__c = 'NexmoV1';
		mess.CVCH__From__c = (String) m.get('from');
		mess.CVCH__To__c = (String) m.get('to');
		mess.From_Name__c = (String) JPath.get0(m, '/profile/name');
		mess.CVCH__InputType__c = (String) m.get('message_type');

		System.debug('mess.CVCH__InputType__c =  ' + mess.CVCH__InputType__c);
		if (mess.CVCH__InputType__c == 'text')
		{
			mess.CVCH__Text__c = (String) m.get('text');
		}
		else if (mess.CVCH__InputType__c == 'image')
		{
			mess.ImageURL__c = (String) ((Map<String, Object>) m.get('image')).get('url');
		}
		else if (mess.CVCH__InputType__c == 'file')
		{
			mess.ImageURL__c = (String) ((Map<String, Object>) m.get('file')).get('url');
		}
		else if (mess.CVCH__InputType__c == 'button')
		{
			mess.CVCH__Text__c = (String) ((Map<String, Object>) m.get('button')).get('payload');
			System.debug('CVCH__InputType__c = button, CVCH__Text__c=' + mess.CVCH__Text__c + ', m=' + JSON.serialize(m));
		}
		else if (mess.CVCH__InputType__c == 'reply')
		{
			String sId = (String) ((Map<String, Object>) m.get('reply')).get('id');
			String sTitle = (String) ((Map<String, Object>) m.get('reply')).get('title');
			if (sId.startsWith('flow_'))
			{
				mess.CVCH__Flow__c = sId.replaceFirst('flow_', '');
				mess.CVCH__Text__c = sTitle;
			}
			else
			{
				mess.CVCH__Text__c = sId;
			}
		}
		else if (mess.InputType__c == 'location')
		{
			Map<String, Object> mLoc = (Map<String, Object>) m.get('location');

			Location loc = new Location();
			loc.address = (String) mLoc.get('address');
			loc.name = (String) mLoc.get('name');
			loc.url = (String) mLoc.get('url');

			loc.latitude = (Decimal) mLoc.get('lat');
			loc.longitude = (Decimal) mLoc.get('long');
			Location.setLocation(loc);
		}

		System.debug('mess.CVCH__Text__c = ' + mess.CVCH__Text__c);
		mess.CVCH__ExternalId__c = mess.Name;
		if (mess.name.length() > 80)
		{
			mess.name = mess.name.substring(0, 79);
		}
		mess.ReplyToId__c = (String) JPath.safeGet(m,'/context/message_uuid');
		System.debug('NexmoV1Message.return');
		System.debug(mess);
		return mess;
	}

	global static CVCH__NexmoMessage__c parseWithUniqueCheck(String jsonbody)
	{
		CVCH__NexmoMessage__c mess = parse(jsonbody);
		List<CVCH__NexmoMessage__c> lold = DM014_Message.getRecordByExtID(mess.CVCH__ExternalId__c);

		if (!lold.isEmpty())
		{
			mess = null;
		}
		else
		{
			SM042_NexmoOut2.setInboundMessage(mess);
		}

		return mess;
	}
	global static CVCH__NexmoMessage__c parse(String jsonbody)
	{
		System.debug('parse.start ' + jsonbody);
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonbody);
		System.debug(m);
		if (m.containsKey('messages'))
			return D360Message(m);

		String message_uuid = (String) m.get('message_uuid');
		System.debug('message_uuid = ' + message_uuid);
		if (message_uuid == null && (String) m.get('type') != null)
		{
			return getAzureMessage(m);
		}
		Map<String, Object> mFrom;
		try
		{
			mFrom = (Map<String, Object>) m.get('from');
		}
		catch (Exception e)
		{
			return NexmoV1Message(m);
		}

		String sFrom = SM010_Utils.phone((String) mFrom.get('number'));
		String sChannel = (String) mFrom.get('type');
		Map<String, Object> mTo = (Map<String, Object>) m.get('to');
		String sTo = (String) mTo.get('number');
		Map<String, Object> mMess = (Map<String, Object>) m.get('message');
		Map<String, Object> mCon;
		try
		{
			mCon = (Map<String, Object>) mMess.get('content');
		}
		catch (Exception e)
		{
			return null;
		}

		String messageText = (String) mCon.get('text');
		CVCH__NexmoMessage__c mess = new CVCH__NexmoMessage__c();
		mess.CVCH__InputType__c = (String) mCon.get('type');
		System.debug(mCon);
		if (mess.CVCH__InputType__c == 'button')
		{
			messageText = (String) ((Map<String, Object>) mCon.get('button')).get('payload');
		}
		if (mess.CVCH__InputType__c == 'image')
		{
			Map<String, Object> mImage = (Map<String, Object>) mCon.get('image');
			mess.ImageURL__c = (String) mImage.get('url');
		}
		else if (mess.CVCH__InputType__c == 'file')
		{
			Map<String, Object> mImage = (Map<String, Object>) mCon.get('file');
			mess.ImageURL__c = (String) mImage.get('url');
		}


		mess.Name = message_uuid;
		mess.CVCH__From__c = sFrom;

		mess.CVCH__To__c = sTo;


		mess.CVCH__Text__c = messageText;
		if (mess.CVCH__Text__c != null)
			mess.CVCH__Text__c = mess.CVCH__Text__c.replace('١', '1').replace('٢', '2').replace('٣', '3').replace('٤', '4').replace('٥', '5').replace('٦', '6').replace('٧', '7').replace('٨', '8').replace('٩', '9').replace('٠', '0');
		mess.CVCH__Channel__c = sChannel;

		mess.CVCH__From_Name__c = '';
		mess.CVCH__To_Name__c = '';
		mess.CVCH__ChannelId__c = '';
		mess.CVCH__conversationId__c = '';
		mess.CVCH__conversationName__c = '';

		mess.CVCH__ExternalId__c = mess.Name;
		if (mess.name.length() > 80)
			mess.name = mess.name.substring(0, 79);
		System.debug('parse.return ' + mess);
		return mess;
	}


	public static CVCH__Visitor__c getVisitor(String sid, String sChatNumber, String channel)
	{
		CVCH__Visitor__c ret;
		List<CVCH__Visitor__c> lVisitors = DM080_Visitor.getRecordsbyNumber(sid);

		if (!lVisitors.isEmpty())
			ret = lVisitors[0];
		else
				ret = new CVCH__Visitor__c(CVCH__Id__c = sid, CVCH__Context__c = null, CVCH__Chat_Number__c = sChatNumber, CVCH__Chanel__c = channel, Id = null, CVCH__language__c = null, CVCH__Livechat_Session_Key__c = null);
		return ret;
	}


	public static void sendError0(CVCH__NexmoMessage__c mess0, String sErrorMessage, CVCH__Visitor__c vis)
	{
		if (vis != null && vis.CVCH__language__c != '' && vis.CVCH__language__c != null && vis.CVCH__language__c != 'en')
		{
			try
			{
				sErrorMessage = SM010_Utils.translate(sErrorMessage, vis.CVCH__language__c);
			}
			catch (Exception e)
			{

			}
		}

		if (mess0 != null && mess0.CVCH__From__c != null)
		{
			String sErrorFlow = SM010_Utils.getChat2aiValue2('Error Flow');
			if (sErrorFlow != '')
			{
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', vis.Id);
				params.put('errorMessage', sErrorMessage);

				Flow.Interview flow = SM010_Utils.getFlow(sErrorFlow, mess0.CVCH__To__c, params);
				flow.start();
			}
			else
			{
				SM042_NexmoOut2.sendText(mess0.CVCH__From__c, sErrorMessage, mess0.CVCH__To__c);
			}
		}
	}
	public static void sendError(CVCH__NexmoMessage__c mess0, String sErrorMessage, CVCH__Visitor__c vis)
	{
		if (sErrorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
		{
			sErrorMessage = sErrorMessage.substring(sErrorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') + 'FIELD_CUSTOM_VALIDATION_EXCEPTION'.length() + 2);
			if (sErrorMessage.contains('Class.'))
			{
				sErrorMessage = sErrorMessage.substring(0, sErrorMessage.indexOf('Class.'));
			}

			if (sErrorMessage.contains(': []'))
			{
				sErrorMessage = sErrorMessage.substring(0, sErrorMessage.indexOf(': []'));
			}
			if (sErrorMessage.contains('[]'))
			{
				sErrorMessage = sErrorMessage.substring(0, sErrorMessage.indexOf('[]'));
			}
		}
		else if (SM010_Utils.getChat2aiValue2('SEND DEV ERRORS') != 'TRUE')
			sErrorMessage = 'Oops, something went wrong. Please try again.';
		if (vis != null && vis.CVCH__language__c != '' && vis.CVCH__language__c != null && vis.CVCH__language__c != 'en')
		{
			try
			{
				sErrorMessage = SM010_Utils.translate(sErrorMessage, vis.CVCH__language__c);
			}
			catch (Exception e)
			{
			}
		}
		String sErrorFlow = SM010_Utils.getChat2aiValue2('Error Flow');
		if (sErrorFlow != '')
		{
			Map<String, Object> params = new Map<String, Object>();
			if (vis != null)
				params.put('visitorId', vis.Id);
			if (mess0 != null)
			{
				params.put('ChatNumber', mess0.To__c);
				params.put('visphone', mess0.From__c);
			}


			params.put('errorMessage', sErrorMessage);

			Flow.Interview flow = SM010_Utils.getFlow(sErrorFlow, mess0.CVCH__To__c, params);
			flow.start();
		}
		else if (mess0 != null && mess0.CVCH__From__c != null)
		{
			SM042_NexmoOut2.sendText(mess0.CVCH__From__c, sErrorMessage, mess0.CVCH__To__c);
		}
	}
	@Future(Callout=true)
	global static void proceedAsync(String jsonbody)
	{
		getMessage0(jsonbody);

	}

	global static List<CVCH__NexmoMessage__c> getMessage0(String jsonbody)
	{
		CVCH__Visitor__c visr;
		Datetime dtBeg = Datetime.now();
		String errMsg = '';
		String sOutput = '';
		CVCH__NexmoMessage__c mess0 = new CVCH__NexmoMessage__c();
		try
		{
			mess0 = parseWithUniqueCheck(jsonbody);
			if (mess0 == null)
				return new List<CVCH__NexmoMessage__c>();

			FacebookMessage fm;
			if (mess0.Channel__c == 'D360')
				fm = FacebookMessage.parse(jsonbody);
			if (fm != null && fm.isValid)
			{
				fm.handledInFlow();
			}
			else
			{
				visr = getVisitor(mess0.CVCH__From__c, mess0.CVCH__To__c, mess0.CVCH__Channel__c);
				mess0.CVCH__Received__c = dtBeg;

				List<MessageOptions> aRetStr;
				aRetStr = getResponse(mess0, visr);
				System.debug(aRetStr);
				if (aRetStr != null)
				{
					mess0.CVCH__Response2__c = String.join(aRetStr, '\t');
					if (mess0.CVCH__Response2__c != null && mess0.CVCH__Response2__c.length() > 32000)
						mess0.CVCH__Response2__c = mess0.CVCH__Response2__c.substring(0, 32000);
					String sPrevContext = visr.CVCH__Context__c;
					for (MessageOptions opt : aRetStr)
					{
						opt.send(visr);
						sOutput += '\t' + opt.getBody();
					}
					if (sOutput != null && sOutput.length() > 32000)
						sOutput = sOutput.substring(0, 32000);
					if (sPrevContext != visr.CVCH__Context__c)
					{
						CVCH__Visitor__c v = new CVCH__Visitor__c(Id = visr.Id, CVCH__Context__c = visr.CVCH__Context__c);
						update v;
					}
				}
			}
		}
		catch (MyException e)
		{
			System.debug('error: ' + e);
			sendError0(mess0, e.getMessage(), visr);
			if (Test.isRunningTest())
				throw e;
		}
		catch (Exception e)
		{
			System.debug('error: ' + e.getMessage() + ' ' + e.getStackTraceString());
			sendError(mess0, '' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString(), visr);
			if (Test.isRunningTest())
				throw e;
		}
		finally
		{
			system.debug('inside getMessage0 catch:');
			system.debug(mess0);
			try
			{

				SM005_Logs.LogCallOut('', 'Nexmo', jsonbody, JSON.serialize(mess0), dtBeg, Datetime.now(), errMsg);
				SM005_Logs.save();
				SM010_Utils.saveTran();
				if (mess0 != null)
				{
					mess0.CVCH__Responded__c = Datetime.now();
					mess0.CVCH__Duration__c = mess0.CVCH__Responded__c.getTime() - mess0.CVCH__Received__c.getTime();
					insert mess0;
					updateVisitor(new Visitor__c(Id = visr.Id, Last_Inbound_Message__c = mess0.Id));
				}
				SM010_Utils.insertConversation(scoreLUIS, scoreQnA, intentLUIS, triggeredFlow, visr.language__c, visr.CVCH__Id__c, mess0.Text__c, sOutput, visr.Id, errMsg);
				if (triggeredLUIS)
				{ // if we got LUIS response for query - log Search Request for keyword, if present
					SM010_Utils.logSearchRequest(respLuis);
				}
				updateVisitor(new Visitor__c(Id = visr.Id, CVCH__Last_Interaction_Date__c = Datetime.now()));

				if (visUpdate != null)
					update visUpdate;
			}
			catch (Exception e)
			{

			}
		}
		return new List<CVCH__NexmoMessage__c>();
	}
}
