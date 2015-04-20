<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink"
	 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="header.xsl"/>
	<xsl:include href="footer.xsl"/>
	<xsl:include href="templates.xsl"/>
	<xsl:include href="functions.xsl"/>
	<xsl:include href="display/nuds/html.xsl"/>
	<xsl:include href="display/nudsHoard/html.xsl"/>
	<xsl:include href="display/shared-html.xsl"/>

	<xsl:param name="pipeline"/>
	<xsl:param name="solr-url"/>
	<xsl:param name="mode"/>
	<xsl:param name="lang"/>

	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="url">
		<xsl:value-of select="/content/config/url"/>
	</xsl:variable>

	<!-- get layout -->
	<xsl:variable name="orientation" select="/content/config/theme/layouts/display/nuds/orientation"/>
	<xsl:variable name="image_location" select="/content/config/theme/layouts/display/nuds/image_location"/>

	<xsl:param name="display_path">
		<xsl:if test="not(string($mode))">
			<xsl:text>../</xsl:text>
		</xsl:if>
	</xsl:param>

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
							<xsl:value-of select="."/>
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
						<object xlink:href="{$type_series_uri}id/{nuds:control/nuds:recordId}">
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

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">
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


	<xsl:variable name="has_mint_geo">
		<xsl:choose>
			<xsl:when test="count($rdf/descendant::nm:mint) &gt; 0">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="has_findspot_geo">
		<xsl:choose>
			<xsl:when test="count($rdf/descendant::nm:findspot) &gt; 0 or count(descendant::*[local-name()='geogname'][@xlink:role='findspot' and string(@xlink:href)]) &gt; 0">true</xsl:when>
			<xsl:when test="/content/response-findspot = 'true'">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
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
						<div class="yui3-g">
							<div class="yui3-u-1">
								<div class="content">
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
						<div class="yui3-g">
							<div class="yui3-u-1">
								<div class="content">
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
				<html>
					<head>
						<xsl:call-template name="generic_head"/>

						<xsl:choose>
							<xsl:when test="$recordType='physical'">
								<!-- determine whether the document has published findspots or associated object findspots -->
								<script type="text/javascript" langage="javascript">
			                                                        $(function () {
			                                                                $("#tabs").tabs({
			                                                                        show: function (event, ui) {
			                                                                                if (ui.panel.id == "mapTab" &amp;&amp; $('#mapcontainer').html().length == 0) {
			                                                                                        $('#mapcontainer').html('');
			                                                                                        initialize_map('<xsl:value-of select="$id"/>', '<xsl:value-of select="$display_path"/>');
			                                                                                }
			                                                                        }
			                                                                });
			                                                        });
							</script>
								<xsl:if test="$has_mint_geo = 'true' or $has_findspot_geo = 'true'">
									<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
									<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
									<script type="text/javascript" src="{$display_path}javascript/display_map_functions.js"/>
								</xsl:if>
							</xsl:when>
							<!-- coin-type CSS and JS dependencies -->
							<xsl:when test="$recordType='conceptual'">
								<link type="text/css" href="{$display_path}jquery.fancybox-1.3.4.css" rel="stylesheet"/>
								<script type="text/javascript" src="{$display_path}javascript/jquery.fancybox-1.3.4.min.js"/>
								<script type="text/javascript" src="{$display_path}javascript/highcharts.js"/>
								<script type="text/javascript" src="{$display_path}javascript/modules/exporting.js"/>
								<script type="text/javascript" src="{$display_path}javascript/display_functions.js"/>

								<script type="text/javascript" langage="javascript">
			                                                        $(function () {
			                                                                $("#tabs").tabs({
			                                                                        show: function (event, ui) {
			                                                                                if (ui.panel.id == "mapTab" &amp;&amp; $('#mapcontainer').html().length == 0) {
			                                                                                        $('#mapcontainer').html('');
			                                                                                        initialize_map('<xsl:value-of select="$id"/>', '<xsl:value-of select="$display_path"/>');
			                                                                                }
			                                                                        }
			                                                                });
			                                                        });
							</script>
								<!-- mapping -->
								<xsl:if test="$has_mint_geo = 'true' or $has_findspot_geo = 'true'">
									<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
									<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
									<script type="text/javascript" src="{$display_path}javascript/display_map_functions.js"/>
								</xsl:if>
							</xsl:when>
							<!-- hoard CSS and JS dependencies -->
							<xsl:when test="$recordType='hoard'">
								<script type="text/javascript" src="{$display_path}javascript/highcharts.js"/>
								<script type="text/javascript" src="{$display_path}javascript/modules/exporting.js"/>
								<script type="text/javascript" src="{$display_path}javascript/jquery.livequery.js"/>
								<script type="text/javascript" src="{$display_path}javascript/display_hoard_functions.js"/>
								<script type="text/javascript" src="{$display_path}javascript/analysis_functions.js"/>

								<!-- mapping -->
								<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
								<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
								<script type="text/javascript" src="{$display_path}javascript/mxn.js"/>
								<script type="text/javascript" src="{$display_path}javascript/timeline-2.3.0.js"/>
								<link type="text/css" href="{$display_path}timeline-2.3.0.css" rel="stylesheet"/>
								<script type="text/javascript" src="{$display_path}javascript/timemap_full.pack.js"/>
								<script type="text/javascript" src="{$display_path}javascript/param.js"/>
								<script type="text/javascript" src="{$display_path}javascript/loaders/xml.js"/>
								<script type="text/javascript" src="{$display_path}javascript/loaders/kml.js"/>
							</xsl:when>
						</xsl:choose>
					</head>
					<body>
						<xsl:call-template name="header"/>						
						<xsl:call-template name="display"/>
						<xsl:call-template name="footer"/>
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
			<xsl:value-of
				select="if (descendant::nuds:nuds) then descendant::nuds:nuds/nuds:descMeta/nuds:title else if (descendant::*[local-name()='nudsHoard']) then descendant::nuds:recordId else ''"/>
		</title>
		<!-- alternates -->
		<link rel="alternate" type="text/xml" href="{concat($url, 'id/', $id)}.xml"/>
		<link rel="alternate" type="application/rdf+xml" href="{concat($url, 'id/', $id)}.rdf"/>
		<link rel="alternate" type="application/atom+xml" href="{concat($url, 'id/', $id)}.atom"/>
		<xsl:if test="$has_mint_geo = 'true' or $has_findspot_geo = 'true'">
			<link rel="alternate" type="application/vnd.google-earth.kml+xml" href="{concat($url, 'collection/', $id)}.kml"/>
		</xsl:if>
		<!-- CSS -->
		<link rel="shortcut icon" type="image/x-icon" href="{$display_path}images/favicon.png"/>
		<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.8.0/build/cssgrids/grids-min.css"/>
		<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"/>
		<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/jquery-ui.min.js"/>

		<!-- menu -->
		<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.core.js"/>
		<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.widget.js"/>
		<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.position.js"/>
		<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.button.js"/>
		<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.menu.js"/>
		<script type="text/javascript" src="{$display_path}javascript/ui/jquery.ui.menubar.js"/>
		<script type="text/javascript" src="{$display_path}javascript/numishare-menu.js"/>
		<link type="text/css" href="{$display_path}themes/{//config/theme/jquery_ui_theme}.css" rel="stylesheet"/>
		<link type="text/css" href="{$display_path}style.css" rel="stylesheet"/>
		<xsl:if test="string(//config/google_analytics/script)">
			<script type="text/javascript">
								<xsl:value-of select="//config/google_analytics/script"/>
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
				<div class="yui3-g">
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
