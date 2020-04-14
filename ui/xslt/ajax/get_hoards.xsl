<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date modified: April 2020
	Function: Serialize Solr XML response for a query of hoards (for distribution analysis interfaces) into an HTML mutiple select box;
	The box is preloaded with all published hoards on the Hoard Record and Analyze pages, but an AJAX call can update the box -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

	<xsl:param name="compare" select="doc('input:request')/request/parameters/parameter[name = 'compare']/value"/>
	
	<!-- if the resuts are being serialized into the distributation analysis interface on a hoard record page, then ignore the ID of the hoard in the results -->
	<xsl:param name="ignore"
		select="
			if (contains(doc('input:request')/request/request-url, 'id/')) then
				tokenize(doc('input:request')/request/request-url, '/')[last()]
			else
				''"/>

	<xsl:template match="/">
		<select multiple="multiple" size="10" class="compare-select form-control" name="compare" id="get_hoards-control">
			<xsl:apply-templates select="descendant::doc[not(str[@name = 'recordId'] = $ignore)]"/>
		</select>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="id" select="str[@name = 'recordId']"/>
		<option value="{$id}" class="compare-option">
			<!-- if the hoard ID is in a compare request parameter, then select the line -->
			<xsl:if test="boolean(index-of($compare, $id)) = true()">
				<xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:if>

			<xsl:value-of select="str[@name = 'title_display']"/>
		</option>
	</xsl:template>
</xsl:stylesheet>
