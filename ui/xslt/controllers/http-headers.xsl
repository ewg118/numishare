<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date Modified: August 2020
	Function: Construct HTTP headers for content negotiation
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name = 'lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[. = 'accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[. = 'accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>
	
	<xsl:template match="/">
		<config>
			<status-code>200</status-code>
			<content-type>text/html</content-type>
			
			<!-- output language, if enabled. otherwise the default is 'en' -->
			<header>
				<name>Content-Language</name>
				<value>
					<xsl:value-of select="if (/config/languages/language[@code = $lang]) then $lang else 'en'"/>
				</value>
			</header>						
		</config>
	</xsl:template>

</xsl:stylesheet>
