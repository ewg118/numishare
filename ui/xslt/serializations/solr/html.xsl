<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
	xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all">
	<xsl:include href="html-templates.xsl"/>
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="../../ajax/numishareResults.xsl"/>

	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path" select="if (string(//config/theme/themes_url)) then concat(//config/theme/themes_url, //config/theme/orbeon_theme) else concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
	<!-- request params -->
	<xsl:param name="pipeline">results</xsl:param>
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
	
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="sort" select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
	<xsl:param name="rows">20</xsl:param>
	<xsl:param name="start" select="doc('input:request')/request/parameters/parameter[name='start']/value"/>
	<xsl:param name="layout" select="doc('input:request')/request/parameters/parameter[name='layout']/value"/>
	<xsl:variable name="request-uri" select="concat('http://localhost:', if (//config/server-port castable as xs:integer) then //config/server-port else '8080', substring-before(doc('input:request')/request/request-uri, 'results'))"/>
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
	<xsl:variable name="role" select="/content/collections/collection[@name=$collection-name]/@role"/>
	<xsl:variable name="authenticated" select="if (doc('input:auth')/request-security/role=$role or doc('input:auth')/request-security/role='numishare-admin') then true() else false()" as="xs:boolean"/>

	<!-- blank params -->
	<xsl:param name="mode"/>
	<xsl:param name="image"/>
	<xsl:param name="side"/>

	<!-- query variables derived from request params -->
	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>
	<xsl:variable name="start_var" as="xs:integer">
		<xsl:choose>
			<xsl:when test="number($start)">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>

	<!-- config variables -->
	<xsl:variable name="collection_type" select="/content/config/collection_type"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="positions" as="node()*">
		<config>
			<xsl:copy-of select="/content/config/positions"/>
		</config>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<xsl:if test="string($lang)">
				<xsl:attribute name="lang" select="$lang"/>
			</xsl:if>
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="class">rtl</xsl:attribute>
			</xsl:if>
			<head profile="http://a9.com/-/spec/opensearch/1.1/">
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: Browse Collection</xsl:text>
				</title>
				<!-- alternates -->
				<link rel="alternate" type="application/atom+xml" href="{concat(//config/url, 'feed/?q=', $q)}"/>
				<link rel="alternate" type="text/csv" href="{concat(//config/url, 'query.csv/?q=', $q, if (string($sort)) then concat('&amp;sort=', $sort) else '', if(string($langParam)) then
					concat('&amp;lang=', $langParam) else '')}"/>
				<xsl:choose>
					<xsl:when test="/content/config/collection_type = 'hoard'">
						<link rel="alternate" type="application/vnd.google-earth.kml+xml" href="{concat(//config/url, 'findspots.kml/?q=', $q, if(string($langParam)) then concat('&amp;lang=', $langParam) else
							'')}"/>
					</xsl:when>
					<xsl:otherwise>
						<link rel="alternate" type="application/vnd.google-earth.kml+xml" href="{concat(//config/url, 'query.kml/?q=', $q, if(string($langParam)) then concat('&amp;lang=', $langParam) else '')}"
						/>
					</xsl:otherwise>
				</xsl:choose>
				<!-- opensearch compliance -->
				<link rel="search" type="application/opensearchdescription+xml" href="{$url}opensearch.xml" title="Example Search for {$url}"/>
				<meta name="totalResults" content="{$numFound}"/>
				<meta name="startIndex" content="{$start_var}"/>
				<meta name="itemsPerPage" content="{$rows}"/>

				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/{if (string(//config/favicon)) then //config/favicon else 'favicon.png'}"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>

				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
				<script type="text/javascript" src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/bootstrap-multiselect.js"/>
				<link rel="stylesheet" href="{$include_path}/css/bootstrap-multiselect.css" type="text/css"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>

				<!-- Add fancyBox -->
				<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
				<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
				<script type="text/javascript" src="{$include_path}/javascript/get_facets.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/facet_functions.js"/>
				<script type="text/javascript" src="{$include_path}/javascript/result_functions.js"/>

				<!-- call mapping information -->
				<xsl:if test="count(//lst[contains(@name, '_geo')]/int) &gt; 0">
					<!-- maps-->
					<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css"/>
					<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.css"/>
					<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.Default.css"/>
					
					<!-- js -->
					<script src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"/>					
					<script type="text/javascript" src="{$include_path}/javascript/leaflet.ajax.min.js"/>
					<script type="text/javascript" src="https://unpkg.com/leaflet.markercluster@1.4.1/dist/leaflet.markercluster.js"/>
					<script type="text/javascript" src="{$include_path}/javascript/result_map_functions.js"/>
				</xsl:if>
				
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
				
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>

				<!-- meta tags-->
				<xsl:for-each select="descendant::str[starts-with(@name, 'reference_')]">
					<meta property="og:image" content="{.}"/>
				</xsl:for-each>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="results"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="results">
		<div class="container-fluid">
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			
			<div class="row">
				<div class="col-md-9 col-md-push-3">
					<xsl:call-template name="remove_facets"/>
					<xsl:choose>
						<xsl:when test="$numFound &gt; 0">
							<!-- include resultMap div when there are geographical results-->
							<xsl:if test="count(//lst[@name='mint_geo']/int) &gt; 0 or count(//lst[@name='findspot_geo']/int) &gt; 0">
								<div style="display:none">
									<div id="resultMap"/>
								</div>
							</xsl:if>
							
							<!-- display link to return to the identify page, if referred from there -->
							<xsl:if test="tokenize(doc('input:request')/request/headers/header[name='referer']/value, '/')[last()] = 'identify'">
								<a href="#" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left"/> Return to previous query on Identify page.</a>
							</xsl:if>	
							
							<xsl:call-template name="paging"/>
							<xsl:call-template name="sort"/>
							
							<!-- use the $layout to choose between grid and default -->
							<xsl:choose>
								<xsl:when test="$layout = 'grid'">
									<div class="row">
										<xsl:apply-templates select="descendant::doc" mode="grid"/>
									</div>										
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="descendant::doc" mode="default"/>										
								</xsl:otherwise>
							</xsl:choose>
							
							<xsl:call-template name="paging"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="tokenize(doc('input:request')/request/headers/header[name='referer']/value, '/')[last()] = 'identify'">
									<h2> No results found. <a href="#" onclick="window.history.back();">Start over.</a></h2>
								</xsl:when>
								<xsl:otherwise>
									<h2> No results found. <a href="results">Start over.</a></h2>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="col-md-3 col-md-pull-9">
					<xsl:if test="//result[@name='response']/@numFound &gt; 0">
						<div class="data_options">
							
							<xsl:variable name="requestParameters" as="node()*">
								<params>
									<xsl:if test="string($q)">
										<param>
											<xsl:text>q=</xsl:text>
											<xsl:value-of select="encode-for-uri($q)"/>
										</param>
									</xsl:if>
									<xsl:if test="string($langParam)">
										<param>
											<xsl:text>lang=</xsl:text>
											<xsl:value-of select="$langParam"/>
										</param>
									</xsl:if>
									<xsl:if test="string($sort)">
										<param>
											<xsl:text>sort=</xsl:text>
											<xsl:value-of select="$sort"/>
										</param>
									</xsl:if>
								</params>								
							</xsl:variable>
							<xsl:variable name="query">
								<xsl:if test="count($requestParameters//param) &gt; 0">
									<xsl:text>?</xsl:text>
								</xsl:if>
								<xsl:value-of select="string-join($requestParameters//param, '&amp;')"/>
							</xsl:variable>
							
							<h3>
								<xsl:value-of select="numishare:normalizeLabel('results_data-options', $lang)"/>
							</h3>
							<a href="{$display_path}feed/{$query}">
								<img src="{$include_path}/images/atom-medium.png" title="Atom" alt="Atom"/>
							</a>
							<xsl:if test="count(//lst[@name='mint_geo']/int) &gt; 0">
								<xsl:choose>
									<xsl:when test="/content/config/collection_type = 'hoard'">
										<a href="{$display_path}findspots.kml{$query}" rel="nofollow">
											<img src="{$include_path}/images/googleearth.png" alt="KML" title="KML: Limit, 500 objects"/>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<a href="{$display_path}query.kml{$query}" rel="nofollow">
											<img src="{$include_path}/images/googleearth.png" alt="KML" title="KML: Limit, 500 objects"/>
										</a>
									</xsl:otherwise>
								</xsl:choose>

							</xsl:if>
							<a href="{$display_path}query.csv{$query}" rel="nofollow">
								<!-- the image below is copyright of Silvestre Herrera, available freely on wikimedia commons: http://commons.wikimedia.org/wiki/File:X-office-spreadsheet_Gion.svg -->
								<img src="{$include_path}/images/spreadsheet.png" title="CSV: Limit, 5000 objects" alt="CSV"/>
							</a>
							<a href="{$display_path}visualize?compare={if (string($q)) then substring-after($query, 'q=') else '*:*'}" rel="nofollow">
								<!-- the image below is copyright of Mark James, available freely on wikimedia commons: http://commons.wikimedia.org/wiki/File:Chart_bar.png -->
								<img src="{$include_path}/images/visualize.png" title="Visualize" alt="Visualize"/>
							</a>
							<xsl:if test="//lst[@name='mint_geo'][count(int) &gt; 0] or //lst[@name='findspot_geo'][count(int) &gt; 0]">
								<div id="geodata">
									<h4><xsl:value-of select="numishare:regularize_node('geographic', $lang)"/></h4>
									<ul>
										<xsl:if test="//lst[@name='mint_geo'][count(int) &gt; 0]">
											<li><b>Mints: </b> <a href="{$display_path}mints.geojson{$query}" rel="nofollow">GeoJSON</a>, <a href="{$display_path}mints.kml{$query}" rel="nofollow">KML</a></li>
										</xsl:if>
										<xsl:if test="//lst[@name='findspot_geo'][count(int) &gt; 0]">
											<li><b>Findspots: </b>  <a href="{$display_path}findspots.geojson{$query}" rel="nofollow">GeoJSON</a>, <a href="{$display_path}findspots.kml{$query}" rel="nofollow">KML</a></li>
										</xsl:if>									
									</ul>
								</div>
							</xsl:if>							
						</div>
						<div id="refine_results">
							<!-- keyword search -->
							<xsl:call-template name="quick_search"/>
							
							<!-- more complex facet form -->
							<h3>
								<xsl:value-of select="numishare:normalizeLabel('results_refine-results', $lang)"/>
							</h3>
							<xsl:apply-templates select="descendant::lst[@name='facet_fields']"/>
						</div>


					</xsl:if>
				</div>
			</div>
			<div id="backgroundPopup"/>
			<div class="hidden">
				<span id="collection_type">
					<xsl:value-of select="$collection_type"/>
				</span>
				<span id="current-query">
					<xsl:value-of select="$q"/>
				</span>
				<span id="baselayers">
					<xsl:value-of select="string-join(//config/baselayers/layer[@enabled=true()], ',')"/>
				</span>
				<span id="path">
					<xsl:value-of select="$display_path"/>
				</span>
				<span id="mapboxKey">
					<xsl:value-of select="//config/mapboxKey"/>
				</span>
				<div id="ajax-temp"/>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
