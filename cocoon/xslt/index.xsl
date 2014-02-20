<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:saxon="http://saxon.sf.net/" version="2.0" exclude-result-prefixes="#all">
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
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link type="text/css" href="{$display_path}style.css" rel="stylesheet"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
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
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-9">
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
				<div class="col-md-3">
					<div>
						<h3>Search the Collection</h3>
						<form action="results" method="GET" id="qs_form" style="padding:10px 0">
							<input type="text" name="q"/>
							<input id="qs_button" type="submit" value="{numishare:normalizeLabel('header_search', $lang)}"/>
						</form>
					</div>
					<div>
						<h3>Linked Data</h3>
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
						<div id="feature">
							<h3>Featured Object</h3>
						</div>
					</xsl:if>
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
