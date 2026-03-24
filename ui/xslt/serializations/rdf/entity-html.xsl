<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:void="http://rdfs.org/ns/void#" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:prov="http://www.w3.org/ns/prov#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig/"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:la="https://linked.art/ns/terms/" exclude-result-prefixes="#all" version="2.0">

	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- URL params -->
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
	<xsl:variable name="request-uri" select="
			concat('http://localhost:', if (//config/server-port castable as xs:integer) then
				//config/server-port
			else
				'8080', substring-before(doc('input:request')/request/request-uri, 'lot/'))"/>
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

	<!-- paths -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="string(//config/uri_space)">					
				<xsl:value-of select="if (doc('input:request')/request/scheme = 'https') then replace($url, 'http://', 'https://') else $url"/>
			</xsl:when>
			<xsl:otherwise>../</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="include_path" select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<!-- variables -->
	<xsl:variable name="objectUri" select="concat($url, 'entity/', tokenize(doc('input:request')/request/request-uri, '/')[last()])"/>
	
	<xsl:variable name="numFound">0</xsl:variable>
	<xsl:variable name="hasGeo">false</xsl:variable>

	<!-- namespaces -->
	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<xsl:for-each select="//rdf:RDF/namespace::*[not(name() = 'xml')]">
				<namespace prefix="{name()}" uri="{.}"/>
			</xsl:for-each>
		</namespaces>
	</xsl:variable>
	<xsl:variable name="prefix">
		<xsl:for-each select="$namespaces/namespace">
			<xsl:value-of select="concat(@prefix, ': ', @uri)"/>
			<xsl:if test="not(position() = last())">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:call-template name="contruct_page"/>
	</xsl:template>

	<xsl:template name="contruct_page">
		<html prefix="{$prefix}" itemscope="" itemtype="Thing">
			<xsl:if test="string($lang)">
				<xsl:attribute name="lang" select="$lang"/>
			</xsl:if>
			<head>
				<xsl:call-template name="generic_head"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="generic_head">
		<title>
			<xsl:value-of select="//config/title"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="descendant::skos:prefLabel[@xml:lang = 'en']"/>
		</title>

		<!-- open graph metadata -->
		<meta property="og:url" content="{$objectUri}"/>
		<meta property="og:type" content="article"/>
		<meta property="og:title">
			<xsl:attribute name="content">
				<xsl:value-of select="descendant::la:Set/rdfs:label"/>
			</xsl:attribute>
		</meta>

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
		
		<xsl:if test="$numFound &gt; 0">
			<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
			<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
			
			<!-- network graph functions -->
			<script type="text/javascript" src="{$include_path}/javascript/d3.min.js"/>
			<script type="text/javascript" src="{$include_path}/javascript/d3plus-network.full.min.js"/>
			
			<script type="text/javascript" src="{$include_path}/javascript/lot_functions.js"/>
			
			<xsl:if test="$hasGeo = true()">
				<!-- maps-->
				<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>
				
				<!-- js -->
				<script src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/leaflet.ajax.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/result_map_functions.js"/>
			</xsl:if>
		</xsl:if>
		

		<!-- google analytics -->
		<xsl:call-template name="google_analytics">
			<xsl:with-param name="id" select="//config/google_analytics_tag"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="body">
		<div class="container-fluid content">
			<xsl:apply-templates select="//*[@rdf:about = $objectUri][1]"/>
		</div>

		<!-- hidden variables -->
		<div class="hidden">
			<span id="path">
				<xsl:value-of select="$display_path"/>
			</span>
			<span id="collection_type">lot</span>
			<span id="baselayers">
				<xsl:value-of select="string-join(//config/baselayers/layer[@enabled = true()], ',')"/>
			</span>
			<span id="mapboxKey">
				<xsl:value-of select="//config/mapboxKey"/>
			</span>
			<span id="lang">
				<xsl:value-of select="$lang"/>
			</span>
			<span id="objectURI">
				<xsl:value-of select="$objectUri"/>
			</span>
		</div>
	</xsl:template>

	<xsl:template match="crm:E21_Person | crm:E74_Group">
		<div class="row" typeof="{name()}" about="{@rdf:about}">
			<div class="col-md-12">
				<h1><xsl:value-of select="rdfs:label"/></h1>
				<p>
					<strong><xsl:value-of select="numishare:normalizeLabel('display_canonical_uri', $lang)"/>: </strong>
					<code>
						<a href="{@rdf:about}" title="{@rdf:about}">
							<xsl:value-of select="@rdf:about"/>
						</a>
					</code>
				</p>
				
				<dl class="dl-horizontal">
					<xsl:apply-templates select="la:equivalent"/>
				</dl>
			</div>
			
			<div class="col-md-{if ($hasGeo = true()) then '6' else '12'}">	
				<table class="table table-striped">
					<thead>
						<tr>
							<th>Lot</th>
							<th>Date</th>
						</tr>
					</thead>
					<tbody>
						<xsl:apply-templates select="//la:Set"/>
					</tbody>					
				</table>
				
			</div>
			
			<xsl:if test="$hasGeo = true()">
				<div class="col-md-6">
					<div id="resultMap"/>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="la:equivalent">
		<dt>External URI</dt>
		<dd>
			<a href="{@rdf:resource}">
				<xsl:value-of select="@rdf:resource"/>
			</a>
		</dd>
	</xsl:template>
	
	<!-- display a table row for each object lot -->
	<xsl:template match="la:Set">
		<tr>
			<td>
				<a href="{@rdf:about}" title="{rdfs:label}">
					<xsl:value-of select="rdfs:label"/>
				</a>				
			</td>
			<xsl:apply-templates select="la:members_exemplified_by/crm:E22_Human-Made_Object/crm:P24i_changed_ownership_through/crm:E8_Acquisition"/>
			
		</tr>
	</xsl:template>
	
	<xsl:template match="crm:E8_Acquisition">
		<td>
			<xsl:value-of select="crm:P4_has_time-span/crm:E52_Time-Span/rdfs:label"/>
		</td>
	</xsl:template>

</xsl:stylesheet>
