<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all">
	<xsl:include href="html-templates.xsl"/>
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path" select="concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<!-- request params -->
	<xsl:param name="pipeline">results</xsl:param>
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="sort" select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
	<xsl:param name="rows">20</xsl:param>
	<xsl:param name="start" select="doc('input:request')/request/parameters/parameter[name='start']/value"/>
	<xsl:variable name="request-uri" select="concat('http://localhost:8080', substring-before(doc('input:request')/request/request-uri, 'results'))"/>

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
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<!-- get block of images from SPARQL endpoint, via nomisma API -->
	<xsl:variable name="sparqlResult" as="element()*">
		<xsl:if test="string($sparql_endpoint) and //config/collection_type='cointype'">
			<xsl:variable name="service" select="concat('http://nomisma.org/apis/numishareResults?identifiers=', encode-for-uri(string-join(descendant::str[@name='recordId'], '|')), '&amp;baseUri=',
				encode-for-uri(/content/config/uri_space))"/>
			<xsl:copy-of select="document($service)/response"/>
		</xsl:if>
	</xsl:variable>

	<xsl:template match="/">
		<html>
			<head profile="http://a9.com/-/spec/opensearch/1.1/">
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: Browse Collection</xsl:text>
				</title>
				<!-- alternates -->
				<link rel="alternate" type="application/atom+xml" href="{concat(//config/url, 'feed/?q=', $q)}"/>
				<link rel="alternate" type="text/csv" href="{concat(//config/url, 'query.csv/?q=', $q, if (string($sort)) then concat('&amp;sort=', $sort) else '', if(string($lang)) then
					concat('&amp;lang=', $lang) else '')}"/>
				<xsl:choose>
					<xsl:when test="/content/config/collection_type = 'hoard'">
						<link rel="alternate" type="application/vnd.google-earth.kml+xml" href="{concat(//config/url, 'findspots.kml/?q=', $q, if(string($lang)) then concat('&amp;lang=', $lang) else
							'')}"/>
					</xsl:when>
					<xsl:otherwise>
						<link rel="alternate" type="application/vnd.google-earth.kml+xml" href="{concat(//config/url, 'query.kml/?q=', $q, if(string($lang)) then concat('&amp;lang=', $lang) else '')}"
						/>
					</xsl:otherwise>
				</xsl:choose>
				<!-- opensearch compliance -->
				<link rel="search" type="application/opensearchdescription+xml" href="{$url}opensearch.xml" title="Example Search for {$url}"/>
				<meta name="totalResults" content="{$numFound}"/>
				<meta name="startIndex" content="{$start_var}"/>
				<meta name="itemsPerPage" content="{$rows}"/>

				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>

				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script type="text/javascript" src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
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
				<xsl:if test="//lst[contains(@name, '_geo')]/int[@name='numFacetTerms'] &gt; 0">
					<script src="http://openlayers.org/api/2.12/OpenLayers.js" type="text/javascript"/>
					<script src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
					<script type="text/javascript" src="{$include_path}/javascript/result_map_functions.js"/>
				</xsl:if>
				<xsl:if test="string(//config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="results"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="results">
		<!--<xsl:copy-of select="$sparqlResult"/>-->
		<div class="container-fluid">
			<div class="row">				
				<div class="col-md-9 col-md-push-3">
					<div class="container-fluid">
						<xsl:call-template name="remove_facets"/>
						<xsl:choose>
							<xsl:when test="$numFound &gt; 0">
								<!-- include resultMap div when there are geographical results-->
								<xsl:if test="//lst[@name='mint_geo']/int[@name='numFacetTerms'] &gt; 0">
									<div style="display:none">
										<div id="resultMap"/>
									</div>
								</xsl:if>
								<xsl:call-template name="paging"/>
								<xsl:call-template name="sort"/>
								<xsl:apply-templates select="descendant::doc"/>
								<xsl:call-template name="paging"/>
							</xsl:when>
							<xsl:otherwise>
								<h2> No results found. <a href="results?q=*:*">Start over.</a></h2>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
				<div class="col-md-3 col-md-pull-9">
					<xsl:if test="//result[@name='response']/@numFound &gt; 0">
						<div class="data_options">
							<h3>
								<xsl:value-of select="numishare:normalizeLabel('results_data-options', $lang)"/>
							</h3>
							<a href="{$display_path}feed/?q={$q}{if(string($lang)) then concat('&amp;lang=', $lang) else ''}">
								<img src="{$include_path}/images/atom-medium.png" title="Atom" alt="Atom"/>
							</a>
							<xsl:if test="//lst[@name='mint_geo']/int[@name='numFacetTerms'] &gt; 0">
								<xsl:choose>
									<xsl:when test="/content/config/collection_type = 'hoard'">
										<a href="{$display_path}findspots.kml?q={$q}{if(string($lang)) then concat('&amp;lang=', $lang) else ''}">
											<img src="{$include_path}/images/googleearth.png" alt="KML" title="KML: Limit, 500 objects"/>
										</a>
									</xsl:when>
									<xsl:otherwise>
										<a href="{$display_path}query.kml?q={$q}{if(string($lang)) then concat('&amp;lang=', $lang) else ''}">
											<img src="{$include_path}/images/googleearth.png" alt="KML" title="KML: Limit, 500 objects"/>
										</a>
									</xsl:otherwise>
								</xsl:choose>
								
							</xsl:if>
							<a href="{$display_path}query.csv?q={$q}{if(string($lang)) then concat('&amp;lang=', $lang) else ''}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
								<!-- the image below is copyright of Silvestre Herrera, available freely on wikimedia commons: http://commons.wikimedia.org/wiki/File:X-office-spreadsheet_Gion.svg -->
								<img src="{$include_path}/images/spreadsheet.png" title="CSV" alt="CSV"/>
							</a>
							<a href="{$display_path}visualize?compare={$q}{if(string($lang)) then concat('&amp;lang=', $lang) else ''}">
								<!-- the image below is copyright of Mark James, available freely on wikimedia commons: http://commons.wikimedia.org/wiki/File:Chart_bar.png -->
								<img src="{$include_path}/images/visualize.png" title="Visualize" alt="Visualize"/>
							</a>
						</div>
						<div id="refine_results">							
							<xsl:call-template name="quick_search"/>
							<h3>
								<xsl:value-of select="numishare:normalizeLabel('results_refine-results', $lang)"/>
							</h3>
							<xsl:apply-templates select="descendant::lst[@name='facet_fields']"/>
						</div>
						
						
					</xsl:if>
				</div>
			</div>
			<div id="backgroundPopup"/>
			<div style="display:none">
				<span id="collection_type">
					<xsl:value-of select="$collection_type"/>
				</span>
				<span id="current-query">
					<xsl:value-of select="$q"/>
				</span>
				<span id="baselayers">
					<xsl:value-of select="string-join(//config/baselayers/layer[@enabled=true()], ',')"/>
				</span>
				<div id="ajax-temp"/>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
