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

				<xsl:if
					test="$collection-name = 'pella' or $collection-name = 'sco' or $collection-name = 'pco' or $collection-name = 'hrc' or $collection-name = 'igch' or $collection-name = 'agco' or $collection-name = 'bigr'">
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
		<div class="container-fluid index">
			<xsl:if test="$lang = 'ar'">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			<div class="row">
				<div class="col-md-12">
					<xsl:choose>
						<xsl:when
							test="$collection-name = 'pella' or $collection-name = 'sco' or $collection-name = 'pco' or $collection-name = 'hrc' or $collection-name = 'igch' or $collection-name = 'agco' or $collection-name = 'bigr'">
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
					<div class="highlight">
						<h3>Support</h3>
						
						<xsl:choose>
							<xsl:when test="$collection-name = 'bigr'">
								<div class="row">
									<div class="col-md-6">
										<a href="http://www.neh.gov/">
											<img src="{$include_path}/images/NEH-Preferred-Seal.svg" alt="NEH logo" style="max-width:100%"/>
										</a>	
									</div>
									<div class="col-md-6">
										<a href="https://www.ukri.org/councils/ahrc/">
											<img src="{$include_path}/images/Arts_and_Humanities_Research_Council_logo.svg" alt="AHRC logo" style="max-width:100%"/>
										</a>	
									</div>
									<div class="col-md-12">
										<br/>
										<p> The OXUS-INDUS project is funded by the <a href="https://www.neh.gov/divisions/odh/new-directions">New Directions in Digital
											Scholarship in Cultural Institutions</a> program that partners the U.S. National Endowment for the Humanities with the
											United Kingdom’s Arts and Humanities Research Council (AHRC). NEH grant number <a
												href="https://securegrants.neh.gov/publicquery/main.aspx?f=1&amp;gn=HC-278063-21">HC-278063-21</a>.</p>
									</div>
								</div>
								
							</xsl:when>
							<xsl:when test="$collection-name = 'lco'">
								<p>
									<a href="https://www.isf.org.il/">
										<img src="{$include_path}/images/ISF_logo.png" style="max-width:100%"/>
									</a>
								</p>
								<p>Small blurb about ISF grant.</p>								
							</xsl:when>
							<xsl:otherwise>
								<p>
									<a href="http://www.neh.gov/">
										<img src="{$include_path}/images/NEH-Preferred-Seal.svg" alt="NEH logo" style="max-width:100%"/>
									</a>
								</p>
								<p>In March 2017, the National Endowment for the Humanities awarded <xsl:value-of select="title"/> $262,000 as part of the the
									broader <a href="http://numismatics.org/neh-hrc2017/">Hellenistic Royal Coinages (HRC)</a> initiative. This grant is issued
									through the NEH <a href="http://www.neh.gov/grants/preservation/humanities-collections-and-reference-resources">Humanities
										Collections and Reference Resources</a> program, to be dispersed over three years, to complete the project.</p>
							</xsl:otherwise>
						</xsl:choose>
					</div>

					<xsl:choose>
						<xsl:when test="$collection-name = 'lco'">
							<div class="highlight">
							<h3>Collaborators</h3>
								<a href="https://numismatics.org/" title="American Numismatic Society">
									<img src="{$include_path}/images/american_numismatics_society.svg" alt="American Numismatic Society logo"/>
								</a>
								<a href="https://www.imj.org.il/" title="Israel Museum, Jerusalem">
									<img src="{$include_path}/images/IMJ_logo.jpg" alt="Israel Museum, Jerusalem logo"/>
								</a>
								<a href="https://www.iaa.org.il/" title="Israel Antiquities Authority">
									<img src="{$include_path}/images/Israel_Antiquities_Authority.png" alt="Israel Antiquities Authority logo"/>
								</a>
								<a href="http://www.ins.org.il/" title="Israel Numismatics Society">
									<img src="{$include_path}/images/ins_logo.png" alt="Israel Numismatic Society logo"/>
								</a>
								<a href="https://tau.ac.il/" title="Tel Aviv University">
									<img src="{$include_path}/images/TAU_logo.png" alt="Tel Aviv University logo"/>
								</a>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<div class="highlight">
								<h3>Get Involved</h3>
								<p> Please consider becoming a Member of the American Numismatic Society, the publisher of this resource. Your membership helps maintain
									our free and open digital projects and data, as well as other educational outreach activities that broaden public access to
									numismatics. Membership comes with other benefits, such as the ANS Magazine and weekly virtual lectures and discussions. See <a
										href="http://numismatics.org/membership/">Membership</a> for more information.</p>
							</div>
						</xsl:otherwise>
					</xsl:choose>

					
					<!--<div class="highlight">
						<h3>Collaborators</h3>
					</div>-->
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
