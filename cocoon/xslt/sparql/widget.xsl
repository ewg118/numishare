<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" xmlns:numishare="https://github.com/ewg118/numishare"
	version="2.0">
	<xsl:include href="templates.xsl"/>	
	
	<xsl:param name="template"/>
	<xsl:param name="uri"/>
	<xsl:param name="lang"/>
	<xsl:param name="identifiers"/>
	<xsl:param name="baseUri"/>
	<xsl:param name="constraints"/>
	<xsl:param name="field"/>
	<xsl:param name="measurement"/>
	
	<!-- config variables -->
	<xsl:variable name="endpoint" select="/config/sparql_endpoint"/>
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/config/geonames_api_key"/>
	
	<xsl:template match="/">
		<xsl:choose>
			<!--<xsl:when test="$template = 'results'">
				<xsl:call-template name="numishare:getImages"/>
			</xsl:when>-->
			<xsl:when test="$template = 'display'">
				<xsl:call-template name="numishare:associatedObjects"/>
			</xsl:when>
			<xsl:when test="$template = 'kml'">
				<xsl:call-template name="numishare:getFindspots"/>
			</xsl:when>
			<xsl:when test="$template = 'json'">
				<xsl:call-template name="numishare:getJsonFindspots"/>
			</xsl:when>
			<xsl:when test="$template = 'solr'">
				<xsl:call-template name="numishare:solrFields"/>
			</xsl:when>
			<xsl:when test="$template = 'avgMeasurement'">
				<xsl:call-template name="numishare:avgMeasurement"/>
			</xsl:when>
			<xsl:when test="$template = 'facets'">
				<xsl:call-template name="numishare:facets"/>
			</xsl:when>
			<xsl:when test="$template = 'contributors'">
				<xsl:call-template name="numishare:contributors"/>
			</xsl:when>
		</xsl:choose>
		
	</xsl:template>
	
</xsl:stylesheet>
