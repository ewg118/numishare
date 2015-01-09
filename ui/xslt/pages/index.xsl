<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" version="2.0" exclude-result-prefixes="#all">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="pipeline">display</xsl:param>
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path" select="concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>


	<xsl:template match="/content/config">
		<html lang="en">
			<head>
				<title>
					<xsl:value-of select="title"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
				<xsl:if test="string(google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="google_analytics"/>
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
		<!-- jumbotron scaling image -->
		<img src="{$include_path}/images/banner.jpg" style="width:100%"/>
				
		<div class="container content">			
			<div class="row">
				<div class="col-md-12">
					<xsl:choose>
						<xsl:when test="string($lang)">
							<xsl:choose>
								<xsl:when test="string(//pages/index/description[@xml:lang=$lang])">
									<xsl:copy-of select="//pages/index/description[@xml:lang=$lang]/*"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="count(//pages/index/description) &gt; 0">
											<xsl:copy-of select="//pages/index/description[1]/*"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:copy-of select="//pages/index/*"/>
										</xsl:otherwise>
									</xsl:choose>

								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="count(//pages/index/description) &gt; 0">
									<xsl:copy-of select="//pages/index/description[1]/*"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy-of select="//pages/index/*"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<div class="row">
				<div class="col-md-4">
					<h3>Collaborators</h3>
					<a href="http://numismatics.org" title="American Numismatic Society" style="margin:0 10px;">
						<img src="{$include_path}/images/logo_ans.jpg" alt="ANS"/>
					</a>					
					<a href="http://www.britishmuseum.org/" title="British Museum" style="margin:0 10px;">
						<img src="{$include_path}/images/logo_bm.png" alt="BM"/>
					</a>
					<br/>
					<a href="http://ww2.smb.museum/ikmk/" title="Münzkabinett Berlin">
						<img src="{$include_path}/images/logo_berlin.jpg" alt="Berlin"/>
					</a>
				</div>
				<div class="col-md-4 data_options">
					<h3>Data Export</h3>
					<a href="{$display_path}feed/?q=*:*">
						<img src="{$include_path}/images/atom-large.png" title="Atom" alt="Atom"/>
					</a>
					<xsl:if test="pelagios_enabled=true()">
						<a href="pelagios.void.rdf">
							<img src="{$include_path}/images/pelagios_icon.png" title="Pelagios VOiD" alt="Pelagios VOiD"/>
						</a>
					</xsl:if>
					<xsl:if test="ctype_enabled=true()">
						<a href="nomisma.void.rdf">
							<img src="{$include_path}/images/nomisma.png" title="nomisma VOiD" alt="nomisma VOiD"/>
						</a>
					</xsl:if>
				</div>
				<div class="col-md-4">
					<h3>Share</h3>
					<!-- AddThis Button BEGIN -->
					<div class="addthis_toolbox addthis_default_style addthis_32x32_style">
						<a class="addthis_button_preferred_1"/>
						<a class="addthis_button_preferred_2"/>
						<a class="addthis_button_preferred_3"/>
						<a class="addthis_button_preferred_4"/>
						<a class="addthis_button_compact"/>
						<a class="addthis_counter addthis_bubble_style"/>
					</div>
					<script type="text/javascript" src="http://s7.addthis.com/js/250/addthis_widget.js#pubid=xa-4ffc41710d8b692c"/>
					<!-- AddThis Button END -->
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
