<cfscript>

component 
	output = "false"
	hint = "I define the application settings and event handlers."
	{


	// Define the application settings. 
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 0, 10, 0 );

	// Enable session management so we can have CFID/CFTOKEN values.
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan( 0, 0, 1, 0 );

	// Get the current directory and the root directory so that we can
	// set up the mappings to our components.
	this.appDirectory = getDirectoryFromPath( getCurrentTemplatePath() );
	this.projectDirectory = (this.appDirectory & "../../");

	// Map to our Lib folder so we can access our project components.
	this.mappings[ "/lib" ] = (this.projectDirectory & "lib/");

	// Map to our Vendor folder so we can access 3rd-party components.
	this.mappings[ "/vendor" ] = (this.projectDirectory & "vendor/");


	// I initialize the session.
	function onSessionStart(){

		// Store some information about the user that we can pass 
		// through to the Presence channel.
		session.user = {
			id = 4,
			name = "Tricia"
		};

	}


	// I initialize the request.
	function onRequestStart(){

		// Store the credentials for the Pusher App API. 
		// *********************************************************
		// THESE ARE DEMO CREDENTIALS AND SHOULD NOT BE USED IN YOUR
		// PRODUCTION APP; THEY ARE FOR SANDBOX USE AND HAVE HARD
		// LIMITS ON CONNECTIONS AND MESSAGES. SWAP THESE OUT WHEN
		// YOU IMPLEMENT THIS LIBRARY.
		// *********************************************************
		request.pusherAppID = "1577";
		request.pusherKey = "967025141727846f5a79";
		request.pusherSecret = "5a7fd901cdf3e73c18b5";
		// *********************************************************

		// Create an instance of our pusher component using our demo
		// credentials and the Crypto library.
		request.pusher = new lib.Pusher(
			appID = request.pusherAppID,
			appKey = request.pusherKey,
			appSecret = request.pusherSecret,
			crypto = new vendor.crypto.Crypto()
		);

		// Return true so the page can load.
		return( true );

	}


}

</cfscript>