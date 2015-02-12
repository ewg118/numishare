<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../templates-visualize.xsl"/>
	<xsl:include href="../../templates-analyze.xsl"/>
	<xsl:include href="../../functions.xsl"/>
	<xsl:include href="html-templates.xsl"/>
	<xsl:include href="../nuds/html.xsl"/>
	<xsl:include href="../nudsHoard/html.xsl"/>

	<!-- URL params -->
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/servlet-path, 'numishare/'), '/')"/>
	<xsl:variable name="request-uri" select="concat('http://localhost:8080', substring-before(doc('input:request')/request/request-uri, 'id/'))"/>
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="mode" select="doc('input:request')/request/parameters/parameter[name='mode']/value"/>
	<xsl:param name="pipeline">display</xsl:param>

	<!-- compare page params -->
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="start" select="doc('input:request')/request/parameters/parameter[name='start']/value"/>
	<xsl:param name="image" select="doc('input:request')/request/parameters/parameter[name='image']/value"/>
	<xsl:param name="side" select="doc('input:request')/request/parameters/parameter[name='side']/value"/>

	<!-- shared visualization/analysis params -->
	<xsl:param name="type" select="doc('input:request')/request/parameters/parameter[name='type']/value"/>
	<xsl:param name="chartType" select="doc('input:request')/request/parameters/parameter[name='chartType']/value"/>

	<!-- config variables -->
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="uri_space" select="/content/config/uri_space"/>
	<xsl:variable name="collection_type" select="/content/config/collection_type"/>
	<!-- get layout -->
	<xsl:variable name="orientation" select="/content/config/theme/layouts/display/nuds/orientation"/>
	<xsl:variable name="image_location" select="/content/config/theme/layouts/display/nuds/image_location"/>

	<!--<xsl:variable name="display_path">
		<xsl:if test="not(string($mode))">
			<xsl:text>../</xsl:text>
		</xsl:if>
	</xsl:variable>-->
	
	<xsl:variable  name="display_path">../search/</xsl:variable>

	<xsl:variable name="include_path" select="concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>

	<xsl:variable name="recordType">
		<xsl:choose>
			<xsl:when test="descendant::nuds:nuds">
				<xsl:value-of select="//nuds:nuds/@recordType"/>
			</xsl:when>
			<xsl:when test="descendant::nh:nudsHoard">hoard</xsl:when>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="id" select="normalize-space(//*[local-name()='recordId'])"/>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:variable name="type_series" as="element()*">
				<list>
					<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/substring-before(@xlink:href, 'id/'))">
						<type_series>
							<xsl:choose>
								<xsl:when test="contains(., 'nomisma')">
									<xsl:value-of select="replace(., 'nomisma\.org', 'numismatics\.org/crro')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</type_series>
					</xsl:for-each>
				</list>
			</xsl:variable>
			<xsl:variable name="type_list" as="element()*">
				<list>
					<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href)]/@xlink:href)">
						<type_series_item>
							<xsl:value-of select="."/>
						</type_series_item>
					</xsl:for-each>
				</list>
			</xsl:variable>

			<xsl:for-each select="$type_series//type_series">
				<xsl:variable name="type_series_uri" select="."/>

				<xsl:variable name="id-param">
					<xsl:for-each select="$type_list//type_series_item[contains(., $type_series_uri)]">
						<xsl:value-of select="substring-after(., 'id/')"/>
						<xsl:if test="not(position()=last())">
							<xsl:text>|</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<xsl:if test="string-length($id-param) &gt; 0">
					<xsl:for-each select="document(concat($type_series_uri, 'apis/getNuds?identifiers=', encode-for-uri($id-param)))//nuds:nuds">
						<object xlink:href="{replace($type_series_uri, 'numismatics\.org/crro', 'nomisma\.org')}id/{nuds:control/nuds:recordId}">
							<xsl:copy-of select="."/>
						</object>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="descendant::nuds:typeDesc[not(string(@xlink:href))]">
				<object>
					<xsl:copy-of select="."/>
				</object>
			</xsl:for-each>
		</nudsGroup>
	</xsl:variable>
	
	<!-- get subtypes -->
	<xsl:variable name="subtypes" as="element()*">
		<xsl:if test="$recordType='conceptual' and //config/collection_type='cointype'">
			<xsl:copy-of select="document(concat($request-uri, 'get_subtypes?identifiers=', $id))/*"/>
		</xsl:if>
	</xsl:variable>
	
	<xsl:variable name="facets" select="string-join(//config//facet, ',')"/>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfa="http://www.w3.org/ns/rdfa#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">
			<xsl:variable name="id-param">
				<xsl:for-each select="distinct-values(descendant::*[not(local-name()='typeDesc') and not(local-name()='reference')][contains(@xlink:href,
					'nomisma.org')]/@xlink:href|$nudsGroup/descendant::*[not(local-name()='object') and not(local-name()='typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
			<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="count(descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy']) = 1 and descendant::*:control/*:maintenanceStatus='cancelledReplaced'">
				<xsl:variable name="uri">
					<xsl:choose>
						<xsl:when test="contains(descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy'][1], 'http://')">
							<xsl:value-of select="descendant::*:otherRecordId[1]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($url, 'id/', descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy'][1])"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<html>
					<head>
						<xsl:call-template name="generic_head"/>
						<meta http-equiv="refresh" content="0;URL={$uri}"/>
					</head>
					<body>
						<xsl:call-template name="header"/>
						<div class="container-fluid">
							<div class="row">
								<div class="col-md-12">
									<h1>301: Moved Permanently</h1>
									<p>This resource has been supplanted by <a href="{$uri}"><xsl:value-of select="$uri"/></a>.</p>
								</div>
							</div>
						</div>
						<xsl:call-template name="footer"/>
					</body>
				</html>
			</xsl:when>
			<xsl:when test="count(descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy']) &gt; 1 and descendant::*:control/*:maintenanceStatus='cancelledSplit'">
				<html>
					<head>
						<xsl:call-template name="generic_head"/>
					</head>
					<body>
						<xsl:call-template name="header"/>
						<div class="container-fluid">
							<div class="row">
								<div class="col-md-12">
									<h1>
										<xsl:value-of select="$id"/>
									</h1>
									<p>This resource has been split and supplanted by the following new URIs:</p>
									<ul>
										<xsl:for-each select="descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy']">
											<xsl:variable name="uri" select="if (contains(., 'http://')) then . else concat($url, 'id/', .)"/>
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
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="contruct_page"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="contruct_page">
		<xsl:choose>
			<!-- regular HTML display mode-->
			<xsl:when test="not(string($mode))">
				<html prefix="geo: http://www.w3.org/2003/01/geo/wgs84_pos# foaf: http://xmlns.com/foaf/0.1/ dcterms: http://purl.org/dc/terms/ xsd: http://www.w3.org/2001/XMLSchema# nm:
					http://nomisma.org/id/ ecrm: http://erlangen-crm.org/current/ rdf: http://www.w3.org/1999/02/22-rdf-syntax-ns# skos: http://www.w3.org/2004/02/skos/core# nmo: http://nomisma.org/ontology#">
					<xsl:if test="string($lang)">
						<xsl:attribute name="lang" select="$lang"/>
					</xsl:if>
					<head>
						<xsl:call-template name="generic_head"/>
						<xsl:choose>
							<xsl:when test="$recordType='physical'">
								<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
								<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
								<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
							</xsl:when>
							<!-- coin-type CSS and JS dependencies -->
							<xsl:when test="$recordType='conceptual'">
								<!-- Add fancyBox -->
								<link rel="stylesheet" href="{$include_path}/css/jquery.fancybox.css?v=2.1.5" type="text/css" media="screen"/>
								<script type="text/javascript" src="{$include_path}/javascript/jquery.fancybox.pack.js?v=2.1.5"/>
								<script type="text/javascript" src="{$include_path}/javascript/highcharts.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/modules/exporting.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/display_functions.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/visualize_functions.js"/>

								<!-- mapping -->
								<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
								<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
								<script type="text/javascript" src="{$include_path}/javascript/mxn.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/timeline-2.3.0.js"/>
								<link type="text/css" href="{$include_path}/css/timeline-2.3.0.css" rel="stylesheet"/>
								<script type="text/javascript" src="{$include_path}/javascript/timemap_full.pack.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/param.js"/>
							</xsl:when>
							<!-- hoard CSS and JS dependencies -->
							<xsl:when test="$recordType='hoard'">
								<script type="text/javascript" src="{$include_path}/javascript/highcharts.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/modules/exporting.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/display_hoard_functions.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/analysis_functions.js"/>

								<!-- mapping -->
								<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
								<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
								<script type="text/javascript" src="{$include_path}/javascript/mxn.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/timeline-2.3.0.js"/>
								<link type="text/css" href="{$include_path}/css/timeline-2.3.0.css" rel="stylesheet"/>
								<script type="text/javascript" src="{$include_path}/javascript/timemap_full.pack.js"/>
								<script type="text/javascript" src="{$include_path}/javascript/param.js"/>
							</xsl:when>
						</xsl:choose>
						<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
					</head>
					<body>
						<xsl:call-template name="header"/>
						<xsl:call-template name="display"/>
						<xsl:call-template name="footer"/>
						<div class="hidden">
							<span id="baselayers">
								<xsl:value-of select="string-join(//config/baselayers/layer[@enabled=true()], ',')"/>
							</span>
							<span id="collection_type">
								<xsl:value-of select="$collection_type"/>
							</span>
							<span id="path">
								<xsl:value-of select="$display_path"/>
							</span>
							<span id="include_path">
								<xsl:value-of select="$include_path"/>
							</span>
							<span id="department">
								<xsl:value-of select="descendant::nuds:department"/>
							</span>
							<span id="pipeline">
								<xsl:value-of select="$pipeline"/>
							</span>
						</div>
					</body>
				</html>
			</xsl:when>
			<xsl:otherwise>
				<!-- only call display template for compare display -->
				<xsl:call-template name="display"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="generic_head">
		<title id="{$id}">
			<xsl:value-of select="//config/title"/>
			<xsl:text>: </xsl:text>
			<xsl:choose>
				<xsl:when test="descendant::*:descMeta/*:title[@xml:lang=$lang]">
					<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang=$lang]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="descendant::*:descMeta/*:title[@xml:lang='en']"/>
				</xsl:otherwise>
			</xsl:choose>
		</title>
		<!-- alternates -->
		<link rel="alternate" type="application/xml" href="{concat($uri_space, $id)}.xml"/>
		<link rel="alternate" type="application/rdf+xml" href="{concat($uri_space, $id)}.rdf"/>
		<link rel="alternate" type="application/ld+json" href="{concat($uri_space, $id)}.jsonld"/>
		<link rel="alternate" type="text/turtle" href="{concat($uri_space, $id)}.ttl"/>
		<link rel="alternate" type="application/vnd.google-earth.kml+xml" href="{concat($uri_space, $id)}.kml"/>
		<!-- CSS -->
		<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
		<meta name="viewport" content="width=device-width, initial-scale=1"/>
		<!-- bootstrap -->
		<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
		<script type="text/javascript" src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
		<xsl:if test="string(//config/google_analytics)">
			<script type="text/javascript">
				<xsl:value-of select="//config/google_analytics"/>
			</script>
		</xsl:if>
	</xsl:template>

	<xsl:template name="display">
		<xsl:choose>
			<xsl:when test="$mode='compare'">
				<xsl:choose>
					<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
						<xsl:call-template name="nuds"/>
					</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="typeof">
					<xsl:choose>
						<xsl:when test="$recordType='hoard'">nmo:Hoard</xsl:when>
						<xsl:when test="$recordType='conceptual'">nmo:TypeSeriesItem</xsl:when>
						<xsl:when test="$recordType='physical'">nmo:NumismaticObject</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<div class="container-fluid" typeof="{$typeof}" about="{concat($uri_space, $id)}">
					<xsl:choose>
						<xsl:when test="count(/content/*[local-name()='nuds']) &gt; 0">
							<xsl:call-template name="nuds"/>
							
						</xsl:when>
						<xsl:when test="count(/content/*[local-name()='nudsHoard']) &gt; 0">
							<xsl:call-template name="nudsHoard"/>
						</xsl:when>
						<xsl:otherwise>false</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>