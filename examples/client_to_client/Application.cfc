<cfscript>

component 
	output = "false"
	hint = "I define the application settings and event handlers."
	{


	// Define the application settings. 
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 0, 10, 0 );
	this.sessionManagement = false;

	// Get the current directory and the root directory so that we can
	// set up the mappings to our components.
	this.appDirectory = getDirectoryFromPath( getCurrentTemplatePath() );
	this.projectDirectory = ( this.appDirectory & "../../" );

	// Map to our Lib folder so we can access our project components.
	this.mappings[ "/lib" ] = ( this.projectDirectory & "lib/" );

	// Map to our Vendor folder so we can access 3rd-party components.
	this.mappings[ "/vendor" ] = ( this.projectDirectory & "vendor/" );


	// I initialize the request.
	public boolean function onRequestStart(){

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
		// credentials.
		request.pusher = new lib.Pusher(
			appID = request.pusherAppID,
			appKey = request.pusherKey,
			appSecret = request.pusherSecret
		);

		// Return true so the page can load.
		return( true );

	}


}

</cfscript>