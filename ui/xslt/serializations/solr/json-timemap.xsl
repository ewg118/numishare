<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:saxon="http://saxon.sf.net/" exclude-result-prefixes="#all" version="3.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- encoding for serializing the description into html to embed into the JSON -->
	<xsl:output name="text" encoding="UTF-8" method="html" indent="no"/>

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

	<!-- config params -->
	<xsl:param name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<xsl:variable name="model" as="element()*">
			<_array>
				<xsl:apply-templates select="descendant::doc"/>
			</_array>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="findspot" select="tokenize(arr[@name = 'findspot_geo']/str[1], '\|')[1]"/>
		<xsl:variable name="uri" select="tokenize(arr[@name = 'findspot_geo']/str[1], '\|')[2]"/>
		<xsl:variable name="coordinates" select="tokenize(arr[@name = 'findspot_geo']/str[1], '\|')[3]"/>

		<xsl:variable name="description" as="element()*">
			<dl class="dl-horizontal">
				<dt>URI</dt>
				<dd>
					<a href="{concat($url, 'id/', str[@name='recordId'])}">
						<xsl:value-of select="concat($url, 'id/', str[@name = 'recordId'])"/>
					</a>
				</dd>
				<dt><xsl:value-of select="numishare:regularize_node('findspot', $lang)"/></dt>
				<dd>
					<xsl:value-of select="$findspot"/>
				</dd>
				<xsl:if test="str[@name = 'closing_date_display']">
					<dt>
						<xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="str[@name = 'closing_date_display']"/>
					</dd>
				</xsl:if>
				<xsl:if test="str[@name = 'deposit_display']">
					<dt><xsl:value-of select="numishare:regularize_node('deposit', $lang)"/></dt>
					<dd>
						<xsl:value-of select="str[@name = 'deposit_display']"/>
					</dd>
				</xsl:if>
			</dl>
		</xsl:variable>

		<_object>
			<point>
				<_object>
					<lon>
						<xsl:value-of select="normalize-space(tokenize($coordinates, ',')[1])"/>
					</lon>
					<lat>
						<xsl:value-of select="normalize-space(tokenize($coordinates, ',')[2])"/>
					</lat>
				</_object>
			</point>
			<title>
				<xsl:value-of select="str[@name = 'title_display']"/>
			</title>
			<xsl:choose>
				<xsl:when test="number(int[@name = 'deposit_minint'])">
					<start datatype="xs:string">
						<xsl:value-of select="int[@name = 'deposit_minint']"/>
					</start>
				</xsl:when>
				<xsl:when test="number(int[@name = 'tpq_num'])">
					<start datatype="xs:string">
						<xsl:value-of select="int[@name = 'tpq_num']"/>
					</start>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="number(int[@name = 'deposit_maxint'])">
					<end datatype="xs:string">
						<xsl:value-of select="int[@name = 'deposit_maxint']"/>
					</end>
				</xsl:when>
				<xsl:when test="number(int[@name = 'taq_num'])">
					<end datatype="xs:string">
						<xsl:value-of select="int[@name = 'taq_num']"/>
					</end>
				</xsl:when>
			</xsl:choose>
			<options>
				<_object>
					<theme>red</theme>
					<href>
						<xsl:value-of select="$uri"/>
					</href>
					<description>
						<xsl:value-of select="saxon:serialize($description, 'text')"/>
					</description>
				</_object>
			</options>
		</_object>



		<!--	{"point": {"lon": <xsl:value-of select="normalize-space(tokenize($coordinates, ',')[1])"/>, "lat": <xsl:value-of select="normalize-space(tokenize($coordinates, ',')[2])"/>},
		"title": "<xsl:value-of select="str[@name='title_display']"/>", <xsl:if test="number(int[@name='tpq_num'])">"start": "<xsl:value-of select="int[@name='tpq_num']"/>",</xsl:if>
		<xsl:if test="number(int[@name='taq_num'])">"end": "<xsl:value-of select="int[@name='taq_num']"/>",</xsl:if> "options": { "theme": "red"<xsl:if
			test="string($description)">, "description": "<xsl:value-of select="normalize-space($description)"/>"</xsl:if><xsl:if test="$uri">, "href": "<xsl:value-of select="$uri"/>"</xsl:if> } }
			<xsl:if test="not(position()=last())"><xsl:text>,</xsl:text></xsl:if>-->
	</xsl:template>
</xsl:stylesheet>
