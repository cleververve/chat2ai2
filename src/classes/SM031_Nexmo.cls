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
			if(mess.CVCH__ImageURL__c != null && mess.CVCH__ImageURL__c != '')
				mess.CVCH__Text__c = mess.CVCH__ImageURL__c;
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
			respLuis = SM080_LUIS.queryPhrase(translatedText, visr.CVCH__language__c);
			if (visr.CVCH__GDPR_Consent__c != 'No Access')
			{
				respQnA = SM080_QnA.queryPhrase(translatedText, visr.CVCH__language__c);
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
//				Visitor__c vis = new Visitor__c();
//				vis.Id = visr.Id;
//				vis.Livechat_Session_Key__c = null;
//				vis.Livechat_Session_Id__c = null;
//				vis.Livechat_affinityToken__c = null;
//				update vis;
//				SM042_NexmoOut2.sendText(vis.CVCH__Id__c, SM010_Utils.translate('The chat is disconnected', vis.CVCH__language__c), vis.CVCH__Chat_Number__c, false);
			}
			else
			{
				if (respLuis.sIntent == 'Image')
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
					SM093_LiveAgent.ChatMessage(mess.CVCH__Text__c, visr.Livechat_affinityToken__c, visr.CVCH__Livechat_Session_Key__c);
				}catch(Exception e)
				{
					String errorMess = e.getMessage();
					if(errorMess.indexOf('Session required but was invalid')>=0)
					{
						CVCH.SM042_NexmoOut2.sendText(visr.CVCH__Id__c, SM010_Utils.translate('Sorry, your chat session is expired..',visr.CVCH__language__c), visr.CVCH__Chat_Number__c, false);

						CVCH__Visitor__c vis = new CVCH__Visitor__c();
						vis.Id = visr.Id;
						vis.CVCH__Livechat_Session_Key__c = null;
						vis.CVCH__Livechat_Session_Id__c = null;
						vis.CVCH__Livechat_affinityToken__c = null;
						update vis;
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
				System.debug('visitor=' + visr);

				String sFlow = SM010_Utils.getChat2aiValue2('Welcome Flow');
				if (sFlow != '')
				{
					system.debug('Welcome Flow: '+JSON.serialize(params));
					Flow.Interview.createInterview(sFlow, params).start();
					triggeredFlow = 'Welcome Flow';
				}
			}
			else if (apexGDPR() && visr.CVCH__GDPR_Consent__c == 'No Access' && (visr.CVCH__Context__c == '' || visr.CVCH__Context__c == null)) //Restrict Non-GDPR users
			{
				System.debug('No Access');
				bProceeded = true;
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.Id);
				params.put('originalmessage', mess.CVCH__Text__c);

				Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('GDPR Flow'), params);
				flow.start();
			}
			else if (apexGDPR() && visr.CVCH__GDPR_Consent__c == 'No Access' && visr.CVCH__Context__c != '' && visr.CVCH__Context__c != null)
			{
				System.debug('start flow: GDPR Flow');
				bProceeded = true;
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.Id);
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
					Flow.Interview flow = Flow.Interview.createInterview(opt.sFlow, params);
					flow.start();
					triggeredFlow = 'GDPR Flow';
				}
				else if (SM010_Utils.getChat2aiValue2('GDPR Flow') !='')
				{
					Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('GDPR Flow'), params);
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
				params.put('originalmessage', mess.CVCH__Text__c);
				Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue2('Main Menu Flow'), params);
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
				params.put('input', mess.CVCH__Text__c);

				Flow.Interview flow = Flow.Interview.createInterview(visr.CVCH__Next_Flow__c, params);
				flow.start();
				triggeredFlow = visr.Next_Flow__c;
			}
				else if(mess.CVCH__Flow__c != null && mess.CVCH__Flow__c != '')
				{
					Map<String, Object> params = new Map<String, Object>();
					params.put('visitorId', visr.Id);
					params.put('originalmessage', mess.CVCH__Text__c);
					Flow.Interview flow = Flow.Interview.createInterview(mess.CVCH__Flow__c, params);
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
							params.put('type', 'Email');
							Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Input Validation Error Flow'), params);
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
							params.put('type', 'Name');
							Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Input Validation Error Flow'), params);
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
						if (mo.sParamName != '' && mo.sParamName != null)
						{
							params.put(mo.sParamName, mess.Text__c);
						}

						Flow.Interview flow = Flow.Interview.createInterview(mo.sFlow, params);
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

							SM080_QnA.QnAResponse respQnA2 = SM080_QnA.getQNA(qnaid, visr.CVCH__language__c);
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
								params.put('originalmessage', mess.CVCH__Text__c);
								if (opt.sName != null)
									params.put(opt.sName, opt.sValue);
								if (opt.sName2 != null)
									params.put(opt.sName2, opt.sValue2);
								if (opt.sName3 != null)
									params.put(opt.sName3, opt.sValue3);
								Flow.Interview flow = Flow.Interview.createInterview(opt.sFlow, params);
								flow.start();
								triggeredFlow = opt.sFlow;
							}
						}
					}
				}

			}
			if (!bProceeded && TriggerDefaultFlowChangeLang && SM010_Utils.getChat2aiValue2('Default Flow 2') !='' )
			{
				System.debug('start flow: Default Flow 2');
				//if (respLuis.dScore < Decimal.valueOf(SM010_Utils.getChat2aiValue('Response minimum score')) || (respLuis.dScore >= Decimal.valueOf(SM010_Utils.getChat2aiValue('Response minimum score')) && !(respLuis.sIntent == 'directions' || respLuis.sIntent == 'category search' || respLuis.sIntent == 'outlet search' || respLuis.sIntent == 'special opening hours' || respLuis.sIntent == 'opt out' || respLuis.sIntent == 'ikea'))) {
				bProceeded = true;
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.Id);
				params.put('originalmessage', mess.Text__c);
				params.put('language', tran.detectedlang);
				params.put('visitorlanguage', visr.language__c);
				Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue2('Default Flow 2'), params);
				flow.start();// trigger default flow 2
				triggeredFlow = 'Default Flow 2';
