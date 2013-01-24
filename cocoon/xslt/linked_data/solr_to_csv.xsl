<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="http://code.google.com/p/numishare/" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs exsl numishare" version="2.0" xmlns="http://www.w3.org/2005/Atom" xmlns:exsl="http://exslt.org/common">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="q"/>	
	<xsl:param name="rows" as="xs:integer">100</xsl:param>
	<xsl:param name="start"/>
	<xsl:param name="lang"/>
	<xsl:variable name="start_var" as="xs:integer">
		<xsl:choose>
			<xsl:when test="number($start)">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	
	<xsl:param name="url">
		<xsl:value-of select="/content/config/url"/>
	</xsl:param>
	<!-- list of fields to display in the csv -->
	<xsl:variable name="fields">
		<xsl:text>title_display,identifier_display,authority_facet,century_num,color_display,dob_num,timestamp,degree_facet,deity_facet,denomination_facet,department_facet,dimensions_display,dynasty_facet,era_facet,findspot_facet,imagesponsor_display,issuer_facet,locality_facet,manufacture_facet,material_facet,mint_facet,obv_leg_display,objectType_facet,persname_facet,provenance_display,reference_display,region_facet,rev_leg_display,weight_num,year_num</xsl:text>
	</xsl:variable>
	<xsl:variable name="tokenized_fields" select="tokenize($fields, ',')"/>
	<xsl:variable name="field_count" select="count($tokenized_fields)"/>

	<xsl:template match="/">		
		<!-- display human-readable field names in header row -->
		<xsl:for-each select="$tokenized_fields">
			<xsl:text>"</xsl:text>
			<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
			<xsl:text>"</xsl:text>
			<xsl:text>,</xsl:text>			
		</xsl:for-each>
		<!-- add URL manually -->
		<xsl:text>"URL"</xsl:text>
		<xsl:text>
</xsl:text>
		<xsl:for-each select="descendant::doc">
			<xsl:variable name="doc" select="."/>
			<xsl:for-each select="$tokenized_fields">
				<xsl:variable name="field" select="."/>
				<xsl:text>"</xsl:text>
				<xsl:apply-templates select="exsl:node-set($doc)/*[@name=$field]"/>
				<xsl:text>"</xsl:text>
				<xsl:text>,</xsl:text>				
			</xsl:for-each>
			<xsl:value-of select="concat($url, 'id/', str[@name='id'])"/>						
			<xsl:text>
</xsl:text>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="doc/*">		
		<xsl:choose>
			<xsl:when test="child::node()">
				<xsl:for-each select="distinct-values(child::node())">
					<xsl:value-of select="."/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>			
	</xsl:template>
</xsl:stylesheet>
