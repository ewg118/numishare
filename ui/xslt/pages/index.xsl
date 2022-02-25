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
	
	<!-- URI space for featured items -->	
	<xsl:variable name="uri_space">
		<xsl:choose>
			<xsl:when test="string(//config/uri_space)">
				<xsl:value-of select="//config/uri_space"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>id/</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="//config">
		<html lang="en">
			<head>
				<title>
					<xsl:value-of select="title"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/{if (string(//config/favicon)) then //config/favicon else 'favicon.png'}"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>
				
				<!-- bootstrap -->
				<link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
				<script src="https://netdna.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>
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
				
				<!-- open graph/twitter metadata -->
				<meta property="og:url" content="{url}"/>
				<meta property="og:type" content="article"/>
				<meta property="og:title" content="{title}"/>
				<meta property="twitter:url" content="{url}"/>
				<meta property="twitter:title" content="{title}"/>
				<meta name="twitter:card" content="summary_large_image"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="index"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="index">
		<div class="jumbotron">
			<div class="container">
				<div class="row">
					<!-- display title and description in the jumbotron, including featured object, if available -->
					<xsl:choose>
						<xsl:when test="features_enabled = true() and count(doc('input:feature-model')//doc) = 1">
							<div class="col-md-9">
								<h1><xsl:value-of select="title"/></h1>
								<p><xsl:value-of select="description"/></p>
							</div>
							<div class="col-md-3">
								<div id="feature" class="highlight text-center">
									<xsl:apply-templates select="doc('input:feature-model')//doc"/>
								</div>
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
		<div class="container-fluid">
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>							
			</xsl:if>
			<div class="row">
				<div class="col-md-9">					
					<xsl:choose>
						<xsl:when test="string($lang)">
							<xsl:choose>
								<xsl:when test="string(//pages/index/content[@xml:lang=$lang])">
									<xsl:copy-of select="//pages/index/content[@xml:lang=$lang]/*"/>
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
	
	<!-- featured object -->
	<xsl:template match="doc">		
		<h3>Featured Object</h3>
		<div>
			<a href="{$uri_space}{str[@name='recordId']}{if(string($langParam)) then concat('?lang=', $langParam) else ''}">
				<img src="{str[@name='thumbnail_obv']}"/>
			</a>
			<br/>
			<a href="{$uri_space}{str[@name='recordId']}{if(string($langParam)) then concat('?lang=', $langParam) else ''}">
				<xsl:value-of select="str[@name='title_display']"/>
			</a>
			<xsl:if test="string(str[@name='imagesponsor'])">
				<br/>
				<xsl:text>Image Sponsor: </xsl:text>
				<xsl:value-of select="str[@name='imagesponsor']"/>
			</xsl:if>
		</div>
	</xsl:template>

</xsl:stylesheet>
