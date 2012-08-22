
<!---
	I provide the authentication for connecting to both private 
	channels and presence channels. Both channels use the same 
	authentication approach; however, the presence channel requires
	additional return data. 
---> 

<!--- Param the form fields. --->
<cfparam name="form.channel_name" type="string" />
<cfparam name="form.socket_id" type="string" />

<!---
	We are also expecting the userID to come through with all 
	authentication-based requests (due to our connection configuration). 
--->
<cfparam name="form.userID" type="numeric" />


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Check to make sure the given userID matches. --->
<cfif (form.userID neq session.user.id)>

	<!---
		The user is trying to subscribe to a channel that they are 
		not allowed to. 
	--->
	<cfheader
		statuscode="403"
		statustext="Forbidden"
		/>

	<!--- Halt any further processing. --->
	<cfabort />

</cfif>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!---
	Check to see if this is a Private channel or a Presence channel
	authentication request.
--->
<cfif reFind( "^presence-", form.channel_name )>

	<!--- Presence channel. --->

	<!---
		When authenticating a presence channel subscription, we need
		to pass along additional user-data to Pusher. The "user_id" 
		value is required. The "user_info" value is optional and may 
		contain any additional data you want to pass to the channel. 
		All of these values will be published to the presence channel
		for clients to consume.
	--->
	<cfset channelData = {} />
	<cfset channelData[ "user_id" ] = session.user.id />
	<cfset channelData[ "user_info" ] = {} />
	<cfset channelData.user_info[ "name" ] = session.user.name />

	<cfset authentication = request.pusher.getPresenceChannelAuthentication(
		form.socket_id,
		form.channel_name,
		channelData
		) />

<cfelse>

	<!--- Private channel. --->

	<cfset authentication = request.pusher.getPrivateChannelAuthentication( 
		form.socket_id,
		form.channel_name 
		) />

</cfif>


<!--- The authentication response is expected in JSON format. --->
<cfset serializedResponse = serializeJSON( authentication ) />

<!--- Stream respones back to the client. --->
<cfcontent
	type="application/json"
	variable="#toBinary( toBase64( serializedResponse ) )#"
	/>
	