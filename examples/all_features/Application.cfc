<cfcomponent 
	output="false"
	hint="I define the application settings and event handlers.">


	<!--- Define the application settings. --->
	<cfset this.name = hash( getCurrentTemplatePath() ) />
	<cfset this.applicationTimeout = createTimeSpan( 0, 0, 10, 0 ) />

	<!--- Enable session management so we can have CFID/CFTOKEN values. --->
	<cfset this.sessionManagement = true />
	<cfset this.sessionTimeout = createTimeSpan( 0, 0, 1, 0 ) />

	<!--- Get the current directory and the root directory so that we can set up the mappings to our components. --->
	<cfset this.appDirectory = getDirectoryFromPath( getCurrentTemplatePath() ) />
	<cfset this.projectDirectory = (this.appDirectory & "../../") />

	<!--- Map to our Lib folder so we can access our project components. --->
	<cfset this.mappings[ "/lib" ] = (this.projectDirectory & "lib/") />

	<!--- Map to our Vendor folder so we can access 3rd-party components. --->
	<cfset this.mappings[ "/vendor" ] = (this.projectDirectory & "vendor/") />


	<!--- Turn off all debugging. --->
	<cfsetting showdebugoutput="false" />


	<cffunction
		name="onSessionStart"
		access="public"
		returntype="void"
		output="false"
		hint="I initialize the session.">

		<!--- Store some information about the user that we can pass through to the Presence channel. --->
		<cfset session.user = {} />
		<cfset session.user[ "id" ] = 4 />
		<cfset session.user[ "name" ] = "Tricia" />

	</cffunction>


	<cffunction
		name="onRequestStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="I initialize the request.">

		<!---
			Store the credentials for the Pusher App API. 
			*********************************************************
			THESE ARE DEMO CREDENTIALS AND SHOULD NOT BE USED IN YOUR
			PRODUCTION APP; THEY ARE FOR SANDBOX USE AND HAVE HARD
			LIMITS ON CONNECTIONS AND MESSAGES. SWAP THESE OUT WHEN
			YOU IMPLEMENT THIS LIBRARY.
			*********************************************************
		--->
		<cfset request.pusherAppID = "1577" />
		<cfset request.pusherKey = "967025141727846f5a79" />
		<cfset request.pusherSecret = "5a7fd901cdf3e73c18b5" />
		<!---
			*********************************************************
		--->

		<!--- Create an instance of our pusher component using our demo credentials and the Crypto library. --->
		<cfset request.pusher = createObject( "component", "lib.Pusher" ).init(
			appID = request.pusherAppID,
			appKey = request.pusherKey,
			appSecret = request.pusherSecret,
			crypto = createObject( "component", "vendor.crypto.Crypto" ).init()
			) />

		<!--- Return true so the page can load. --->
		<cfreturn true />

	</cffunction>


</cfcomponent>