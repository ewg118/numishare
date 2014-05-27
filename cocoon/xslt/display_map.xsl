<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="functions.xsl"/>

	<!-- URL params -->
	<xsl:param name="pipeline"/>
	<xsl:param name="solr-url"/>
	<xsl:param name="lang"/>

	<!-- config variables -->
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>
	<xsl:variable name="sparql_endpoint" select="/content/config/sparql_endpoint"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="collection_type" select="/content/config/collection_type"/>
	<!-- get layout -->
	<xsl:variable name="orientation" select="/content/config/theme/layouts/display/nuds/orientation"/>
	<xsl:variable name="image_location" select="/content/config/theme/layouts/display/nuds/image_location"/>

	<xsl:variable name="display_path">../</xsl:variable>

	<xsl:variable name="recordType">
		<xsl:choose>
			<xsl:when test="descendant::nuds:nuds">
				<xsl:value-of select="//nuds:nuds/@recordType"/>
			</xsl:when>
			<xsl:when test="descendant::nh:nudsHoard">hoard</xsl:when>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="id" select="normalize-space(//*[local-name()='recordId'])"/>

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
						<div class="container-fluid">
							<div class="row">
								<div class="col-md-12">
									<h1>301: Moved Permanently</h1>
									<p>This resource has been supplanted by <a href="{$uri}"><xsl:value-of select="$uri"/></a>.</p>
								</div>
							</div>
						</div>
					</body>
				</html>
			</xsl:when>
			<xsl:when test="count(descendant::*:otherRecordId[@semantic='dcterms:isReplacedBy']) &gt; 1 and descendant::*:control/*:maintenanceStatus='cancelledSplit'">
				<html>
					<head>
						<xsl:call-template name="generic_head"/>
					</head>
					<body>
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
					<xsl:when test="$recordType='physical'">
						<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
						<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
						<script type="text/javascript" src="{$display_path}javascript/display_map_functions.js"/>
					</xsl:when>
					<!-- coin-type CSS and JS dependencies -->
					<xsl:when test="$recordType='conceptual'">
						<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
						<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
						<script type="text/javascript" src="{$display_path}javascript/mxn.js"/>
						<script type="text/javascript" src="{$display_path}javascript/timeline-2.3.0.js"/>
						<link type="text/css" href="{$display_path}timeline-2.3.0.css" rel="stylesheet"/>
						<script type="text/javascript" src="{$display_path}javascript/timemap_full.pack.js"/>
						<script type="text/javascript" src="{$display_path}javascript/param.js"/>
						<script type="text/javascript" src="{$display_path}javascript/display_map_functions.js"/>
					</xsl:when>
					<!-- hoard CSS and JS dependencies -->
					<xsl:when test="$recordType='hoard'">
						<script type="text/javascript" src="http://www.openlayers.org/api/OpenLayers.js"/>
						<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
						<script type="text/javascript" src="{$display_path}javascript/mxn.js"/>
						<script type="text/javascript" src="{$display_path}javascript/timeline-2.3.0.js"/>
						<link type="text/css" href="{$display_path}timeline-2.3.0.css" rel="stylesheet"/>
						<script type="text/javascript" src="{$display_path}javascript/timemap_full.pack.js"/>
						<script type="text/javascript" src="{$display_path}javascript/param.js"/>
						<script type="text/javascript" src="{$display_path}javascript/display_hoard_functions.js"/>
					</xsl:when>
				</xsl:choose>
			</head>
			<body>
				<div class="container-fluid">
					<div class="row">
						<div class="col-md-12">
							<div id="timemap-legend">
								<h2>
									<xsl:value-of select="numishare:regularize_node('legend', $lang)"/>									
								</h2>

								<div class="legend">
									<table>
										<tbody>
											<tr>
												<td style="background-color:#6992fd;border:2px solid black;width:50px;"/>
												<td style="width:100px">
													<xsl:value-of select="numishare:regularize_node('mint', $lang)"/>
												</td>
												<td style="background-color:#d86458;border:2px solid black;width:50px;"/>
												<td style="width:100px">
													<xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
												</td>
											</tr>
										</tbody>
									</table>
								</div>
								<small>
									<a href="{$display_path}id/{$id}"><span class="glyphicon glyphicon-arrow-left"/>Return</a>
								</small>
							</div>
							<xsl:choose>
								<xsl:when test="$recordType='physical'">
									<div id="mapcontainer"/>
								</xsl:when>
								<xsl:otherwise>
									<div id="timemap">
										<div id="fullscreen-timemapcontainer">
											<div id="map"/>
										</div>
										<div id="timelinecontainer">
											<div id="timeline"/>
										</div>
									</div>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</div>
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
					<span id="pipeline">
						<xsl:value-of select="$pipeline"/>
					</span>
					<span id="object_title">
						<xsl:value-of
							select="if (descendant::nuds:nuds) then descendant::nuds:nuds/nuds:descMeta/nuds:title else if (descendant::*[local-name()='nudsHoard']) then descendant::nuds:recordId else ''"/>
					</span>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="generic_head">
		<title id="{$id}">
			<xsl:value-of select="//config/title"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of
				select="if (descendant::nuds:nuds) then descendant::nuds:nuds/nuds:descMeta/nuds:title else if (descendant::*[local-name()='nudsHoard']) then descendant::nuds:recordId else ''"/>
		</title>
		<!-- CSS -->
		<link rel="shortcut icon" type="image/x-icon" href="{$display_path}images/favicon.png"/>
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
		<meta name="viewport" content="width=device-width, initial-scale=1"/>
		<!-- bootstrap -->
		<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
		<script type="text/javascript" src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
		<link type="text/css" href="{$display_path}fullscreen.css" rel="stylesheet"/>

		<xsl:if test="string(//config/google_analytics)">
			<script type="text/javascript">
				<xsl:value-of select="//config/google_analytics"/>
			</script>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
