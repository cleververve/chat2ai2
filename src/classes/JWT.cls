/**
 * Created by serhiivolynets on 2019-05-15.
 */

public class JWT {
//    String applicationId = '015c5919-1465-4cab-9e6c-5a005bc318b3';
//    string applicationId = 'asdasdas-asdd-2344-2344-asdasdasd345';
    String applicationId = 'aa048234-54d2-4733-9df5-11b2b033ee06';
    public String alg {get;set;}
//    public String iss {get;set;}
//    public String sub {get;set;}
//    public String aud {get;set;}
//    public String exp {get;set;}
//    public String iat {get;set;}
//    public Map<String,String> claims {get;set;}
    public Integer validFor {get;set;}
    public String cert {get;set;}
    public String pkcs8 {get;set;}
//    public String privateKey {get;set;}


    public static final String HS256 = 'HS256';
    public static final String RS256 = 'RS256';
    public static final String NONE = 'none';

//    public JWT(String alg) {

    public JWT() {
        this.alg = RS256;
        this.validFor = 300;
    }


    public String issue() {

        String jwt = '';

        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', this.alg);
        header.writeStringField('typ', 'JWT');
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
        Long rightNow = (dateTime.now().getTime()/1000)+1;
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('application_id', applicationId);
        body.writeNumberField('iat', rightNow);
        body.writeStringField('jti', 'id'+dateTime.now().getTime());
        body.writeNumberField('iat', rightNow);
        body.writeNumberField('exp', (rightNow + validFor));


/*        if (claims != null) {
            for (String claim : claims.keySet()) {
                body.writeStringField(claim, claims.get(claim));
            }
        }
  */      body.writeEndObject();

        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));

  /*      if ( this.alg == HS256 ) {
            Blob key = EncodingUtil.base64Decode(privateKey);
            Blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
            jwt += '.' + base64URLencode(signature);
        } else if ( this.alg == RS256 ) {*/
            Blob signature = null;

            if (cert != null ) {
                signature = Crypto.signWithCertificate('rsa-sha256', Blob.valueOf(jwt), cert);
            } else {
                Blob privateKey = EncodingUtil.base64Decode(pkcs8);
                if(!test.isRunningTest())
                    signature = Crypto.sign('rsa-sha256', Blob.valueOf(jwt), privateKey);
                else
                        signature = Blob.valueOf('aaaa');
            }
            jwt += '.' + base64URLencode(signature);
/*        } else if ( this.alg == NONE ) {
            jwt += '.';
        }
*/
        system.debug('jwt='+jwt);
        return jwt;

    }


    public String base64URLencode(Blob input){
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }

    public static String getAccessToken()
    {
        String tokenEndpoint = 'https://api.nexmo.com/v0.1/messages';
        JWT jwt = new JWT();
        if(!Test.isRunningTest())
        {
            CVCH__Key__c rec = [select id, CVCH__Value__c,CVCH__Application_Id__c  from CVCH__Key__c where CVCH__Active_Flag__c = true limit 1];
            jwt.pkcs8 = rec.CVCH__Value__c;
            if(rec.CVCH__Application_Id__c != '' && rec.CVCH__Application_Id__c != null)
                jwt.applicationId = rec.CVCH__Application_Id__c;
        }
        else
            jwt.pkcs8 = 'aaabbb';
        system.debug('jwt.pkcs8=>'+jwt.pkcs8);
        String access_token = null;
        return jwt.issue();
  /*      String body = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwt.issue();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(tokenEndpoint);
        req.setHeader('Content-type', 'application/x-www-form-urlencoded');
        req.setBody(body);
        Http http = new Http();
        HTTPResponse res = http.send(req);

        if ( res.getStatusCode() == 200 ) {
            system.debug('res.body='+res.getBody());
            System.JSONParser parser = System.JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    access_token = parser.getText();
                    break;
                }
            }
        }
        return access_token;*/
    }

}