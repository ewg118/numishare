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

				<xsl:if test="$collection-name = 'crro' or $collection-name = 'chrr' or $collection-name = 'rrdp'">
					<meta property="og:image" content="{$include_path}/images/{$collection-name}-banner.jpg"/>
					<meta property="twitter:image" content="{$include_path}/images/{$collection-name}-banner.jpg"/>
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
		<xsl:if test="$collection-name = 'crro' or $collection-name = 'chrr' or $collection-name = 'rrdp'">
			<img src="{$include_path}/images/{$collection-name}-banner.jpg" style="width:100%" alt="banner image"/>
		</xsl:if>

		<xsl:if test="$lang = 'ar'">
			<xsl:attribute name="style">direction: rtl;</xsl:attribute>
		</xsl:if>
		<div class="container-fluid index">

			<xsl:choose>
				<xsl:when test="$collection-name = 'crro' or $collection-name = 'chrr' or $collection-name = 'rrdp'"/>
				<xsl:otherwise>
					<div class="row">
						<div class="col-md-12">
							<div class="jumbotron">
								<div class="container">
									<div class="row">
										<!-- display title and description in the jumbotron, including featured object, if available -->
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
													<xsl:copy-of select="/content/div[@id = 'feature']"/>
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
							</div>
						</div>
					</div>
				</xsl:otherwise>
			</xsl:choose>

			<div class="row content">
				<div class="col-md-12">
					<xsl:choose>
						<xsl:when test="string($lang)">
							<xsl:choose>
								<xsl:when test="string(//pages/index/description[@xml:lang = $lang])">
									<xsl:copy-of select="//pages/index/description[@xml:lang = $lang]/*"/>
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
				<xsl:if test="$collection-name = 'crro'">
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
				</xsl:if>

				<xsl:if test="$collection-name = 'rrdp'">
					<div class="col-md-4">
						<h3>Support</h3>
						<a href="http://www.bigdatabase.com/Big-DB/USFoundation-profiles/ARETE%20FOUNDATION-236779271.HTML" title="Arete Foundation">
							<img src="{$include_path}/images/logo_arete_foundation.jpg" alt="Arete Foundation" style="max-width:100%"/>
						</a>

						<p>In November 2020, the <a href="http://www.bigdatabase.com/Big-DB/USFoundation-profiles/ARETE%20FOUNDATION-236779271.HTML">Arete
								Foundation</a> awarded RRDP $115,200 to complete the first phase of the project.</p>
					</div>
				</xsl:if>

				<div class="col-md-4 data_options">
					<h3>Data Export</h3>
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
	</xsl:template>

</xsl:stylesheet>