//}

			}
			if (!bProceeded && TriggerDefaultFlow  && SM010_Utils.getChat2aiValue2('Default Flow') !='' )
			{
				System.debug('start flow: Default Flow');
				bProceeded = true;
				Map<String, Object> params = new Map<String, Object>();
				params.put('visitorId', visr.Id);
				params.put('originalmessage', mess.Text__c);
				Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue2('Default Flow'), params);
				flow.start();// trigger default flow
				triggeredFlow = 'Default Flow';
//VF-438
/*if (visr.language__c == 'en')
{
    tran = SM080_Translate.translate0(mess.Text__c);
    if (visr.language__c != tran.detectedlang)
    {
        params.put('language',tran.detectedlang);
        params.put('visitorlanguage',visr.language__c);
        Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Default Flow 2'), params);
        flow.start();// trigger default flow 2
        triggeredFlow = 'Default Flow 2';
    }
    else
    {
        Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Default Flow'), params);
        flow.start();// trigger default flow
        triggeredFlow = 'Default Flow';
    }
}
else
{
    Flow.Interview flow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Default Flow'), params);
    flow.start();// trigger default flow
    triggeredFlow = 'Default Flow';
}
*/
			}
			if (!bProceeded)
			{
				System.debug('start flow: Chat2ai Flow');
				System.debug('LUIS score=' + respLuis.dScore + ',QnA score=' + respQnA.dScore);
				if (respLuis.dScore > respQnA.dScore)
				{
					Map<String, Object> params = new Map<String, Object>();
					params.put('visitorId', visr.Id);
					params.put('intent', respLuis.sIntent);
					params.put('entities', respLuis.getEntities());
					params.put('originalmessage', mess.CVCH__Text__c);
					Flow.Interview chat2aiflow = Flow.Interview.createInterview(SM010_Utils.getChat2aiValue('Chat2ai Flow'), params);
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
		CVCH__NexmoMessage__c mess = new CVCH__NexmoMessage__c();
		mess.Name = (String) m.get('id');
		mess.CVCH__Text__c = (String) m.get('text');
		if (mess.CVCH__Text__c == null || mess.CVCH__Text__c == '')
			return null;
		Map<String, Object> mFrom = (Map<String, Object>) m.get('from');
		mess.CVCH__From__c = (String) mFrom.get('id');
		mess.CVCH__From_Name__c = (String) mFrom.get('name');

		Map<String, Object> mTo = (Map<String, Object>) m.get('recipient');
		mess.CVCH__To__c = (String) mTo.get('id');
		mess.CVCH__To_Name__c = (String) mTo.get('name');
		mess.CVCH__ChannelId__c = (String) mTo.get('channelId');
		mess.CVCH__Channel__c = 'Azure';
		Map<String, Object> mConv = (Map<String, Object>) m.get('conversation');

		mess.CVCH__conversationId__c = (String) mConv.get('id');
		mess.CVCH__conversationName__c = (String) mConv.get('name');
		SM042_NexmoOut2.setInboundMessage(mess);
		return mess;
	}

	private static NexmoMessage__c D360Message(Map<String, Object> mObj)
	{
		System.debug('D360Message.start');
		List<Object> lMess = (List<Object> ) mObj.get('messages');
		Map<String, Object> m = (Map<String, Object>) lMess[0];
		CVCH__NexmoMessage__c mess = new CVCH__NexmoMessage__c();
		mess.Name = (String) m.get('id');
		mess.CVCH__Channel__c = 'D360';
		mess.CVCH__From__c = (String) m.get('from');
		mess.From_Name__c = (String) JPath.get0(mObj, '/contacts/[1]/profile/name');
		mess.CVCH__InputType__c = (String) m.get('type');
		if (mess.CVCH__InputType__c == 'text')
			mess.CVCH__Text__c = (String) ((Map<String, Object>) m.get('text')).get('body');
		else if (mess.CVCH__InputType__c == 'image')
			mess.ImageURL__c = (String) ((Map<String, Object>) m.get('image')).get('url');
		else if (mess.CVCH__InputType__c == 'file')
			mess.ImageURL__c = (String) ((Map<String, Object>) m.get('file')).get('url');
		else if (mess.CVCH__InputType__c == 'button')
			mess.CVCH__Text__c = (String) ((Map<String, Object>) m.get('button')).get('payload');
		SM042_NexmoOut2.setInboundMessage(mess);
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
		system.debug('mess.CVCH__InputType__c =  '+mess.CVCH__InputType__c );
		if (mess.CVCH__InputType__c == 'text')
			mess.CVCH__Text__c = (String) m.get('text');
		else if (mess.CVCH__InputType__c == 'image')
			mess.ImageURL__c = (String) ((Map<String, Object>) m.get('image')).get('url');
		else if (mess.CVCH__InputType__c == 'file')
			mess.ImageURL__c = (String) ((Map<String, Object>) m.get('file')).get('url');
		else if (mess.CVCH__InputType__c == 'button')
		{
			mess.CVCH__Text__c = (String) ((Map<String, Object>) m.get('button')).get('payload');
			system.debug('CVCH__InputType__c = button, CVCH__Text__c='+mess.CVCH__Text__c+', m='+JSON.serialize(m));
		}

		else if(mess.CVCH__InputType__c == 'reply')
		{
			string sId = (String) ((Map<String, Object>) m.get('reply')).get('id');
			string sTitle = (String) ((Map<String, Object>) m.get('reply')).get('title');
			if(sId.startsWith('flow_'))
			{
				mess.CVCH__Flow__c = sId.replaceFirst('flow_','');
				mess.CVCH__Text__c = sTitle;
			}
			else
			{
				mess.CVCH__Text__c = sId;
			}
		}

		system.debug('mess.CVCH__Text__c = '+mess.CVCH__Text__c);
		List<CVCH__NexmoMessage__c> lold =
		[
				select Id
				from CVCH__NexmoMessage__c
				where Name = :mess.Name
		];
		if (!lold.isEmpty())
			mess = null;

		SM042_NexmoOut2.setInboundMessage(mess);
		System.debug('NexmoV1Message.return');
		System.debug(mess);
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
		System.debug('message_uuid = '+message_uuid);
		if (message_uuid == null && (String) m.get('type') != null)
		{
			return getAzureMessage(m);
		}
		Map<String, Object> mFrom;
		try
		{
			mFrom = (Map<String, Object>) m.get('from');
		}catch(Exception e)
		{
			return NexmoV1Message(m);
		}

		String sFrom = SM010_Utils.phone((string) mFrom.get('number'));
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

		List<CVCH__NexmoMessage__c> lold =
		[
				select Id
				from CVCH__NexmoMessage__c
				where Name = :mess.Name
		];
		if (!lold.isEmpty())
			mess = null;
		System.debug('parse.return ' + mess);
		SM042_NexmoOut2.setInboundMessage(mess);
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
			SM042_NexmoOut2.sendText(mess0.CVCH__From__c, sErrorMessage, mess0.CVCH__To__c);
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
		if (mess0 != null && mess0.CVCH__From__c != null)
		{
			SM042_NexmoOut2.sendText(mess0.CVCH__From__c, sErrorMessage, mess0.CVCH__To__c);
		}
	}
	@Future(Callout = true)
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
		List<CVCH__NexmoMessage__c>lMess = new List<CVCH__NexmoMessage__c>();
		try
		{
			mess0 = parse(jsonbody);
			if (mess0 == null)
				return lMess;
			lMess.add(mess0);
			visr = getVisitor(mess0.CVCH__From__c, mess0.CVCH__To__c, mess0.CVCH__Channel__c);

			mess0.CVCH__Received__c = dtBeg;

			List<MessageOptions> aRetStr = getResponse(mess0, visr);
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
//				lMess.add(mess0);
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
			System.debug('error: ' + e.getMessage()+' '+e.getStackTraceString());
			sendError(mess0, '' + e.getLineNumber() + ' ' + e.getMessage() + ' ' + e.getStackTraceString(), visr);
			if (Test.isRunningTest())
				throw e;
		}
		finally
		{
//			if (mess0 != null)
//			{
			try
			{
				SM005_Logs.LogCallOut('', 'Nexmo', jsonbody, JSON.serialize(lMess), dtBeg, Datetime.now(), errMsg);
				SM005_Logs.save();
				SM010_Utils.saveTran();
				if (mess0 != null)
				{
					mess0.CVCH__Responded__c = Datetime.now();
					mess0.CVCH__Duration__c = mess0.CVCH__Responded__c.getTime() - mess0.CVCH__Received__c.getTime();
				}
				if (lMess != null)
					insert lMess;
				SM010_Utils.insertConversation(scoreLUIS, scoreQnA, intentLUIS, triggeredFlow, visr.language__c, visr.CVCH__Id__c, mess0.Text__c, sOutput, visr.Id, errMsg);
				if (triggeredLUIS)
				{ // if we got LUIS response for query - log Search Request for keyword, if present
					SM010_Utils.logSearchRequest(respLuis);
				}
			}
			catch (Exception e)
			{

			}

//			}
		}
		return lMess;
	}
}
