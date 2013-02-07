<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="http://code.google.com/p/numishare/" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="text/html"/>
	<xsl:include href="header.xsl"/>
	<xsl:include href="footer.xsl"/>
	<xsl:include href="templates.xsl"/>
	<xsl:include href="functions.xsl"/>

	<xsl:param name="pipeline"/>
	<xsl:param name="lang"/>
	<xsl:param name="mode"/>
	<xsl:param name="display_path"/>

	<!-- config variables-->
	<xsl:variable name="collection_type" select="//config/collection_type"/>

	<!-- load facets into variable -->
	<xsl:variable name="facets" select="//lst[@name='facet_fields']"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="//config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="numishare:normalizeLabel('header_compare', $lang)"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$display_path}images/favicon.png"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.8.0/build/cssgrids/grids-min.css"/>
				<!-- Core + Skin CSS -->
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/menu/assets/skins/sam/menu.css"/>
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

				<!-- search related functions -->
				<script type="text/javascript" src="{$display_path}javascript/jquery.livequery.js"/>
				<script type="text/javascript" src="{$display_path}javascript/search_functions.js"/>
				<script type="text/javascript" src="{$display_path}javascript/compare.js"/>
				<script type="text/javascript" src="{$display_path}javascript/compare_functions.js"/>
				<xsl:if test="string(/config/google_analytics/script)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics/script"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="compare"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="compare">
		<div class="yui3-g">
			<div class="yui3-u">
				<div class="content">
					<h1>
						<xsl:value-of select="numishare:normalizeLabel('header_compare', $lang)"/>
					</h1>
					<p>This feature allows you to compare the results of conducting two separate searches of the database. The results of the searches are displayed on the results page in parallel
						columns and may be sorted separately.</p>
				</div>
			</div>
			<div class="yui3-u-1-2">
				<div class="content">					
					<div class="compare-form">
						<form id="dataset1" method="GET">
							<div id="searchItemTemplate_1" class="searchItemTemplate">
								<select id="search_option_1" class="category_list">
									<xsl:call-template name="search_options"/>
								</select>
								<div style="display:inline;" class="option_container">
									<input type="text" id="search_text" class="search_text" style="display: inline;"/>
								</div>
								<a class="gateTypeBtn" href="#">add »</a>
								<a id="removeBtn_1" class="removeBtn" href="#">« remove</a>
							</div>
						</form>
					</div>
					<div id="search1"/>
				</div>
			</div>
			<div class="yui3-u-1-2">
				<div class="compare-form">
					<form id="dataset2" method="GET">
						<div id="searchItemTemplate_1" class="searchItemTemplate">
							<select id="search_option_1" class="category_list">
								<xsl:call-template name="search_options"/>
							</select>
							<div style="display:inline;" class="option_container">
								<input type="text" id="search_text" class="search_text" style="display: inline;"/>
							</div>
							<a class="gateTypeBtn" href="#">add »</a>
							<a id="removeBtn_1" class="removeBtn" href="#">«</a>
						</div>
					</form>
					<div style="display:table;width:100%;">
						<xsl:text>Image: </xsl:text>
						<select id="image" style="width: 200px;">
							<option value="obverse">Obverse</option>
							<option value="reverse">Reverse</option>
						</select>
						<input class="compare_button" type="submit" value="Compare Data"/>
					</div>
					<div id="searchItemTemplate" class="searchItemTemplate">
						<select id="search_option_1" class="category_list">
							<xsl:call-template name="search_options"/>
						</select>
						<div style="display:inline;" class="option_container">
							<input type="text" id="search_text" class="search_text" style="display: inline;"/>
						</div>
						<a class="gateTypeBtn" href="#">add »</a>
						<a id="removeBtn_1" class="removeBtn" href="#">«</a>
					</div>
				</div>
				<div id="search2"/>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
