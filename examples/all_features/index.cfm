
<cfoutput>

	<!doctype html>
	<html>
	<head>
		<meta charset="utf-8" />

		<title>Pusher.com ColdFusion Feature Demo</title>

		<!-- Include jQuery and Pusher libraries from the CDN. -->
		<script type="text/javascript" src="http://code.jquery.com/jquery-1.8.0.min.js"></script>
		<script type="text/javascript" src="http://js.pusher.com/1.12/pusher.min.js"></script>

	</head>
	<body>

		<h1>
			Pusher.com ColdFusion Feature Demo
		</h1>

		<ol class="pusherLog">
			<!-- To be populated dynamically. -->
		</ol>

		<p>
			<em>Wait a few seconds for test messages from CFThread.</em>
		</p>


		<!-- Run the page scripts. -->
		<script type="text/javascript">


			// Store the pusher App key - we'll need this when we connect.
			var pusherAppKey = "#request.pusherKey#";

			// Create a new instance of the Pusher client. The second
			// argument - the connection options - is an optional set
			// of data that can be passed through with Authentication
			// requests. In this case, we are going to be passing the
			// session-based USERID through so we can validate it 
			// against the current session.
			var pusher = new Pusher(
				pusherAppKey,
				{
					auth: {
						params: {
							"userID": "#session.user.id#"
						}
					}
				}
			);

			// For Private and Presence channel workflows, we need to
			// define a server-side end-point where the Pusher client
			// can get additional authorization. This is accessed from
			// the client-side, not from the Pusher servers.
			Pusher.channel_auth_endpoint = "./channel_auth.cfm"


			// Define a log method for writing events to the HTML.
			var logEvent = function( message ){

				$( "ol.pusherLog" ).append(
					("<li>" + message + "</li>")
				);

			};


			// Liste for state changes on the pusher client.
			pusher.connection.bind(
				"state_change",
				function( states ){

					logEvent( "Connection State: " + states.current );

				}
			);


			// Listen for a connection event.
			pusher.connection.bind( 
				"connected",
				function(){

					logEvent( "Connected with Socket ID " + pusher.connection.socket_id );

				}
			);


			// Let's subscribe to a presence channel - tehse are channels
			// prefixed with the term, "presence-". There is no need to
			// wait for Pusher to finish connecting to the server - we
			// can subscribe at any time.
			var presenceChannel = pusher.subscribe( "presence-demo-channel" );

			// Listen for 
			presenceChannel.bind(
				"pusher:subscription_succeeded",
				function( members ){

					logEvent( "Presence Channel Subscribed: " + members.count + " members." );

					// Output the member info on the channel.
					members.each(
						function( member ){

							logEvent( "--- [" + member.id + "] " + member.info.name );

						}
					);

				}
			);

			// Listen for events on the channel.
			presenceChannel.bind(
				"pusher:member_added",
				function( member ){

					logEvent( "I sense a new presence: " + member.name );

				}
			);


			// Let's subscribe to a prviate channel - these are channels
			// prefixed with the term, "private-". There is no need to
			// wait for Pusher to finish connecting to the server - we
			// can subscribe at any time.
			var privateChannel = pusher.subscribe( "private-demo-channel" );

			// Listen for events on the channel.
			privateChannel.bind(
				"message",
				function( message ){

					logEvent( "New Private Message: " + message.text );

				}
			);


			// Let's subscribe to a public channel.
			var publicChannel = pusher.subscribe( "app-channel" );

			// Listen for events on the channel.
			publicChannel.bind(
				"message",
				function( message ){

					logEvent( "New Public Message: " + message.text );

				}
			);


		</script>

	</body>
	</html>


	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->
	<cfflush />
	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->


	<!---
		Now, let's create an asynchronous thread and push a message 
		down to the user.
	--->
	<cfthread
		name="pushMessage"
		action="run">

		<!--- Sleep briefly to give Pusher time to connect. --->
		<cfset sleep( 3 * 1000 ) />

		<!--- Create a PRIVATE message. --->
		<cfset message = {} />
		<cfset message[ "text" ] = "Ah, Push it! Push it real good!" />

		<!--- Push the message down the private channel. --->
		<cfset request.pusher.pushToAllSubscribers(
			channel = "private-demo-channel",
			eventType = "message",
			message = message
			) />


		<!--- Create a PUBLIC message. --->
		<cfset message = {} />
		<cfset message[ "text" ] = "Something less secure just happened!" />

		<!--- Push the message down the public channel. --->
		<cfset request.pusher.pushToAllSubscribers(
			channel = "app-channel",
			eventType = "message",
			message = message
			) />

	</cfthread>

</cfoutput>