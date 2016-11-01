<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:include href="../../functions.xsl"/>
	
	<!-- url params -->
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[.='accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[.='accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>
	
	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="collection_type" select="/content/config/collection_type"/>
	
	<!-- list of fields to display in the csv -->
	<xsl:variable name="fields">
		<xsl:choose>
			<xsl:when test="$collection_type='hoard'">
				<xsl:text>title_display,recordId,tpq_num,taq_num,coinType_uri,description_display,findspot_display,findspot_uri,reference_facet,timestamp</xsl:text>
			</xsl:when>
			<xsl:when test="$collection_type='cointype'">
				<xsl:text>title_display,recordId,authority_facet,degree_facet,deity_facet,denomination_facet,dynasty_facet,engraver_facet,era_facet,issuer_facet,maker_facet,manufacture_facet,material_facet,mint_facet,obv_leg_display,obv_type_display,objectType_facet,portrait_facet,reference_facet,region_facet,rev_leg_display,rev_type_display,year_num,timestamp</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>title_display,recordId,authority_facet,coinType_uri,dob_num,degree_facet,deity_facet,denomination_facet,department_facet,diameter_num,dynasty_facet,engraver_facet,era_facet,findspot_facet,findspot_uri,issuer_facet,maker_facet,manufacture_facet,material_facet,mint_facet,obv_leg_display,obv_type_display,objectType_facet,portrait_facet,reference_facet,region_facet,rev_leg_display,rev_type_display,weight_num,year_num,timestamp</xsl:text>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:variable>
	<xsl:variable name="tokenized_fields" select="tokenize($fields, ',')"/>
	<xsl:variable name="field_count" select="count($tokenized_fields)"/>

	<xsl:template match="/">
		<!-- display human-readable field names in header row -->
		<!-- add URI manually -->
		<xsl:text>"URI",</xsl:text>
		<xsl:for-each select="$tokenized_fields">
			<xsl:text>"</xsl:text>
			<xsl:value-of select="numishare:normalize_fields(., $lang)"/>
			<xsl:text>"</xsl:text>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:for-each>		
		<xsl:text>&#x0A;</xsl:text>
		
		<!-- each doc -->
		<xsl:for-each select="descendant::doc">
			<xsl:variable name="doc" as="element()*">
				<xsl:copy-of select="."/>
			</xsl:variable>
			<xsl:value-of select="concat('&#x022;', $url, 'id/', str[@name='recordId'], '&#x022;,')"/>
			<xsl:for-each select="$tokenized_fields">
				<xsl:variable name="field" select="."/>
				<xsl:text>"</xsl:text>
				<xsl:apply-templates select="$doc/*[@name=$field]"/>
				<xsl:text>"</xsl:text>
				<xsl:if test="not(position()=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>			
			<xsl:text>&#x0A;</xsl:text>
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
