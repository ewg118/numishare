<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="http://code.google.com/p/numishare/" xmlns:saxon="http://saxon.sf.net/" version="2.0" exclude-result-prefixes="#all">
	<xsl:include href="header.xsl"/>
	<xsl:include href="footer.xsl"/>
	<xsl:include href="functions.xsl"/>

	<xsl:param name="pipeline"/>
	<xsl:param name="display_path"/>
	<xsl:param name="lang"/>

	<xsl:template match="/config">
		<html>
			<head>
				<title>
					<xsl:value-of select="title"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$display_path}images/favicon.png"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.8.0/build/cssgrids/grids-min.css"/>
				<link type="text/css" href="{$display_path}themes/{theme/jquery_ui_theme}.css" rel="stylesheet"/>
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

				<!-- index script -->
				<script type="text/javascript" src="{$display_path}javascript/get_features.js"/>
				<xsl:if test="string(/config/google_analytics/script)">
					<script type="text/javascript">
<xsl:value-of select="google_analytics/script"/>
</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="index"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="index">
		<div class="yui3-g">
			<div class="yui3-u-2-3">
				<div class="content">
					<xsl:choose>
						<xsl:when test="string($lang)">
							<xsl:choose>
								<xsl:when test="string(//pages/index/description[@xml:lang=$lang])">
									<xsl:copy-of select="saxon:parse(concat('&lt;div&gt;', string(//pages/index/description[@xml:lang=$lang]), '&lt;/div&gt;'))"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="count(//pages/index/description) &gt; 0">
											<xsl:copy-of select="saxon:parse(concat('&lt;div&gt;', string(//pages/index/description[1]), '&lt;/div&gt;'))"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:copy-of select="saxon:parse(concat('&lt;div&gt;', string(//pages/index), '&lt;/div&gt;'))"/>
										</xsl:otherwise>
									</xsl:choose>

								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="count(//pages/index/description) &gt; 0">
									<xsl:copy-of select="saxon:parse(concat('&lt;div&gt;', string(//pages/index/description[1]), '&lt;/div&gt;'))"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy-of select="saxon:parse(concat('&lt;div&gt;', string(//pages/index), '&lt;/div&gt;'))"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<div class="yui3-u-1-3" id="numishare-widget">
				<div class="content">
					<div id="quick_search" style="margin:10px 0;">
						<div class="ui-widget-header ui-helper-clearfix ui-corner-all">Search the Collection</div>
						<form action="results" method="GET" id="qs_form" style="padding:10px 0">							
							<input type="text" name="q"/>
							<input id="qs_button" type="submit" value="{numishare:normalizeLabel('header_search', $lang)}"/>
						</form>
					</div>
					<div id="linked_data" style="margin:10px 0;">
						<div class="ui-widget-header ui-helper-clearfix ui-corner-all">Linked Data</div>
						<!--<a href="{$display_path}rdf/">
							<img src="{$display_path}images/rdf-large.gif" title="RDF" alt="PDF"/>
							</a>-->
						<a href="{$display_path}feed/?q=*:*">
							<img src="{$display_path}images/atom-large.png" title="Atom" alt="Atom"/>
						</a>
						<xsl:if test="pelagios_enabled=true()">
							<a href="pelagios.void.rdf">
								<img src="{$display_path}images/pelagios_icon.png" title="Pelagios VOiD" alt="Pelagios VOiD"/>
							</a>
						</xsl:if>
						<xsl:if test="ctype_enabled=true()">
							<a href="nomisma.void.rdf">
								<img src="{$display_path}images/rdf-large.gif" title="nomisma VOiD" alt="nomisma VOiD"/>
							</a>
						</xsl:if>
					</div>
					<xsl:if test="features_enabled = true()">
						<div id="feature" style="margin:10px 0;">
							<div class="ui-widget-header ui-helper-clearfix ui-corner-all">Featured Object</div>
						</div>
					</xsl:if>
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
