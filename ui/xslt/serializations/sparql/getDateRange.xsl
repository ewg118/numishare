<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: May 2019
	Function: serialize the earliest possible date and the latest possible date from 1 or more SPARQL queries into a simple JSON object -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">

	<xsl:template match="/">
		<xsl:text>{</xsl:text>
		<xsl:text>"earliest":</xsl:text>
		<xsl:value-of select="min(//res:binding[@name = 'earliest'])"/>
		<xsl:text>,"latest":</xsl:text>
		<xsl:value-of select="max(//res:binding[@name = 'latest'])"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

</xsl:stylesheet>
