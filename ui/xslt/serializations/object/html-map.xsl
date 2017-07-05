<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../functions.xsl"/>
	<!-- URL params -->
	<xsl:param name="pipeline">display_map</xsl:param>
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
	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="collection_type" select="/content/config/collection_type"/>
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="include_path" select="if (string(//config/theme/themes_url)) then concat(//config/theme/themes_url, //config/theme/orbeon_theme) else concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>
	<xsl:variable name="recordType">
		<xsl:choose>
			<xsl:when test="descendant::nuds:nuds">
				<xsl:value-of select="//nuds:nuds/@recordType"/>
			</xsl:when>
			<xsl:when test="descendant::nh:nudsHoard">hoard</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="id" select="normalize-space(//*[local-name() = 'recordId'])"/>

	<xsl:variable name="hasFindspots" select="if (doc('input:hasFindspots')//res:sparql/res:boolean) then doc('input:hasFindspots')//res:sparql/res:boolean else false()" as="xs:boolean"/>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when
				test="count(descendant::*:otherRecordId[@semantic = 'dcterms:isReplacedBy']) &gt; 1 and descendant::*:control/*:maintenanceStatus = 'cancelledSplit'">
				<html>
					<head>
						<xsl:call-template name="generic_head"/>
					</head>
					<body>
						<div class="container-fluid">
							<xsl:if test="$lang = 'ar'">
								<xsl:attribute name="style">direction: rtl;</xsl:attribute>
							</xsl:if>
							<div class="row">
								<div class="col-md-12">
									<h1>
										<xsl:value-of select="$id"/>
									</h1>
									<p>This resource has been split and supplanted by the following new URIs:</p>
									<ul>
										<xsl:for-each select="descendant::*:otherRecordId[@semantic = 'dcterms:isReplacedBy']">
											<xsl:variable name="uri"
												select="
													if (contains(., 'http://')) then
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
					</body>
				</html>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="contruct_page"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="contruct_page">
		<html>
			<head>
				<xsl:call-template name="generic_head"/>
				<xsl:choose>
					<xsl:when test="$recordType = 'physical'">
						<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
					</xsl:when>
					<!-- coin-type CSS and JS dependencies -->
					<xsl:when test="$recordType = 'conceptual'">
						<xsl:if test="$hasFindspots = true()">
							<script type="text/javascript" src="http://openlayers.org/api/2.12/OpenLayers.js"/>
							<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.20&amp;sensor=false"/>
							<script type="text/javascript" src="{$include_path}/javascript/mxn.js"/>
							<script type="text/javascript" src="{$include_path}/javascript/timeline-2.3.0.js"/>
							<link type="text/css" href="{$include_path}/css/timeline-2.3.0.css" rel="stylesheet"/>
							<script type="text/javascript" src="{$include_path}/javascript/timemap_full.pack.js"/>
							<script type="text/javascript" src="{$include_path}/javascript/param.js"/>
						</xsl:if>
						
						<script type="text/javascript" src="{$include_path}/javascript/display_map_functions.js"/>
					</xsl:when>
					<!-- hoard CSS and JS dependencies -->
					<xsl:when test="$recordType = 'hoard'">
						<script type="text/javascript" src="http://openlayers.org/api/2.12/OpenLayers.js"/>
						<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.20&amp;sensor=false"/>
						<script type="text/javascript" src="{$include_path}/javascript/mxn.js"/>
						<script type="text/javascript" src="{$include_path}/javascript/timeline-2.3.0.js"/>
						<link type="text/css" href="{$include_path}/css/timeline-2.3.0.css" rel="stylesheet"/>
						<script type="text/javascript" src="{$include_path}/javascript/timemap_full.pack.js"/>
						<script type="text/javascript" src="{$include_path}/javascript/param.js"/>
						<script type="text/javascript" src="{$include_path}/javascript/display_hoard_functions.js"/>
					</xsl:when>
				</xsl:choose>
			</head>
			<body>
				<div class="container-fluid" style="height:100%">
					<xsl:if test="$lang = 'ar'">
						<xsl:attribute name="style">direction: rtl;</xsl:attribute>
					</xsl:if>
					<div class="row" style="height:100%">
						<div class="col-md-12" style="height:100%">
							<div id="timemap-legend">
								<h2>
									<xsl:value-of select="numishare:normalizeLabel('maps_legend', $lang)"/>
								</h2>
								<div class="legend">
									<table>
										<tbody>
											<tr>
												<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
												<td style="width:100px">
													<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
												</td>
											</tr>
											<tr>
												<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
												<td style="width:100px">
													<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
												</td>
											</tr>
											<xsl:if test="descendant::nuds:subject[contains(@xlink:href, 'geonames.org')]">
												<tr>
													<td style="background-color:#00e64d;border:2px solid black;width:50px;"/>
													<td style="width:100px">
														<xsl:value-of select="numishare:regularize_node('subject', $lang)"/>
													</td>
												</tr>
											</xsl:if>
										</tbody>
									</table>
								</div>
								<small>
									<a href="{$url}id/{$id}"><span class="glyphicon glyphicon-arrow-left"/>Return</a>
								</small>
							</div>
							<xsl:choose>
								<xsl:when test="$recordType = 'physical'">
									<div id="mapcontainer" style="height:100%"/>
								</xsl:when>
								<xsl:when test="$recordType = 'conceptual'">
									<xsl:choose>
										<xsl:when test="$hasFindspots = true()">
											<div id="timemap" style="height:100%">
												<div id="mapcontainer" class="fullscreen">
													<div id="map"/>
												</div>
												<div id="timelinecontainer">
													<div id="timeline"/>
												</div>
											</div>
										</xsl:when>
										<xsl:otherwise>
											<div id="mapcontainer" style="height:100%"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="$recordType='hoard'">
									<div id="timemap" style="height:100%">
										<div id="mapcontainer" class="fullscreen">
											<div id="map"/>
										</div>
										<div id="timelinecontainer">
											<div id="timeline"/>
										</div>
									</div>
								</xsl:when>
							</xsl:choose>
						</div>
					</div>
				</div>
				<div class="hidden">
					<span id="baselayers">
						<xsl:value-of select="string-join(//config/baselayers/layer[@enabled = true()], ',')"/>
					</span>
					<span id="collection_type">
						<xsl:value-of select="$collection_type"/>
					</span>
					<span id="path">
						<xsl:choose>
							<xsl:when test="$recordType = 'physical'">
								<xsl:value-of select="concat($display_path, 'id/')"/>
							</xsl:when>
							<xsl:when test="$recordType = 'conceptual' and $hasFindspots = false()">
								<xsl:value-of select="concat($display_path, 'id/')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$display_path"/>
							</xsl:otherwise>
						</xsl:choose>
					</span>
					<span id="pipeline">
						<xsl:value-of select="$pipeline"/>
					</span>
					<span id="object_title">
						<xsl:value-of select="descendant::*:descMeta/*:title"/>
					</span>
					<span id="mapboxKey">
						<xsl:value-of select="//config/mapboxKey"/>
					</span>
					<span id="lang">
						<xsl:value-of select="$lang"/>
					</span>
					<xsl:if test="$recordType = 'conceptual'">
						<span id="hasFindspots">
							<xsl:value-of select="$hasFindspots"/>
						</span>
					</xsl:if>
				</div>
			</body>
		</html>
	</xsl:template>
	<xsl:template name="generic_head">
		<title id="{$id}">
			<xsl:value-of select="//config/title"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="descendant::*:descMeta/*:title"/>
		</title>
		<!-- CSS -->
		<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
		<meta name="viewport" content="width=device-width, initial-scale=1"/>
		<!-- bootstrap -->
		<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
		<script type="text/javascript" src="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
		<link type="text/css" href="{$include_path}/css/fullscreen.css" rel="stylesheet"/>
		<xsl:if test="string(//config/google_analytics)">
			<script type="text/javascript">
				<xsl:value-of select="//config/google_analytics"/>
			</script>
		</xsl:if>

		<link rel="stylesheet" href="https://unpkg.com/leaflet@0.7.7/dist/leaflet.css"/>
		<script src="https://unpkg.com/leaflet@0.7.7/dist/leaflet.js"/>
		<script type="text/javascript" src="{$include_path}/javascript/leaflet.ajax.min.js"/>
	</xsl:template>
</xsl:stylesheet>
