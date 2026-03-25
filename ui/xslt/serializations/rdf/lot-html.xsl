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
	
	<!-- specimen variables -->
	<xsl:variable name="numFound" select="doc('input:specimens')/response/result[@name = 'response']/@numFound"/>
	<xsl:variable name="hasGeo" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="doc('input:specimens')/descendant::lst[ends-with(@name, 'geo')]/int">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- variables -->
	<xsl:variable name="objectUri" select="//rdf:RDF/*[1]/@rdf:about"/>
	<xsl:variable name="id" select="tokenize($objectUri, '/')[last()]"/>

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
		<title id="{$id}">
			<xsl:value-of select="//config/title"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="descendant::skos:prefLabel[@xml:lang = 'en']"/>
		</title>
		<!-- alternates -->
		<link rel="alternate" type="application/rdf+xml" href="{$objectUri}.rdf"/>
		<link rel="alternate" type="application/ld+json" href="{$objectUri}.jsonld"/>
		<link rel="alternate" type="text/turtle" href="{$objectUri}.ttl"/>

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
			
			<xsl:apply-templates select="//rdf:RDF/la:Set"/>
			
			<xsl:if test="$numFound &gt; 0">
				<div class="row">
					<div class="col-md-12">
						<div id="results"/>
					</div>
				</div>
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<h3>Export</h3>
					<ul class="list-inline">
						<li>
							<strong>Linked Data</strong>
						</li>
						<li>
							<a href="{$id}.rdf">RDF/XML</a>
						</li>
						<li>
							<a href="{$id}.ttl">RDF/TTL</a>
						</li>
						<li>
							<a href="{$id}.jsonld">JSON-LD</a>
						</li>
					</ul>
				</div>
			</div>
			
		</div>

		<!-- hidden variables -->
		<div class="hidden">
			<span id="path">
				<xsl:value-of select="$display_path"/>
			</span>
			<span id="query">
				<xsl:value-of select="concat('recordId:', $id, '.*')"/>
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

	<xsl:template match="la:Set">
		<div class="row" typeof="{name()}" about="{@rdf:about}">
			<div class="col-md-12">
				<h1>Lot <xsl:value-of select="rdfs:label"/></h1>
				<p>
					<strong><xsl:value-of select="numishare:normalizeLabel('display_canonical_uri', $lang)"/>: </strong>
					<code>
						<a href="{$objectUri}" title="{$objectUri}">
							<xsl:value-of select="$objectUri"/>
						</a>
					</code>
				</p>
			</div>
			<div class="col-md-{if ($hasGeo = true()) then '6' else '12'}">
				
				<xsl:apply-templates select="la:members_exemplified_by/crm:E22_Human-Made_Object"/>
				
				<noscript>
					<a href="{$display_path}results?q=recordId:{$id}.*">View objects from this lot.</a>
				</noscript>
			</div>
			
			<xsl:if test="$hasGeo = true()">
				<div class="col-md-6">
					<div id="resultMap"/>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- set description -->
	<xsl:template match="crm:E22_Human-Made_Object">
		<xsl:apply-templates select="crm:P24i_changed_ownership_through/crm:E8_Acquisition"/>

		<xsl:if test="crm:P43_has_dimension">
			<h2>Contents</h2>

			<p class="text-info">
				<strong>Note: </strong> Contents recorded in the accession history may differ than what is publicly available in the collection database. </p>

			<table class="table table-striped table-responsive">
				<thead>
					<tr>
						<th>
							<xsl:value-of select="numishare:normalizeLabel('numeric_count', $lang)"/>
						</th>
						<th>
							<xsl:value-of select="numishare:regularize_node('objectType', $lang)"/>
						</th>
						<th>
							<xsl:value-of select="numishare:regularize_node('department', $lang)"/>
						</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="crm:P43_has_dimension/crm:E54_Dimension"/>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>

	<!-- provenance -->
	<xsl:template match="crm:E8_Acquisition">
		<h2>Acquisition</h2>
		<dl class="{if(//config/languages/language[@code = $lang]/@rtl = true()) then 'dl-horizontal dl-rtl' else 'dl-horizontal'}">

			<xsl:apply-templates select="crm:P2_has_type" mode="acquisition_type"/>

			<xsl:if test="crm:P4_has_time-span">
				<dt>
					<xsl:value-of select="numishare:regularize_node('date', $lang)"/>
				</dt>
				<dd>
					<xsl:value-of select="crm:P4_has_time-span/descendant::rdfs:label"/>
				</dd>
			</xsl:if>

			<xsl:if test="crm:P23_transferred_title_from">
				<dt>Contributor</dt>
				<dd>
					<xsl:apply-templates select="crm:P23_transferred_title_from"/>
				</dd>
			</xsl:if>

			<xsl:if test="crm:P67i_is_referred_to_by">
				<dt>
					<xsl:value-of select="numishare:regularize_node('acknowledgment', $lang)"/>
				</dt>
				<dd>
					<xsl:value-of select="crm:P67i_is_referred_to_by/descendant::crm:P190_has_symbolic_content"/>
				</dd>
			</xsl:if>
		</dl>
	</xsl:template>

	<!-- related entities -->
	<xsl:template match="crm:P23_transferred_title_from">
		<xsl:variable name="uri" select="@rdf:resource"/>

		<xsl:apply-templates select="//rdf:RDF/*[@rdf:about = $uri]"/>
		
		<xsl:if test="not(position() = last())">
			<br/>
		</xsl:if>	
	</xsl:template>

	<xsl:template match="crm:E21_Person | crm:E74_Group">
		<a href="{@rdf:about}" title="{rdfs:label}">
			<xsl:value-of select="rdfs:label"/>
		</a>

		<xsl:if test="la:equivalent">
			<a href="{la:equivalent/@rdf:resource}" target="_blank" class="external_link">
				<span class="glyphicon glyphicon-new-window"/>
			</a>
		</xsl:if>
	</xsl:template>

	<!-- acquisition type -->
	<xsl:template match="crm:P2_has_type" mode="acquisition_type">
		<xsl:variable name="uri" select="@rdf:resource"/>

		<xsl:apply-templates select="//rdf:RDF/crm:E55_Type[@rdf:about = $uri]"/>
	</xsl:template>

	<xsl:template match="crm:E55_Type">
		<dt>Acquisition Type</dt>
		<dd>
			<xsl:value-of select="rdfs:label"/>
			<a href="{@rdf:about}" target="_blank" class="external_link">
				<span class="glyphicon glyphicon-new-window"/>
			</a>
		</dd>
	</xsl:template>

	<!-- contents -->
	<xsl:template match="crm:E54_Dimension">
		<tr>
			<td>
				<xsl:value-of select="crm:P90_has_value"/>
			</td>
			<td>
				<xsl:value-of select="crm:P2_has_type/crm:E55_Type[crm:P2_has_type = 'http://vocab.getty.edu/aat/300435443']/rdfs:label"/>
			</td>
			<td>
				<xsl:value-of select="crm:P2_has_type/crm:E55_Type[crm:P2_has_type = 'http://vocab.getty.edu/aat/300263534']/rdfs:label"/>
			</td>
		</tr>
	</xsl:template>

</xsl:stylesheet>
