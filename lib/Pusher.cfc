<cfcomponent
	output="false"
	hint="I provide a gateway to the PusherApp realtime publication server.">


	<cffunction
		name="init"
		access="public"
		returntype="any"
		output="false"
		hint="I initialize the component. The Crypto library is used to create Hashed Message Authentication Codes for creating request signatures.">

		<!--- Define arguments. --->
		<cfargument
			name="appID"
			type="string"
			required="true"
			hint="I am the Pusher App ID."
			/>

		<cfargument
			name="appKey"
			type="string"
			required="true"
			hint="I am the Pusher App key."
			/>

		<cfargument
			name="appSecret"
			type="string"
			required="true"
			hint="I am the Pusher App secret."
			/>

		<cfargument
			name="crypto"
			type="any"
			required="true"
			hint="I the Crypto library, needed to generate hmac-hashes - hmacSha256()."
			/>

		<!--- Store the properties. --->
		<cfset variables.appID = appID />
		<cfset variables.appKey = appKey />
		<cfset variables.appSecret = appSecret />
		<cfset variables.crypto = crypto />

		<!--- Return this object reference. --->
		<cfreturn this />

	</cffunction>


	<!---
	// PUBLIC METHODS
	--->


	<cffunction
		name="getPresenceChannelAuthentication"
		access="public"
		returntype="struct"
		output="false"
		hint="I return the authentication object for a presence channel subscription using the given socket. The [data] argument must contain a user_id key and an optional user_info key.">

		<!--- Define arguments. --->
		<cfargument
			name="socketID"
			type="string"
			required="true"
			hint="I am the socket ID the user is connected to (on the Pusher app)."
			/>

		<cfargument
			name="channel"
			type="string"
			required="true"
			hint="I am the channel the user is trying to subscribe to."
			/>

		<cfargument
			name="data"
			type="struct"
			required="true"
			hint="I am the user data being passed to Pusher along with the user subscription."
			/>

		<!--- Serialize the user data - we'll need it for the signature as well as for the authenication response object. --->
		<cfset var serializedData = serializeJSON( data ) />

		<!--- Create a hashed signature for the sockect-channel-data combination. --->
		<cfset var signature = this._hmacSha256(
			variables.appSecret,
			"#socketID#:#channel#:#serializedData#"
			) />

		<!--- Create the authentication response using the app key, our signature, and the data to pass through as part of the channel subscription. --->
		<cfset var authentication = {} />
		<cfset authentication[ "auth" ] = (variables.appKey & ":" & signature) />
		<cfset authentication[ "channel_data" ] = serializedData />

		<cfreturn authentication />

	</cffunction>


	<cffunction
		name="getPrivateChannelAuthentication"
		access="public"
		returntype="struct"
		output="false"
		hint="I return the authentication object for a private channel subscription using the given socket.">

		<!--- Define arguments. --->
		<cfargument
			name="socketID"
			type="string"
			required="true"
			hint="I am the socket ID the user is connected to (on the Pusher app)."
			/>

		<cfargument
			name="channel"
			type="string"
			required="true"
			hint="I am the channel the user is trying to subscribe to."
			/>

		<!--- Create a hashed signature for the sockect-channel-data combination. --->
		<cfset var signature = this._hmacSha256(
			variables.appSecret,
			"#socketID#:#channel#"
			) />

		<!--- Create the authentication response using the app key and our signature. --->
		<cfset var authentication = {} />
		<cfset authentication[ "auth" ] = (variables.appKey & ":" & signature) />

		<cfreturn authentication />

	</cffunction>


	<cffunction
		name="pushToAllSubscribers"
		access="public"
		returntype="any"
		output="false"
		hint="I publish the given event to all active subscribers of the given channel. The message data will be serialized as JSON before it is pushed to the subscribers.">

		<!--- Define arguments. --->
		<cfargument
			name="channel"
			type="string"
			required="true"
			hint="I am the channel on which to push the event."
			/>

		<cfargument
			name="eventType"
			type="string"
			required="true"
			hint="I am the event type being triggered."
			/>

		<cfargument
			name="message"
			type="any"
			required="true"
			hint="I am the message being pushed to the subscribers."
			/>

		<!--- Post the message to Pusher. --->
		<cfset var response = this._postEvent( channel, eventType, message ) />

		<!--- Return the underlying HTTP response. --->
		<cfreturn response />

	</cffunction>


	<cffunction
		name="pushToAllSubscribersExcept"
		access="public"
		returntype="any"
		output="false"
		hint="I publish the given event to all active subscribers except for the given subscriber on the given channel. The message data will be serialized as JSON before it is pushed.">

		<!--- Define arguments. --->
		<cfargument
			name="channel"
			type="string"
			required="true"
			hint="I am the channel on which to push the event."
			/>

		<cfargument
			name="eventType"
			type="string"
			required="true"
			hint="I am the event type being triggered."
			/>

		<cfargument
			name="message"
			type="any"
			required="true"
			hint="I am the message being pushed to the subscribers."
			/>

		<cfargument
			name="socketID"
			type="string"
			required="true"
			hint="I am the socketID that originated the message."
			/>

		<!--- Post the message to Pusher. --->
		<cfset var response = this._postEvent( channel, eventType, message, socketID ) />

		<!--- Return the underlying HTTP response. --->
		<cfreturn response />

	</cffunction>


	<!---
	// PRIVATE METHODS
	--->


	<cffunction
		name="_hmacSha256"
		access="public"
		returntype="any"
		output="false"
		hint="I compute a hashed message authentication code using the SHA-256 algorithm.">

		<!--- Define arguments. --->
		<cfargument
			name="key"
			type="string"
			required="true"
			hint="I am the secret key being used to generate the hash."
			/>

		<cfargument
			name="input"
			type="string"
			required="true"
			hint="I am the value being hashed."
			/>

		<!--- Pass this off to the Crypto library. --->
		<cfreturn
			variables.crypto.hmacSha256( key, input )
			/>

	</cffunction>


	<cffunction
		name="_postEvent"
		access="public"
		returntype="any"
		output="false"
		hint="I communicate with the actual Pusher API.">

		<!--- Define arguments. --->
		<cfargument
			name="channel"
			type="string"
			required="true"
			hint="I am the channel on which to push the event."
			/>

		<cfargument
			name="eventType"
			type="string"
			required="true"
			hint="I am the event type being triggered."
			/>

		<cfargument
			name="message"
			type="any"
			required="true"
			hint="I am the message being pushed to the subscribers."
			/>

		<cfargument
			name="socketID"
			type="string"
			required="false"
			default=""
			hint="I am the socketID that originated the message."
			/>

		<!--- Serialize the message for transport. --->
		<cfset var serializedMessage = serializeJSON( message ) />

		<!--- Build the resource URI. --->
		<cfset var resourceUri = "/apps/#variables.appID#/channels/#channel#/events" />

		<!--- Get the current the epoch time in seconds (API requires seconds, not milliseconds). --->
		<cfset var epochTimeInSeconds = (getTickCount() / 1000) />

		<!--- Get the MD5 hash of the body. --->
		<cfset var md5Body = lcase( hash( serializedMessage, "md5" ) ) />

		<!--- Define the version of the API we are using. As of this writing, version 1.0 is the latest. --->
		<cfset var apiVersion = "1.0" />

		<!--- In order post, we have to create a signature of the request. --->
		<cfset var requestParts = [
			"POST",
			chr( 10 ),
			resourceUri,
			chr( 10 ),
			"auth_key=#variables.appKey#&",
			"auth_timestamp=#epochTimeInSeconds#&",
			"auth_version=#apiVersion#&",
			"body_md5=#md5Body#&",
			"name=#eventType#&",
			"socket_id=#socketID#"
			] />

		<!--- Get the auth signature using Hmac-Sha256 hashing. --->
		<cfset var signature = this._hmacSha256(
			variables.appSecret,
			arrayToList( requestParts, "" )
			) />

		<!--- Var the HTTP response. --->
		<cfset var httpResponse = {} />

		<!--- Build the HTTP request. --->
		<cfhttp
			result="httpResponse"
			method="post"
			url="http://api.pusherapp.com#resourceUri#"
			charset="utf-8">

			<cfhttpparam
				type="url"
				name="name"
				value="#eventType#"
				/>

			<cfhttpparam
				type="url"
				name="body_md5"
				value="#md5Body#"
				/>

			<cfhttpparam
				type="url"
				name="socket_id"
				value="#socketID#"
				/>

			<cfhttpparam
				type="url"
				name="auth_key"
				value="#variables.appKey#"
				/>

			<cfhttpparam
				type="url"
				name="auth_timestamp"
				value="#epochTimeInSeconds#"
				/>

			<cfhttpparam
				type="url"
				name="auth_signature"
				value="#signature#"
				/>

			<cfhttpparam
				type="url"
				name="auth_version"
				value="#apiVersion#"
				/>

			<!--- The message must be passed through as a JSON body. --->
			<cfhttpparam
				type="header"
				name="content-type"
				value="application/json"
				/>

			<cfhttpparam
				type="body"
				value="#serializedMessage#"
				/>

		</cfhttp>

		<!--- Return the response. --->
		<cfreturn httpResponse />

	</cffunction>


</cfcomponent>