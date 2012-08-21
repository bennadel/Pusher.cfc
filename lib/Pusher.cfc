<cfscript>

component
	output = "false"
	hint = "I provide a gateway to the PusherApp realtime publication server."
	{


	// I initialize the component.
	function init(
		String appID,
		String appKey,
		String appSecret
		){

		// Store the properties.
		variables.appID = appID;
		variables.appKey = appKey;
		variables.appSecret = appSecret;

		// Return this object reference.
		return( this );

	}


	// ---
	// PUBLIC METHODS
	// ---


	// I return the authentication object for a presence channel subscription using the given socket.
	// The [data] argument must contain a user_id key and an optional user_info key.
	function getPresenceChannelAuthentication( 
		String socketID,
		String channel,
		Struct data
		){

		// Serialize the user data - we'll need it for the signature as well as for the authenication
		// response object.
		var serializedData = serializeJSON( data );

		// Create a hashed signature for the sockect-channel-data combination.
		var signature = this._hmacSha256(
			variables.appSecret,
			"#socketID#:#channel#:#serializedData#"
		);

		// Create the authentication response using the app key, our signature, and the data to pass
		// through as part of the channel subscription.
		var authentication = {
			"auth" = (variables.appKey & ":" & signature),
			"channel_data" = serializedData
		};

		return( authentication );

	}


	// I return the authentication object for a private channel subscription using the given socket.
	function getPrivateChannelAuthentication(
		String socketID,
		String channel
		){

		// Create a hashed signature for the sockect-channel combination.
		var signature = this._hmacSha256(
			variables.appSecret,
			"#socketID#:#channel#"
		);

		// Create the authentication response using the app key and our signature.
		var authentication = {
			"auth" = (variables.appKey & ":" & signature)
		};

		return( authentication );

	}


	// I publish the given event to all active subscribers of the given channel. The message data
	// will be serialized as JSON before it is pushed to the subscribers.
	function pushToAllSubscribers(
		String channel,
		String eventType,
		Any message
		){

		// Post the message to Pusher.
		var response = this._postEvent( channel, eventType, message );

		// Return the underlying HTTP response.
		return( response );

	}


	// I publish the given event to all active subscribers except for the given subscriber on the 
	// given channel. The message data will be serialized as JSON before it is pushed.
	function pushToAllSubscribersExcept(
		String channel,
		String eventType,
		Any message,
		String socketID
		){

		// Post the message to Pusher.
		var response = this._postEvent( channel, eventType, message, socketID );

		// Return the underlying HTTP response.
		return( response );

	}


	// ---
	// PRIVATE METHODS
	// ---


	// I compute a hashed message authentication code using the SHA-256 algorithm.
	function _hmacSha256( String key, String input ){

		// Pass this off to the hmac() function.
		return(
			lcase( hmac( input, key, "HmacSHA256" ) )
		);

	}


	// I communicate with the actual Pusher API.
	function _postEvent(
		String channel,
		String eventType,
		Any message,
		String socketID = ""
		){

		// Serialize the message for transport.
		var serializedMessage = serializeJSON( message );

		// Build the resource URI.
		var resourceUri = "/apps/#variables.appID#/channels/#channel#/events";

		// Get the current the epoch time in seconds (API requires seconds, not milliseconds).
		var epochTimeInSeconds = (getTickCount() / 1000);

		// Get the MD5 hash of the body.
		var md5Body = lcase( hash( serializedMessage, "md5" ) );

		// Define the version of the API we are using. As of this writing, version 1.0 is the latest.
		var apiVersion = "1.0";

		// In order post, we have to create a signature of the request. To create the signature,
		var requestParts = [
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
		];

		// Get the auth signature using Hmac-Sha256 hashing.
		var signature = this._hmacSha256(
			variables.appSecret,
			arrayToList( requestParts, "" )
		);

		// Build the HTTP request.
		var httpRequest = new HTTP(
			method = "post",
			url = ("http://api.pusherapp.com" & resourceUri),
			charset = "utf-8"
		);

		httpRequest.addParam(
			type = "url",
			name = "name",
			value = eventType
		);

		httpRequest.addParam(
			type = "url",
			name = "body_md5",
			value = md5Body
		);

		httpRequest.addParam(
			type = "url",
			name = "socket_id",
			value = socketID
		);

		httpRequest.addParam(
			type = "url",
			name = "auth_key",
			value = variables.appKey
		);

		httpRequest.addParam(
			type = "url",
			name = "auth_timestamp",
			value = epochTimeInSeconds
		);

		httpRequest.addParam(
			type = "url",
			name = "auth_signature",
			value = signature
		);

		httpRequest.addParam(
			type = "url",
			name = "auth_version",
			value = apiVersion
		);

		// The message must be passed through as a JSON body.
		httpRequest.addParam(
			type = "header",
			name = "content-type",
			value = "application/json"
		);

		httpRequest.addParam(
			type = "body",
			value = serializedMessage
		);

		// Send the HTTP request and get the result.
		var response = httpRequest
			 .send()
			 .getPrefix()
		;

		// Return the response.
		return( response );

	}


}

</cfscript>