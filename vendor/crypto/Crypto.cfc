<cfcomponent 
	output="false"
	hint="I provide easy access to Java's HMAC security / crypto methods.">


	<cffunction 
		name="init"
		access="public"
		returntype="any"
		output="false"
		hint="I return an initialized component.">

		<!--- Store the MAC class definition so that its static methods can be accessed quickly. --->
		<cfset variables.macClass = createObject( "java", "javax.crypto.Mac" ) />

		<!--- Return this object reference. --->
		<cfreturn this />

	</cffunction>


	<!---
	// PUBLIC METHODS 
	--->


	<cffunction 
		name="hmacMd5"
		access="public"
		returntype="any"
		output="false"
		hint="I hash the given input using the MD5 encoding algorithm and the given secret key. By default, the hash is returned as a HEX-encoded string.">
	
		<!--- Define arguments. --->
		<cfargument 
			name="key"
			type="string"
			required="true"
			hint="I am the secret key used to create the hash."
			/>

		<cfargument 
			name="input"
			type="string"
			required="true"
			hint="I am the value being hashed."
			/>

		<cfargument 
			name="encoding"
			type="string"
			required="false"
			default="hex"
			hint="I am the encoding of the resultant hash - hex, base64, or binary."
			/>

		<!--- Hash the input using Hmac MD5. --->
		<cfset var authenticationCode = this._hashInputWithAlgorithmAndKey( "HmacMD5", key, input ) />

		<!--- Return the authentication code in the appropriate encoding. --->
		<cfreturn
			this._encodeByteArray( authenticationCode, encoding )
			/> 

	</cffunction>


	<cffunction 
		name="hmacSha1"
		access="public"
		returntype="any"
		output="false"
		hint="I hash the given input using the Sha-1 encoding algorithm and the given secret key. By default, the hash is returned as a HEX-encoded string.">
	
		<!--- Define arguments. --->
		<cfargument 
			name="key"
			type="string"
			required="true"
			hint="I am the secret key used to create the hash."
			/>

		<cfargument 
			name="input"
			type="string"
			required="true"
			hint="I am the value being hashed."
			/>

		<cfargument 
			name="encoding"
			type="string"
			required="false"
			default="hex"
			hint="I am the encoding of the resultant hash - hex, base64, or binary."
			/>

		<!--- Hash the input using Hmac Sha-1. --->
		<cfset var authenticationCode = this._hashInputWithAlgorithmAndKey( "HmacSHA1", key, input ) />

		<!--- Return the authentication code in the appropriate encoding. --->
		<cfreturn
			this._encodeByteArray( authenticationCode, encoding )
			/> 

	</cffunction>


	<cffunction 
		name="hmacSha256"
		access="public"
		returntype="any"
		output="false"
		hint="I hash the given input using the Sha-256 encoding algorithm and the given secret key. By default, the hash is returned as a HEX-encoded string.">
	
		<!--- Define arguments. --->
		<cfargument 
			name="key"
			type="string"
			required="true"
			hint="I am the secret key used to create the hash."
			/>

		<cfargument 
			name="input"
			type="string"
			required="true"
			hint="I am the value being hashed."
			/>

		<cfargument 
			name="encoding"
			type="string"
			required="false"
			default="hex"
			hint="I am the encoding of the resultant hash - hex, base64, or binary."
			/>

		<!--- Hash the input using Hmac Sha-1. --->
		<cfset var authenticationCode = this._hashInputWithAlgorithmAndKey( "HmacSHA256", key, input ) />

		<!--- Return the authentication code in the appropriate encoding. --->
		<cfreturn
			this._encodeByteArray( authenticationCode, encoding )
			/> 

	</cffunction>


	<!---
	// PRIVATE METHODS 
	--->


	<cffunction 
		name="_encodeByteArray"
		access="public"
		returntype="any"
		output="false"
		hint="I encode the byte array / binary value using the given encoding. The Hex-encoding is used by default.">
	
		<!--- Define arguments. --->
		<cfargument 
			name="bytes"
			type="any"
			required="true"
			hint="I am binary value / byte array being encoded."
			/>

		<cfargument 
			name="encoding"
			type="string"
			required="false"
			default="hex"
			hint="I am encoding format being used."
			/>


		<!--- Normalize the encoding value. --->
		<cfset encoding = lcase( encoding ) />

		<!--- Checking encoding algorithm. --->
		<cfif (encoding eq "hex")>

			<cfreturn
				lcase( binaryEncode( bytes, "hex" ) )
				/>

		<cfelseif (encoding eq "base64")>

			<cfreturn
				binaryEncode( bytes, "base64" )
				/>

		<cfelseif (encoding eq "binary")>

			<!--- No further encoding required. --->
			<cfreturn bytes />

		</cfif>

		<!--- If we made it this far, the encoding was not recognized or is not yet supported. --->
		<cfthrow
			type="InvalidEncoding"
			message="The requested encoding method [#encoding#] is not yet supported."
			/>

	</cffunction>


	<cffunction 
		name="_getMacInstance"
		access="public"
		returntype="any"
		output="false"
		hint="I get the MAC genreator for the given key and hashing algorithm.">
	
		<!--- Define arguments. --->
		<cfargument 
			name="algorithm"
			type="string"
			required="true"
			hint="I am hashing algorithm being used."
			/>

		<cfargument 
			name="key"
			type="string"
			required="true"
			hint="I am the secret key being uses to create the hash."
			/>

		<!--- Create the specification for our secret key. --->
		<cfset var secretkeySpec = createObject( "java", "javax.crypto.spec.SecretKeySpec" ).init(
			toBinary( toBase64( key ) ),
			javaCast( "string", algorithm )
			) />

		<!--- Get an instance of our MAC generator for the given hashing algorithm. --->
		<cfset var mac = variables.macClass.getInstance(
			javaCast( "string", algorithm )
			) />

		<!--- Initialize the Mac with our secret key spec. --->
		<cfset mac.init( secretkeySpec ) />

		<!--- Return the initialized Mac generator. --->
		<cfreturn mac />

	</cffunction>


	<cffunction 
		name="_hashInputWithAlgorithmAndKey"
		access="public"
		returntype="any"
		output="false"
		hint="I provide a generic method for creating an Hmac with various algorithms. The hash value is returned as a binary value / byte array.">
	
		<!--- Define arguments. --->
		<cfargument 
			name="algorithm"
			type="string"
			required="true"
			hint="I am hashing algorithm being used."
			/>

		<cfargument 
			name="key"
			type="string"
			required="true"
			hint="I am the secret key being uses to create the hash."
			/>

		<cfargument 
			name="input"
			type="string"
			required="true"
			hint="I am the value being hashed."
			/>

		<!--- Create our MAC generator. --->
		<cfset var mac = this._getMacInstance( algorithm, key ) />

		<!--- Hash the input. --->
		<cfset var hashedBytes = mac.doFinal(
			toBinary( toBase64( input ) )
			) />

		<cfreturn hashedBytes />

	</cffunction>


</cfcomponent>