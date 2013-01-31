<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:exsl="http://exslt.org/common" xmlns:cinclude="http://apache.org/cocoon/include/1.0"
	xmlns:numishare="http://code.google.com/p/numishare/" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:include href="results_generic.xsl"/>
	<xsl:include href="templates.xsl"/>
	<xsl:include href="functions.xsl"/>
	<xsl:include href="header.xsl"/>
	<xsl:include href="footer.xsl"/>
	
	<xsl:param name="pipeline"/>	
	<xsl:param name="lang"/>
	<xsl:param name="display_path"/>
	<xsl:param name="q"/>
	<xsl:param name="sort"/>
	<xsl:param name="rows">20</xsl:param>
	<xsl:param name="start"/>
	<xsl:variable name="start_var" as="xs:integer">
		<xsl:choose>
			<xsl:when test="number($start)">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:param name="tokenized_q" select="tokenize($q, ' AND ')"/>
	<xsl:param name="mode"/>
	
	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>
	
	<!-- config variables -->
	<xsl:variable name="collection_type" select="/content//collection_type"/>
	<xsl:variable name="sparql_endpoint" select="/content//sparql_endpoint"/>	
	<xsl:variable name="url" select="/content/config/url"/>
	
	<xsl:template match="/">
		<html>
			<head profile="http://a9.com/-/spec/opensearch/1.1/">
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: Browse Collection</xsl:text>
				</title>
				<!-- alternates -->										
				<link rel="alternate" type="application/atom+xml" href="{concat(//config/url, 'feed/?q=', $q)}"/>
				<link rel="alternate" type="text/csv" href="{concat(//config/url, 'data.csv/?q=', $q)}"/>
				<link rel="alternate" type="application/application/vnd.google-earth.kml+xml" href="{concat(//config/url, 'query.kml/?q=', $q)}"/>
				<!-- opensearch compliance -->
				<link rel="search"
					type="application/opensearchdescription+xml" 
					href="{$url}opensearch.xml"
					title="Example Search for {$url}" />
				<meta name="totalResults" content="{$numFound}"/>
				<meta name="startIndex" content="{$start_var}"/>
				<meta name="itemsPerPage" content="{$rows}"/>
				
				<link rel="shortcut icon" type="image/x-icon" href="{$display_path}images/favicon.png"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.8.0/build/cssgrids/grids-min.css"/>
				<!-- Core + Skin CSS -->
				<link type="text/css" href="{$display_path}themes/{//config/theme/jquery_ui_theme}.css" rel="stylesheet"/>
				<link type="text/css" href="{$display_path}style.css" rel="stylesheet"/>
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
				
				<link type="text/css" href="{$display_path}jquery.multiselect.css" rel="stylesheet"/>
				<link type="text/css" href="{$display_path}jquery.fancybox-1.3.4.css" rel="stylesheet"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery.multiselect.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery.multiselectfilter.js"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery.livequery.js"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery.fancybox-1.3.4.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/get_facets.js"/>
				<script type="text/javascript" src="{$display_path}javascript/facet_functions.js"/>
				<script type="text/javascript" src="{$display_path}javascript/sort_results.js"/>
				<script type="text/javascript" src="{$display_path}javascript/numishare-menu.js"/>
				<script type="text/javascript">
							$(document).ready(function(){
								$('a.thumbImage').fancybox();
							});
						</script>
				<xsl:if test="//lst[@name='mint_geo']/int[@name='numFacetTerms'] &gt; 0">
					<script src="http://www.openlayers.org/api/OpenLayers.js" type="text/javascript">//</script>
					<script src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false">//</script>
					<script type="text/javascript" src="{$display_path}javascript/result_map_functions.js"/>
					<script type="text/javascript">
								$(document).ready(function() {
									$("#map_results").fancybox({
										onComplete: function(){
											if  ($('#resultMap').html().length == 0){								
												$('#resultMap').html('');
												initialize_map('<xsl:value-of select="$q"/>','<xsl:value-of select="$collection_type"/>');
											}
										}
									});
								});
							</script>
				</xsl:if>
				<script type="text/javascript" src="javascript/quick_search.js"/>
				<xsl:if test="string(/config/google_analytics/script)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics/script"/>
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
		<div id="backgroundPopup"/>
		<div class="yui3-g">
			<div class="yui3-u-1-4">
				<div class="content">
					<xsl:if test="//result[@name='response']/@numFound &gt; 0">
						<div class="data_options">
							<h2><xsl:value-of select="numishare:normalizeLabel('results_data-options', $lang)"/></h2>
							<a href="{$display_path}feed/?q={$q}">
								<img src="{$display_path}images/atom-medium.png" title="Atom" alt="Atom"/>
							</a>
							<xsl:if test="//lst[@name='mint_geo']/int[@name='numFacetTerms'] &gt; 0">
								<a href="{$display_path}query.kml?q={$q}">
									<img src="{$display_path}images/googleearth.png" alt="KML" title="KML: Limit, 500 objects"/>
								</a>
							</xsl:if>
							<a href="{$display_path}data.csv?q={$q}">
								<!-- the image below is copyright of Silvestre Herrera, available freely on wikimedia commons: http://commons.wikimedia.org/wiki/File:X-office-spreadsheet_Gion.svg -->
								<img src="{$display_path}images/spreadsheet.png" title="CSV" alt="CSV"/>
							</a>
							<a href="{$display_path}visualize?q={$q}">
								<!-- the image below is copyright of Mark James, available freely on wikimedia commons: http://commons.wikimedia.org/wiki/File:Chart_bar.png -->
								<img src="{$display_path}images/visualize.png" title="Visualize" alt="Visualize"/>
							</a>
						</div>
						<h2><xsl:value-of select="numishare:normalizeLabel('results_refine-results', $lang)"/></h2>
						<xsl:call-template name="quick_search"/>
						<xsl:apply-templates select="descendant::lst[@name='facet_fields']"/>
					</xsl:if>
					<span style="display:none" id="collection_type">
						<xsl:value-of select="$collection_type"/>
					</span>
				</div>				
			</div>
			<div class="yui3-u-3-4">
				<div class="content">					
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
							<table>
								<xsl:apply-templates select="descendant::doc"/>
							</table>
							<xsl:call-template name="paging"/>
						</xsl:when>
						<xsl:otherwise>
							<h2> No results found. <a href="results?q=*:*">Start over.</a></h2>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
