/**
Author:         serhiivolynets
Date:           30.07.2022
Description:   
**/

public class SM098_FacebookCatalog
{

	public static void sendSingleProduct(String sTo,String sFrom, String bodyText, String footerText, String catalogId, String SKU)
	{
		SM003_Http.request(getURL(),'POST',getHeaders(sFrom),getSingleProductBody(sTo, bodyText, footerText, catalogId, SKU),'FacebookSingleProduct',null,'DummySuccessMock',true);
	}

	public static void sendMultiProducts(String sTo,String sFrom, String bodyText, String footerText, String catalogId, String sections,String headerText)
	{
		SM003_Http.request(getURL(),'POST',getHeaders(sFrom),getMultiProductBody(sTo, bodyText, footerText, catalogId,  sections, headerText),'FacebookMultiProduct',null,'DummySuccessMock', true);
	}


	public static Map<String,String> getHeaders(String sFrom)
	{
		return SM043_360Dialog.getHeaders(sFrom);
	}


	public static String getURL()
	{
		return SM043_360Dialog.getMessagesURL();
	}

	public static String getSingleProductBody(String sTo, String bodyText, String footerText, String catalogId, String SKU)
	{
		Map<String, Object> mBody = new Map<String, Object>
		{
				'text' => bodyText
		};
		Map<String, Object> mFooter = new Map<String, Object>
		{
				'text' => footerText
		};
		Map<String, Object> mAction = new Map<String, Object>
		{
				'catalog_id' => catalogId,
				'product_retailer_id' => SKU
		};
		Map<String, Object> mInteractive = new Map<String, Object>
		{
				'type' => 'product',
				'body' => mBody,
				'footer' => mFooter,
				'action' => mAction
		};
		Map<String, Object> mRet = new Map<String, Object>
		{
				'recipient_type' => 'individual',
				'to' => sTo,
				'type' => 'interactive',
				'interactive' => mInteractive
		};
		return JSON.serialize(mRet);
	}

	public static String getMultiProductBody(String sTo, String bodyText, String footerText, String catalogId, String sections, String headerText)
	{
		Map<String, Object> mBody = new Map<String, Object>
		{
				'text' => bodyText
		};
		Map<String, Object> mFooter = new Map<String, Object>
		{
				'text' => footerText
		};

		Map<String, Object> mHeader = new Map<String, Object>
		{
				'type' => 'text',
				'text' => headerText
		};

//		List<Object>lSections = new List<Object>();
//		for(FlowFacebookCatalogMulti.CatalogSection sec : lSect)
//		{
//			List<Object> lProdItems = new List<Object>();
//			Map<String,Object> mAdd = new Map<String,Object>{'title' => sec.title,'product_items'=> lProdItems};
//			for(String Sku : sec.productItems)
//			{
//				lProdItems.add(new Map<String,Object>{'product_retailer_id' => Sku});
//			}
//			lSections.add(mAdd);
//		}
		List<Object> lSections = (List<Object>)JSON.deserializeUntyped(sections);

		Map<String, Object> mAction = new Map<String, Object>
		{
				'catalog_id' => catalogId,'sections'=> lSections
		};
		Map<String, Object> mInteractive = new Map<String, Object>
		{
				'type' => 'product_list',
				'body' => mBody,
				'footer' => mFooter,
				'action' => mAction,
				'header' => mHeader
		};
		Map<String, Object> mRet = new Map<String, Object>
		{
				'recipient_type' => 'individual',
				'to' => sTo,
				'type' => 'interactive',
				'interactive' => mInteractive
		};
		return JSON.serialize(mRet);
	}
}
