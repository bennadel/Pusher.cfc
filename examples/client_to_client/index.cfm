<!doctype html>
<html>
<head>
	<meta charset="utf-8" />

	<title>
		Sending Client-To-Client Realtime Messages With Pusher App And ColdFusion
	</title>

	<link rel="stylesheet" type="text/css" href="./styles.css"></link>
</head>
<body>

	<h1>
		Sending Client-To-Client Realtime Messages With Pusher App And ColdFusion
	</h1>

	<p>
		<em>Note</em>: You should see the Mouse cursor for each user viewing this page.
	</p>


	<!-- Load jQuery and Pusher from the CDN. -->
	<script 
		type="text/javascript"
		src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js">
	</script>
	<script 
		type="text/javascript"
		src="//js.pusher.com/2.1/pusher.min.js">
	</script>
	<script type="text/javascript">


		// Define the pusher key here so we can limit our use of 
		// CFOutput within the JavaScript.
		var pusherAppKey = "<cfoutput>#request.pusherKey#</cfoutput>";


		// -------------------------------------------------- //
		// -------------------------------------------------- //


		// Generate a unique ID for each user.
		var currentUserID = "<cfoutput>#createUUID()#</cfoutput>";


		// -------------------------------------------------- //
		// -------------------------------------------------- //


		// Create a new instance of the Pusher client. The second
		// argument - the connection options - is an optional set
		// of data that can be passed through with Authentication
		// requests. In this case, we need to define the authorization
		// end-point since client-events need to be on authorized 
		// channel subscriptions.
		var pusher = new Pusher(
			pusherAppKey,
			{
				authEndpoint: "./channel_auth.cfm",
				auth: {
					params: {
						userID: currentUserID
					}
				}
			}
		);


		// All the users will listen for and announce mouse-move
		// events over this private channel. 
		// --
		// NOTE: client-events need to use an authenciated channel.
		var channel = pusher.subscribe( "private-mouse" );


		// Bind to the move event (other user's publishing).
		// --
		// NOTE: ALl client-events must be transmitted on events that
		// are prefixed with "client-".
		channel.bind(
			"client-moved",
			function( event ) {
				
				applyMouseMove( event.userID, event.x, event.y );

			}
		);


		// Client-events can only be triggered at a maximum of 10 events
		// per second. As such, we'll have to debounce the events that 
		// are triggered by the local user.
		var rateLimitEvent = null;


		// I push the current user's mouse-move event out on the
		// private channel to all the other users. 
		// --
		// NOTE: Client-events do NOT bounce back to the originating
		// user. As such, we can publish events without having to have
		// and logic about who sent what.
		function pushMouseMove( userID, x, y ) {

			if ( rateLimitEvent ) {

				rateLimitEvent.x = x;
				rateLimitEvent.y = y;
				return;

			}

			rateLimitEvent = {
				userID: userID,
				x: x,
				y: y
			};

			// Debounce for 100ms (we can only send a max of 10 events
			// per second ~ every 100ms).
			setTimeout(
				function() {

					channel.trigger( "client-moved", rateLimitEvent );

					rateLimitEvent = null;

				},
				100
			);

		}


		// -------------------------------------------------- //
		// -------------------------------------------------- //


		// Keep a collection of the users we know about.
		var users = [];

		// Start watching the document for mouse movements.
		$( document ).mousemove( handleMouseMove );


		// I apply a mouse move events that has been received over the
		// pusher channel (from another user).
		function applyMouseMove( userID, x, y ) {

			var user = getUserByID( userID );

			// If the user has not yet been defined locally, then 
			// create it and append it to the BODY.
			if ( ! user ) {

				user = createNewUser( userID );

				users.push( user );

				$( "body" ).append( user.mouse );

			}

			// Update the data and location for the user.
			user.mouse.css({
				left: ( ( user.x = x ) + "px" ),
				top: ( ( user.y = y ) + "px" )				
			});

		}


		// I create a user object with the given userID.
		function createNewUser( userID ) {

			var mouse = $( "<div class='mouse'></div>" )
				.append( "<div class='pointer'></div>" )
				.append( "<div class='label'></div>")
			;

			var label = mouse.find( "div.label" );

			// Apply a special label to the current user.
			if ( userID === currentUserID ) {

				label.text( "Me!" );

			} else {

				label.text( userID );
				
				// Also, let's add a CSS class that animates the 
				// transition in CSS position. This way, the local
				// user will update immediately and the external users
				// will update with an animation in alignement with
				// the rate-limiting.
				mouse.addClass( "external" );

			}

			var user = {
				id: userID,
				x: -100,
				y: -100,
				mouse: mouse
			};

			user.mouse.css({
				left: ( user.x + "px" ),
				top: ( user.y + "px" )
			});

			return( user );

		}


		// I get the user object using the given userID. If the user
		// has not yet been recorded locally, null is returned.
		function getUserByID( userID ) {

			for ( var i = 0 ; i < users.length ; i++ ) {

				if ( users[ i ].id === userID ) {

					return( users[ i ] );

				}

			}

			return( null );

		}


		// I handle the local mouse-move event triggered by the current
		// user.
		function handleMouseMove( event ) {

			// Update the local mouse indicator for the current user.
			applyMouseMove( currentUserID, event.pageX, event.pageY );

			// Push the mouse move event to all users.
			pushMouseMove( currentUserID, event.pageX, event.pageY );

		}


	</script>

</body>
</html>