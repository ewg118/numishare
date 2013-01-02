<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" indent="yes" encoding="UTF-8" media-type="text/html"/>
	<xsl:include href="search_segments.xsl"/>
	<xsl:include href="header.xsl"/>
	<xsl:include href="footer.xsl"/>

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
					<xsl:text>: Compare Coins</xsl:text>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$display_path}images/favicon.png"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/grids/grids-min.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/reset-fonts-grids/reset-fonts-grids.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/base/base-min.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/fonts/fonts-min.css"/>
				<!-- Core + Skin CSS -->
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/menu/assets/skins/sam/menu.css"/>
				<link type="text/css" href="{$display_path}themes/{//config/theme/jquery_ui_theme}.css" rel="stylesheet"/>
				<link type="text/css" href="{$display_path}style.css" rel="stylesheet"/>
				<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"/>
				<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/jquery-ui.min.js"/>

				<script type="text/javascript" src="{$display_path}javascript/jquery.livequery.js"/>
				<script type="text/javascript" src="{$display_path}javascript/compare.js"/>
				<script type="text/javascript" src="{$display_path}javascript/compare_functions.js"/>
				<script type="text/javascript" src="{$display_path}javascript/numishare-menu.js"/>
				<xsl:if test="string(/config/google_analytics/script)">
					<script type="text/javascript">
						<xsl:value-of select="//config/google_analytics/script"/>
					</script>
				</xsl:if>
			</head>
			<body class="yui-skin-sam">
				<div id="doc4" class="{//config/theme/layouts/*[name()=$pipeline]/yui_class}">
					<xsl:call-template name="header"/>
					<xsl:call-template name="compare"/>
					<xsl:call-template name="footer"/>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="compare">
		<div id="bd">
			<div id="yui-main">
				<div class="yui-g">
					<h1>Compare</h1>
					<p>This feature allows you to compare the results of conducting two separate searches of the database. The results of the searches are displayed on the results page in parallel
						columns and may be sorted separately.</p>
					<div class="yui-u first">

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
						<table id="search1"/>
					</div>
					<div class="yui-u">
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
						<table id="search2"/>
					</div>
				</div>
			</div>

		</div>
	</xsl:template>
</xsl:stylesheet>
