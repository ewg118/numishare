<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date Modified: August 2020
	Function: Construct an HTML page presenting the user with multiple choices for types or hoards that have been cancelled and split
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:mets="http://www.loc.gov/METS/" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:nm="http://nomisma.org/id/"
	xmlns:gml="http://www.opengis.net/gml" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:nmo="http://nomisma.org/ontology#" xmlns:org="http://www.w3.org/ns/org#"
	xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:nuds="http://nomisma.org/nuds" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<!-- URL params -->
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
	<xsl:variable name="request-uri"
		select="
			concat('http://localhost:', if (//config/server-port castable as xs:integer) then
				//config/server-port
			else
				'8080', substring-before(doc('input:request')/request/request-uri, 'id/'))"/>
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
	
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="collection_type" select="/content/config/collection_type"/>
	
	
	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="string(//config/uri_space) and $recordType = 'physical'">
				<xsl:value-of select="$url"/>
			</xsl:when>
			<xsl:otherwise>../</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
	<xsl:variable name="recordType" select="//nuds:nuds/@recordType"/>
	<xsl:variable name="id" select="normalize-space(//*[local-name() = 'recordId'])"/>
	<xsl:variable name="objectUri"
		select="
			if (/content/config/uri_space) then
				concat(/content/config/uri_space, $id)
			else
				concat($url, 'id/', $id)"/>

	

	<xsl:template match="/">
		<html>
			<head>
				<title id="{$id}">
					<xsl:value-of select="//config/title"/>
					<xsl:text>: Multiple Choices</xsl:text>
				</title>
				
				<xsl:for-each select="descendant::*:otherRecordId[@semantic = 'dcterms:isReplacedBy']">
					<xsl:variable name="uri"
						select="
						if (matches(., 'https?://')) then
						.
						else
						concat($url, 'id/', .)"/>
					<link href="{$uri}" rel="related"/>
				</xsl:for-each>
				
				<!-- CSS -->
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/{if (string(//config/favicon)) then //config/favicon else 'favicon.png'}"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				
				<xsl:for-each select="//config/includes/include">
					<xsl:choose>
						<xsl:when test="@type = 'css'">
							<link type="text/{@type}" rel="stylesheet" href="{@url}"/>
						</xsl:when>
						<xsl:when test="@type = 'javascript'">
							<script type="text/{@type}" src="{@url}"/>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
				
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
				<script type="text/javascript" src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<div class="container-fluid">
					<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
						<xsl:attribute name="style">direction: rtl;</xsl:attribute>
					</xsl:if>
					<div class="row pull-right icons">
						<div class="col-md-12">
							<ul class="list-inline">
								<li>
									<strong>EXPORT:</strong>
								</li>
								<li>
									<a href="{$id}.xml">NUDS/XML</a>
								</li>
								<li>
									<a href="{$id}.rdf">RDF/XML</a>
								</li>
								<li>
									<a href="{$id}.ttl">TTL</a>
								</li>
								<li>
									<a href="{$id}.jsonld">JSON-LD</a>
								</li>
							</ul>
						</div>
					</div>
					<div class="row">
						<div class="col-md-12">
							<h1>300 Multiple Choices</h1>
							<p>This resource has been split and supplanted by the following new URIs:</p>
							<ul>
								<xsl:for-each select="descendant::*:otherRecordId[@semantic = 'dcterms:isReplacedBy']">
									<xsl:variable name="uri"
										select="
										if (matches(., 'https?://')) then
										.
										else
										concat($url, 'id/', .)"/>
									<li>
										<a href="{$uri}">
											<xsl:value-of select="$uri"/>
										</a>
									</li>
								</xsl:for-each>
							</ul>
						</div>
					</div>
				</div>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>
	
</xsl:stylesheet>
