<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:numishare="https://github.com/ewg118/numishare" version="2.0">
	<xsl:include href="../../functions.xsl"/>

	<xsl:param name="template" select="doc('input:request')/request/parameters/parameter[name='template']/value"/>
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
	<xsl:param name="subtype" select="doc('input:request')/request/parameters/parameter[name='subtype']/value"/>

	<xsl:template match="/">
		<xsl:choose>			
			<xsl:when test="$template = 'kml'">
				<xsl:apply-templates select="descendant::res:sparql" mode="kml"/>
			</xsl:when>
			<xsl:when test="$template = 'json'">
				<xsl:apply-templates select="descendant::res:sparql" mode="json"/>
			</xsl:when>
			<xsl:when test="$template = 'solr'">
				<xsl:copy-of select="descendant::res:sparql"/>
			</xsl:when>
			<xsl:when test="$template = 'avgMeasurement'">
				<response>
					<xsl:value-of select="format-number(number(/content/response), '#.00')"/>
				</response>
			</xsl:when>
			<xsl:when test="$template = 'facets'">
				<xsl:apply-templates select="descendant::res:sparql" mode="facets"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- **************** KML TEMPLATES ****************-->
	<xsl:template match="res:sparql" mode="kml">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				<xsl:apply-templates select="descendant::res:result" mode="kml"/>
			</Document>
		</kml>
	</xsl:template>

	<xsl:template match="res:result" mode="kml">
		<xsl:variable name="closing_date" select="res:binding[@name='burial']/res:literal"/>
		<xsl:variable name="description">
			<![CDATA[
          					<dl class='dl-horizontal'><dt>URL</dt><dd><a href="]]><xsl:value-of select="res:binding[@name='object']/res:uri"/><![CDATA[">]]><xsl:value-of
				select="res:binding[@name='title']/res:literal"/><![CDATA[</a></dd>]]>
			<xsl:if test="res:binding[@name='hoard']/res:uri">
				<![CDATA[<dt>Hoard</dt><dd><a href="]]><xsl:value-of select="res:binding[@name='hoard']/res:uri"/><![CDATA[">]]><xsl:value-of select="res:binding[@name='hoardLabel']/res:literal"
				/><![CDATA[</a></dd>]]>
			</xsl:if>
			<xsl:if test="res:binding[@name='findspot']/res:uri">
				<![CDATA[<dt>Findspot</dt><dd><a href="]]><xsl:value-of select="res:binding[@name='findspot']/res:uri"/><![CDATA[">]]>
				<xsl:choose>
					<xsl:when test="res:binding[@name='placeName']/res:literal">
						<xsl:value-of select="res:binding[@name='placeName']/res:literal"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="res:binding[@name='findspot']/res:uri"/>
					</xsl:otherwise>
				</xsl:choose><![CDATA[</a></dd>]]>
			</xsl:if>
			<xsl:if test="number($closing_date) castable as xs:integer">
				<![CDATA[<dt>]]><xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/><![CDATA[</dt><dd>]]><xsl:value-of select="number($closing_date)"/><![CDATA[</dd>]]>
			</xsl:if>
			<![CDATA[</dl>]]>
		</xsl:variable>

		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:value-of select="res:binding[@name='title']/res:literal"/>
			</name>
			<description>
				<xsl:value-of select="normalize-space($description)"/>
			</description>

			<styleUrl>#mapped</styleUrl>
			<!-- add placemark -->
			<Point>
				<coordinates>
					<xsl:value-of select="concat(res:binding[@name='long']/res:literal, ',', res:binding[@name='lat']/res:literal)"/>
				</coordinates>
			</Point>
			<!-- add timespan -->
			<xsl:if test="string($closing_date)">
				<TimeStamp>
					<when>
						<xsl:value-of select="number($closing_date)"/>
					</when>
				</TimeStamp>
			</xsl:if>
		</Placemark>
	</xsl:template>

	<!-- **************** TIMEMAP-JSON TEMPLATES ****************-->
	<xsl:template match="res:sparql" mode="json">
		<response>
			<xsl:if test="count(descendant::res:result/res:binding[@name='findspot']) &gt; 0">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:apply-templates select="descendant::res:result" mode="json"/>
		</response>
	</xsl:template>

	<xsl:template match="res:result" mode="json">
		<xsl:variable name="closing_date" select="res:binding[@name='burial']/res:literal"/>
		<xsl:variable name="lat" select="res:binding[@name='lat']/res:literal"/>
		<xsl:variable name="long" select="res:binding[@name='long']/res:literal"/>
		<xsl:variable name="description">
			<![CDATA[
          					<ul><li><b>URL: </b><a href=']]><xsl:value-of select="res:binding[@name='object']/res:uri"/><![CDATA['>]]><xsl:value-of select="res:binding[@name='title']/res:literal"/><![CDATA[</a></li>]]>
			<xsl:if test="res:binding[@name='hoard']/res:uri">
				<![CDATA[<li><b>Hoard: </b><a href=']]><xsl:value-of select="res:binding[@name='hoard']/res:uri"/><![CDATA['>]]><xsl:value-of select="res:binding[@name='hoardLabel']/res:literal"
				/><![CDATA[</a></li>]]>
			</xsl:if>
			<xsl:if test="res:binding[@name='findspot']/res:uri">
				<![CDATA[<li><b>Findspot: </b><a href=']]><xsl:value-of select="res:binding[@name='findspot']/res:uri"/><![CDATA['>]]>
				<xsl:choose>
					<xsl:when test="res:binding[@name='placeName']/res:literal">
						<xsl:value-of select="res:binding[@name='placeName']/res:literal"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="res:binding[@name='findspot']/res:uri"/>
					</xsl:otherwise>
				</xsl:choose><![CDATA[</a></li>]]>
			</xsl:if>
			<xsl:if test="number($closing_date) castable as xs:integer">
				<![CDATA[<li><b>]]><xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/><![CDATA[: </b>]]><xsl:value-of select="number($closing_date)"/><![CDATA[</li>]]>
			</xsl:if>
			<![CDATA[</ul>]]>
		</xsl:variable>
		<xsl:variable name="theme">red</xsl:variable>
		<!-- output --> { <xsl:if test="string($lat) and string($long)">"point": {"lon": <xsl:value-of select="$long"/>, "lat": <xsl:value-of select="$lat"/>},</xsl:if> "title": "<xsl:value-of
			select="res:binding[@name='title']/res:literal"/>", "start": "<xsl:value-of select="$closing_date"/>", "options": { "theme": "<xsl:value-of select="$theme"/>", "description":
			"<xsl:value-of select="normalize-space($description)"/>" } }<xsl:if test="not(position()=last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- **************** SPARQL FACETS FOR VISUALIZATION ****************-->
	<xsl:template match="res:sparql" mode="facets">
		<html>
			<head>
				<title/>
			</head>
			<body>
				<select class="search_text form-control">
					<option value="">Select option from list...</option>
					<xsl:for-each select="descendant::res:result">
						<option value="{res:binding[@name='val']/res:uri}" class="term">
							<xsl:value-of select="res:binding[@name='label']/res:literal"/>
						</option>
					</xsl:for-each>
				</select>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
