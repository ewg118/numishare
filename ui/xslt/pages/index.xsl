<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" version="2.0"
	exclude-result-prefixes="#all">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<!-- URL params -->
	<xsl:param name="pipeline">display</xsl:param>	
	<xsl:variable name="collection-name" select="substring-before(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
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
	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path"
		select="
			if (string(//config/theme/themes_url)) then
				concat(//config/theme/themes_url, //config/theme/orbeon_theme)
			else
				concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>


	<xsl:template match="//config">
		<html lang="en">
			<head>
				<title>
					<xsl:value-of select="title"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
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
		<div class="container-fluid index">
			<xsl:if test="$lang = 'ar'">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<xsl:choose>
						<xsl:when test="$collection-name = 'pella' or $collection-name = 'sco' or $collection-name = 'pco' or $collection-name = 'hrc'">
							<img src="{$include_path}/images/{$collection-name}-banner.jpg" style="width:100%"/>
						</xsl:when>
						<xsl:otherwise>
							<div class="jumbotron">
								<div class="container">
									<div class="row">
										<!-- display title and description in the jumbotron, including featured object, if available -->
										<xsl:choose>
											<xsl:when test="features_enabled = true()">
												<div class="col-md-9">
													<h1><xsl:value-of select="title"/></h1>
													<p><xsl:value-of select="description"/></p>
												</div>
												<div class="col-md-3">
													<xsl:copy-of select="/content/div[@id='feature']"/>	
												</div>
											</xsl:when>
											<xsl:otherwise>
												<div class="col-md-12">
													<h1><xsl:value-of select="title"/></h1>
													<p><xsl:value-of select="description"/></p>
												</div>
											</xsl:otherwise>
										</xsl:choose>
									</div>
								</div>
							</div>
						</xsl:otherwise>
					</xsl:choose>
					
				</div>
			</div>
			<div class="row content">
				<div class="col-md-8">
					<xsl:choose>
						<xsl:when test="string($lang)">
							<xsl:choose>
								<xsl:when test="string(//pages/index/content[@xml:lang = $lang])">
									<xsl:copy-of select="//pages/index/content[@xml:lang = $lang]/*"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="count(//pages/index/content) &gt; 0">
											<xsl:copy-of select="//pages/index/content[1]/*"/>
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
								<xsl:when test="count(//pages/index/content) &gt; 0">
									<xsl:copy-of select="//pages/index/content[1]/*"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy-of select="//pages/index/*"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<div class="row">						
						<div class="col-md-6 data_options">
							<h3>Linked Data</h3>
							<a href="{$display_path}feed/?q=*:*">
								<img src="{$include_path}/images/atom-large.png" title="Atom" alt="Atom"/>
							</a>
							<xsl:if test="pelagios_enabled = true()">
								<a href="pelagios.void.rdf">
									<img src="{$include_path}/images/pelagios_icon.png" title="Pelagios VOiD" alt="Pelagios VOiD"/>
								</a>
							</xsl:if>
							<xsl:if test="ctype_enabled = true()">
								<a href="nomisma.void.rdf">
									<img src="{$include_path}/images/nomisma.png" title="nomisma VOiD" alt="nomisma VOiD"/>
								</a>
							</xsl:if>
						</div>
					</div>

				</div>
				<div class="col-md-4">
					<!--<div class="highlight">
						<h3>Share</h3>
						<!-\- AddThis Button BEGIN -\->
						<div class="addthis_toolbox addthis_default_style addthis_32x32_style">
							<a class="addthis_button_preferred_1"/>
							<a class="addthis_button_preferred_2"/>
							<a class="addthis_button_preferred_3"/>
							<a class="addthis_button_preferred_4"/>
							<a class="addthis_button_compact"/>
							<a class="addthis_counter addthis_bubble_style"/>
						</div>
						<script type="text/javascript" src="http://s7.addthis.com/js/250/addthis_widget.js#pubid=xa-4ffc41710d8b692c"/>
						<!-\- AddThis Button END -\->
					</div>-->
					<div class="highlight">
						<h3>Support</h3>
						<p>
							<a href="http://www.neh.gov/">
								<img src="{$include_path}/images/neh_logo_horizontal_rgb.jpg" style="max-width:100%"/>
							</a>
						</p>
						<p>In March 2017, the National Endowment for the Humanities awarded <xsl:value-of select="title"/> $262,000 as part of the the broader <a
								href="http://numismatics.org/neh-hrc2017/">Hellenistic Royal Coinages (HRC)</a> initiative. This grant is issued through the NEH <a
								href="http://www.neh.gov/grants/preservation/humanities-collections-and-reference-resources">Humanities Collections and
								Reference Resources</a> program, to be dispersed over three years, to complete the project.</p>

					</div>
					<!--<div class="highlight">
						<h3>Collaborators</h3>
					</div>-->
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
