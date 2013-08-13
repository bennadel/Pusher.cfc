
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
	authentication-based requests (due to our connection configuration
	in the JavaScript).
--->
<cfparam name="form.userID" type="string" />


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!---
	For this demo, we don't really have any true security. So, I'm
	simply going to validate that the userID is a valid UUID. 
--->
<cfif ! isValid( "uuid", form.userID )>
	
	<!--- Do not allow the chellen subscription. --->
	<cfheader
		statuscode="403"
		statustext="Forbidden"
		/>

	<!--- Halt any further processing. --->
	<cfabort />

</cfif>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- For this demo, we only care about private channels. --->
<cfif reFind( "^private-", form.channel_name )>

	<cfset authentication = request.pusher.getPrivateChannelAuthentication( 
		form.socket_id,
		form.channel_name 
		) />

<cfelse>

	<cfthrow type="PresenseNotSupported" />

</cfif>


<!--- The authentication response is expected in JSON format. --->
<cfset serializedResponse = serializeJSON( authentication ) />

<!--- Stream respones back to the client. --->
<cfcontent
	type="application/json"
	variable="#charsetDecode( serializedResponse, 'utf-8' )#"
	/>
	