/*

File: mcXmlReader.m
Abstract: Uses NSXMLParser to extract the contents of an XML file and map it
Objective-C model objects.
 
 This whole thing is pretty abominable, but who really cares how elegant it is since no one can see it 


*/

#import "mcXmlReader.h"
#import "mcUrlConnection.h"

static NSUInteger parsedPatientsCounter;
static NSUInteger parsedGiversCounter;
static NSString *gDataPath;

@implementation mcXmlReader
@synthesize currentPersonObject = _currentPersonObject;
@synthesize currentPersonProperty = _currentPersonProperty;

// Limit the number of parsed peoples to 50. Otherwise the application runs very slowly on the device.
#define MAX_PATIENTS 50


- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    parsedPatientsCounter = 0;
	// should write file out at this point
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    gDataPath = (NSString *)[[paths objectAtIndex:0] stringByAppendingPathComponent:@"FamilyCareTeam"];
}

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error
{	
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
    NSLog(@"patients= %i",parsedPatientsCounter);
    NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
    }
    
    [parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) {
        elementName = qName;
    }

    // If the number of patients is greater than MAX_ELEMENTS, abort the parse.
    // Otherwise the application runs very slowly on the device.
    if (parsedPatientsCounter >= MAX_PATIENTS) {
        [parser abortParsing];
    }
    
    if ([elementName isEqualToString:@"patient"]) {
        
        parsedPatientsCounter++;
        
        // An entry in the xml response represents a patient  so create an instance of it.
        self.currentPersonObject = [[Patient alloc] init];
        // Add the new Patient object to the application's array of patients. -- needs more thought
        [(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(addToPersonList:) withObject:self.currentPersonObject waitUntilDone:YES];
        return;
    } else
		if ([elementName isEqualToString:@"user"]) {
			
			parsedGiversCounter++;
			
			// An entry in the xml response represents a patient  so create an instance of it.
			self.currentPersonObject = [[Giver alloc] init];
			// Add the new Patient object to the application's array of patients. -- needs more thought
			[(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(addToPersonList:) withObject:self.currentPersonObject waitUntilDone:YES];
			return;
		}
      
 else 
	 if ([elementName isEqualToString:@"firstname"] || [elementName isEqualToString:@"lastname"] || [elementName isEqualToString:@"mcid"]||
		  [elementName isEqualToString:@"sex"]||[elementName isEqualToString:@"sponsorfbid"] || [elementName isEqualToString:@"familyfbid"] || 
		  [elementName isEqualToString:@"oauth_token"] || [elementName isEqualToString:@"oauth_secret"] || [elementName isEqualToString:@"applianceurl"] || 
		  [elementName isEqualToString:@"photoUrl"] || [elementName isEqualToString:@"gw_modified_date_time"]|| [elementName isEqualToString:@"alertlevel"]
		 || [elementName isEqualToString:@"hurl"]) {
        // Create a mutable string to hold the contents of thelement.
        // The contents are collected in parser:foundCharacters:.
        self.currentPersonProperty = [NSMutableString string];
		}
 else {
        // The element isn't one that we care about, so set the property that holds the 
        // character content of the current element to nil. That way, in the parser:foundCharacters:
        // callback, the string that the parser reports will be ignored.
        self.currentPersonProperty = nil;
    }
}

- (void)photo_loader:(NSString *)kind {
			// start loading photo now, the asynchronous callbacks come to us in this thread, so just put them down below
			  self.currentPersonObject.photoFileSpec = 
			[NSString stringWithFormat:@"%@/%@-%@-%@.png",gDataPath, self.currentPersonObject.firstname,self.currentPersonObject.lastname,self.currentPersonObject.mcid];
			
			
			mcUrlConnection *theConnection = [mcUrlConnection alloc];
			[theConnection initWithURL: [NSURL URLWithString:self.currentPersonObject.photoUrl] 
							  delegate: self.currentPersonObject];
			
			NSLog(@"%@ %@ %@ %@",kind, self.currentPersonObject.mcid,self.currentPersonObject.firstname,self.currentPersonObject.lastname);
			self.currentPersonObject.photoState = @"pending";
			NSLog(@"loading %@ into %@",self.currentPersonObject.photoUrl,self.currentPersonObject.photoFileSpec);

}


/**
 * util function: current timestamp

private static function generate_timestamp() {    return time();
}*/

/*
private static function generate_nonce()
    $mt = microtime();
    $rand = mt_rand();
	
    return md5($mt . $rand); // md5s look nicer than numbers
}
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
    if (qName) { 
        elementName = qName;
    }
	// use the patients end tag to trigger processing of the whole group of patients now that they are all in
	// lets go load up all the pictures
	
	if ([elementName isEqualToString:@"patients"]) 
		
	{
		NSLog(@"All patients loaded");

	}
	if ([elementName isEqualToString:@"careteam"]) 
		
	{
		NSLog(@"All givers loaded");
		
	}
	// when closing out the patient we create the links we need for either
	
	if ([elementName isEqualToString:@"patient"])
	{
		/*
		//https://tenth.medcommons.net/?m=1188231681939301&t=dd8c32577919778eed18d0995e09a98f5fd8f297&s=7b9a24ab8d208ed785dff14445f61647243ac891


		
		//https://tenth.medcommons.net/1188231681939301?oauth_version=1.0&oauth_nonce=f7df963dd7e38194141dc77b9839fb5c&oauth_timestamp=1242564096&oauth_consumer_key=3a211604e88110c6caa6161fd0e692368a7d0b58&oauth_token=dd8c32577919778eed18d0995e09a98f5fd8f297&oauth_signature_method=HMAC-SHA1&oauth_signature=nNPI2e2wJwOxL7IAmLsTIa9w1Ig%3D
		    #include <sys/time.h>		
			#include <CommonCrypto/CommonDigest.h>

		
			struct timeval tval;
		
		unsigned char *md5digest;
		md5digest = malloc(CC_MD5_DIGEST_LENGTH+1);
			
		int retval = gettimeofday(&tval, NULL);
		if (retval==0)
		{
			// for the nonce just take the md5 of the microsecond time
		md5digest[CC_MD5_DIGEST_LENGTH]=0;
		CC_MD5(&tval,sizeof(tval),md5digest);
		// needs work
		

		}

	
		NSString *stringFromUTFString = [[NSString alloc] initWithUTF8String:(char *)md5digest];
		NSString *link = [NSString stringWithFormat:@"%@%@?oauth_version=1.0&oauth_nonce=%@&oauth_token=%@&secretkey=%@&oauth_timestamp=%i&oauth_consumer_key=&oauth_signature=&oauth_signature_method=", self.currentPersonObject.applianceurl,
						  self.currentPersonObject.mcid,stringFromUTFString,self.currentPersonObject.oauth_token,
						  self.currentPersonObject.oauth_secret, time(nil)];
		 
		 */
		self.currentPersonObject.webLink = self.currentPersonObject.hurl;		
		
		[self photo_loader:@"patient"];
		
		
	}
	else
		if ([elementName isEqualToString:@"user"])
		{
			self.currentPersonObject.webLink = @"";			
			[self photo_loader:@"giver"];
	
		}
	
		
	else
	{		
		if ([elementName isEqualToString:@"firstname"]) {
			self.currentPersonObject.firstname = [self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				
		} else if ([elementName isEqualToString:@"lastname"]) {
			self.currentPersonObject.lastname = [self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
			
		} else if ([elementName isEqualToString:@"mcid"]) {
			self.currentPersonObject.mcid =[self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				
		}
		else if ([elementName isEqualToString:@"sex"]) {
		self.currentPersonObject.sex = [self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];		}
		
		else if ([elementName isEqualToString:@"sponsorfbid"]) {
			self.currentPersonObject.sponsorfbid =[self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
		
		else if ([elementName isEqualToString:@"familyfbid"]) {
			self.currentPersonObject.familyfbid = [self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
		else if ([elementName isEqualToString:@"oauth_token"]) {
			self.currentPersonObject.oauth_token = [self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
		
		else if ([elementName isEqualToString:@"oauth_secret"]) {
			self.currentPersonObject.oauth_secret = [self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
		
		else if ([elementName isEqualToString:@"applianceurl"]) {
			self.currentPersonObject.applianceurl = [self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
		
		else if ([elementName isEqualToString:@"photoUrl"]) {
			self.currentPersonObject.photoUrl = [self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		}
		
		else if ([elementName isEqualToString:@"gw_modified_date_time"]) {
			self.currentPersonObject.gw_modified_date_time = [self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
		else if ([elementName isEqualToString:@"alertlevel"]) {
			self.currentPersonObject.alertlevel = [self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		 	}
		else if ([elementName isEqualToString:@"hurl"]) {
			self.currentPersonObject.hurl = [self.currentPersonProperty  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
	}
	
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.currentPersonProperty) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.currentPersonProperty appendString:string];
    }
}



@end
