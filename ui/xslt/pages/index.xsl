<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" version="2.0" exclude-result-prefixes="#all">
	<xsl:include href="../templates.xsl"/>
	<xsl:include href="../functions.xsl"/>

	<xsl:param name="pipeline">display</xsl:param>
	<xsl:param name="langParam" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="lang">
		<xsl:choose>
			<xsl:when test="string($langParam)">
				<xsl:value-of select="$langParam"/>
			</xsl:when>
			<xsl:when test="string(doc('input:request')/request//header[name[.='accept-language']]/value)">
				<xsl:value-of select="numishare:parseAcceptLanguage(doc('input:request')/request//header[name[.='accept-language']]/value)[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:param>
	<xsl:variable name="display_path"/>
	<xsl:variable name="include_path" select="if (string(//config/theme/themes_url)) then concat(//config/theme/themes_url, //config/theme/orbeon_theme) else concat('http://', doc('input:request')/request/server-name, ':8080/orbeon/themes/', //config/theme/orbeon_theme)"/>


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
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link type="text/css" href="{$include_path}/css/style.css" rel="stylesheet"/>
				
				<xsl:for-each select="includes/include">
					<xsl:choose>
						<xsl:when test="@type = 'css'">
							<link type="text/{@type}" rel="stylesheet" href="{@url}"/>
						</xsl:when>
						<xsl:when test="@type = 'javascript'">
							<script type="text/{@type}" src="{@url}"/>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
				
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
		<!--<div class="jumbotron">
			<div class="container">
				<div class="row">
					<!-\- display title and description in the jumbotron, including featured object, if available -\->
					<xsl:choose>
						<xsl:when test="features_enabled = true()">
							<div class="col-md-9">
								<h1>
									<xsl:value-of select="title"/>
								</h1>
								<p>
									<xsl:value-of select="description"/>
								</p>
							</div>
							<div class="col-md-3">
								<xsl:copy-of select="/content/div[@id='feature']"/>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<div class="col-md-12">
								<h1>
									<xsl:value-of select="title"/>
								</h1>
								<p>
									<xsl:value-of select="description"/>
								</p>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
		</div>-->
		
		<!-- jumbotron scaling image -->
		<img src="{$include_path}/images/banner.jpg" style="width:100%"/>
		<div class="container-fluid content">
			<div class="row">
				<div class="col-md-9">
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
					<div class="row">
						<div class="col-md-6">
							<h3>Collaborators</h3>
							<p>
								<a href="http://numismatics.org" title="American Numismatic Society" style="margin:0 10px;">
									<img src="{$include_path}/images/logo_ans.jpg" alt="ANS"/>
								</a>
								<a href="http://isaw.nyu.edu/" title="Institute for the Study of the Ancient World" style="margin:0 10px;">
									<img src="{$include_path}/images/logo_isaw.jpg" alt="ISAW"/>
								</a>
								<a href="http://www.dainst.org/" title="Deutsches Archäologisches Institut" style="margin:0 10px;">
									<img src="{$include_path}/images/logo_dai.png" alt="DAI"/>
								</a>
								<br/>
								<a href="http://ww2.smb.museum/ikmk/" title="Münzkabinett Berlin" style="margin:0 10px;">
									<img src="{$include_path}/images/logo_berlin.jpg" alt="Berlin"/>
								</a>
								<br/>
								<a href="https://www.spink.com/" title="Spink &amp; Son" style="margin:0 10px;">
									<img src="{$include_path}/images/logo_spink.jpg" alt="Spink &amp; Son" style="width:260px;"/>
								</a>
							</p>
						</div>
						<div class="col-md-6">
							<h3>Support</h3>
							<p>
								<a href="http://www.neh.gov/">
									<img src="{$include_path}/images/neh_logo_horizontal_rgb.jpg" style="max-width:100%"/>
								</a>
							</p>
							<p>In May 2014, the National Endowment for the Humanities awarded OCRE $300,000 as part of the <a
									href="http://www.neh.gov/grants/preservation/humanities-collections-and-reference-resources">Humanities Collections and Reference Resources</a> program, to be
								dispersed over three years, to complete the project. <a href="http://numismatics.org/wikiuploads/NewsEvents/2014_0404_PR_major-grant-NEH-.pdf">Press release</a></p>
						</div>
					</div>
				</div>
				<div class="col-md-3">					
					<div class="highlight data_options">
						<h3>Linked Data</h3>
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
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
