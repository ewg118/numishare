<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" version="2.0" exclude-result-prefixes="#all">
	<xsl:include href="header.xsl"/>
	<xsl:include href="footer.xsl"/>
	<xsl:include href="functions.xsl"/>

	<xsl:param name="pipeline"/>
	<xsl:param name="display_path"/>
	<xsl:param name="lang"/>

	<xsl:template match="/config">
		<html lang="en">
			<head>
				<title>
					<xsl:value-of select="title"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$display_path}images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link type="text/css" href="{$display_path}style.css" rel="stylesheet"/>
				<!-- index script -->
				<script type="text/javascript" src="{$display_path}javascript/get_features.js"/>
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
								<xsl:if test="features_enabled = true()">
									<div id="feature">
										<h3>Featured Object</h3>
									</div>
								</xsl:if>
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
		<div class="container-fluid" id="content">
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
									<img src="{$display_path}images/logo_ans.jpg" alt="ANS"/>
								</a>
								<a href="http://isaw.nyu.edu/" title="Institute for the Study of the Ancient World" style="margin:0 10px;">
									<img src="{$display_path}images/logo_isaw.jpg" alt="ISAW"/>
								</a>
								<a href="http://www.dainst.org/" title="Deutsches Archäologisches Institut" style="margin:0 10px;">
									<img src="{$display_path}images/logo_dai.png" alt="DAI"/>
								</a>
							</p>
						</div>
						<div class="col-md-6">
							<h3>Support</h3>
							<p>
								<a href="http://www.neh.gov/">
									<img src="{$display_path}images/neh_logo_horizontal_rgb.jpg" style="max-width:100%"/>
								</a>
							</p>
							<p>In May 2014, the National Endowment for the Humanities awarded OCRE $300,000 as part of the <a
									href="http://www.neh.gov/grants/preservation/humanities-collections-and-reference-resources">Humanities Collections and Reference Resources</a> program, to be
								dispersed over three years, to complete the project. <a href="http://numismatics.org/wikiuploads/NewsEvents/2014_0404_PR_major-grant-NEH-.pdf">Press release</a></p>
						</div>
					</div>
				</div>
				<div class="col-md-3">
					<div class="highlight">
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

					<div class="highlight data_options">
						<h3>Linked Data</h3>
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
								<img src="{$display_path}images/nomisma.png" title="nomisma VOiD" alt="nomisma VOiD"/>
							</a>
						</xsl:if>
					</div>
				</div>
			</div>

		</div>
	</xsl:template>

</xsl:stylesheet>
