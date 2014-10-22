<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:numishare="https://github.com/ewg118/numishare" version="2.0">
	<xsl:include href="../../functions.xsl"/>

	<xsl:param name="template" select="doc('input:request')/request/parameters/parameter[name='template']/value"/>
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="subtype" select="doc('input:request')/request/parameters/parameter[name='subtype']/value"/>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$template = 'display'">
				<xsl:apply-templates select="descendant::res:sparql" mode="display"/>
			</xsl:when>
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
		<Placemark xmlns="http://earth.google.com/kml/2.0">
			<name>
				<xsl:value-of select="res:binding[@name='title']/res:literal"/>
			</name>
			<description>
				<![CDATA[
          					<dl class='dl-horizontal'><dt>URL</dt><dd><a href="]]><xsl:value-of select="res:binding[@name='findspot']/res:uri"/><![CDATA[" target="_blank">]]><xsl:value-of
					select="res:binding[@name='title']/res:literal"/><![CDATA[</a></dd>]]>
				<xsl:if test="number($closing_date) castable as xs:integer">
					<![CDATA[<dt>]]><xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/><![CDATA[</dt><dd>]]><xsl:value-of select="number($closing_date)"/><![CDATA[</dd>]]>
				</xsl:if>
				<![CDATA[</dl>
        				]]>
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
		<xsl:variable name="title">
			<xsl:value-of select="res:binding[@name='title']/res:literal"/>
		</xsl:variable>
		<xsl:variable name="description">
			<![CDATA[<dl class='dl-horizontal'><dt>URL</dt><dd><a href=']]><xsl:value-of select="res:binding[@name='object']/res:uri"/><![CDATA['>]]><xsl:value-of
				select="res:binding[@name='object']/res:uri"/><![CDATA[</a></dd>]]>
			<xsl:if test="string($closing_date)">
				<![CDATA[<dt>]]><xsl:value-of select="numishare:regularize_node('closing_date', $lang)"/><![CDATA[</dt><dd>]]><xsl:value-of select="numishare:normalizeYear(number($closing_date))"
				/><![CDATA[</dd>]]>
			</xsl:if>
			<![CDATA[</dl>]]>
		</xsl:variable>
		<xsl:variable name="theme">red</xsl:variable>
		<!-- output --> { <xsl:if test="string($lat) and string($long)">"point": {"lon": <xsl:value-of select="$long"/>, "lat": <xsl:value-of select="$lat"/>},</xsl:if> "title": "<xsl:value-of
			select="$title"/>", "start": "<xsl:value-of select="$closing_date"/>", "options": { "theme": "<xsl:value-of select="$theme"/>", "description": "<xsl:value-of
			select="normalize-space($description)"/>" } }<xsl:if test="not(position()=last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>


	<!-- **************** DISPLAY TEMPLATES ****************-->
	<xsl:template match="res:sparql" mode="display">
		<xsl:variable name="count" select="count(descendant::res:result)"/>

		<div class="row">
			<xsl:if test="not($subtype='true')">
				<xsl:attribute name="id">examples</xsl:attribute>
			</xsl:if>
			<xsl:if test="$count &gt; 0">
				<div class="col-md-12">
					<xsl:element name="{if($subtype='true') then 'h4' else 'h3'}">
						<xsl:value-of select="numishare:normalizeLabel('display_examples', $lang)"/>
					</xsl:element>
				</div>
				<xsl:apply-templates select="descendant::res:result" mode="display"/>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="res:result" mode="display">
		<div class="g_doc col-md-4">
			<span class="result_link">
				<a href="{res:binding[@name='object']/res:uri}" target="_blank">
					<xsl:value-of select="res:binding[@name='title']/res:literal"/>
				</a>
			</span>
			<dl class="dl-horizontal">
				<xsl:if test="res:binding[@name='collection']/res:literal">
					<dt>
						<xsl:value-of select="numishare:regularize_node('collection', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="res:binding[@name='collection']/res:literal"/>
					</dd>
				</xsl:if>
				<xsl:if test="string(res:binding[@name='axis']/res:literal)">
					<dt>
						<xsl:value-of select="numishare:regularize_node('axis', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="string(res:binding[@name='axis']/res:literal)"/>
					</dd>
				</xsl:if>
				<xsl:if test="string(res:binding[@name='diameter']/res:literal)">
					<dt>
						<xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="string(res:binding[@name='diameter']/res:literal)"/>
					</dd>
				</xsl:if>
				<xsl:if test="string(res:binding[@name='weight']/res:literal)">
					<dt>
						<xsl:value-of select="numishare:regularize_node('weight', $lang)"/>
					</dt>
					<dd>
						<xsl:value-of select="string(res:binding[@name='weight']/res:literal)"/>
					</dd>
				</xsl:if>
			</dl>
			<div class="gi_c">
				<xsl:choose>
					<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and string(res:binding[@name='obvThumb']/res:uri)">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}" title="Obverse of {res:binding[@name='identifier']/res:literal}:
							{res:binding[@name='collection']/res:literal}" id="{res:binding[@name='object']/res:uri}">
							<img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>
						</a>
					</xsl:when>
					<xsl:when test="not(string(res:binding[@name='obvRef']/res:uri)) and string(res:binding[@name='obvThumb']/res:uri)">
						<img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>
					</xsl:when>
					<xsl:when test="string(res:binding[@name='obvRef']/res:uri) and not(string(res:binding[@name='obvThumb']/res:uri))">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='obvRef']/res:uri}" title="Obverse of {res:binding[@name='identifier']/res:literal}:
							{res:binding[@name='collection']/res:literal}" id="{res:binding[@name='object']/res:uri}">
							<img class="gi" src="{res:binding[@name='obvRef']/res:uri}" style="max-width:120px"/>
						</a>
					</xsl:when>
				</xsl:choose>
				<!-- reverse-->
				<xsl:choose>
					<xsl:when test="string(res:binding[@name='revRef']/res:uri) and string(res:binding[@name='revThumb']/res:uri)">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}" title="Reverse of {res:binding[@name='identifier']/res:literal}:
							{res:binding[@name='collection']/res:literal}" id="{res:binding[@name='object']/res:uri}">
							<img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
						</a>
					</xsl:when>
					<xsl:when test="not(string(res:binding[@name='revRef']/res:uri)) and string(res:binding[@name='revThumb']/res:uri)">
						<img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
					</xsl:when>
					<xsl:when test="string(res:binding[@name='revRef']/res:uri) and not(string(res:binding[@name='revThumb']/res:uri))">
						<a class="thumbImage" rel="gallery" href="{res:binding[@name='revRef']/res:uri}" title="Reverse of {res:binding[@name='identifier']/res:literal}:
							{res:binding[@name='collection']/res:literal}" id="{res:binding[@name='object']/res:uri}">
							<img class="gi" src="{res:binding[@name='revRef']/res:uri}" style="max-width:120px"/>
						</a>
					</xsl:when>
				</xsl:choose>
				<!-- combined -->
				<xsl:if test="string(res:binding[@name='comRef']/res:uri) and not(string(res:binding[@name='comThumb']/res:uri))">
					<a class="thumbImage" rel="gallery" href="{res:binding[@name='comRef']/res:uri}" title="Image of {res:binding[@name='identifier']/res:literal}:
						{res:binding[@name='collection']/res:literal}" id="{res:binding[@name='object']/res:uri}">
						<img class="gi" src="{res:binding[@name='comRef']/res:uri}" style="max-width:240px"/>
					</a>
				</xsl:if>
			</div>
		</div>
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
