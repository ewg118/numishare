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
		<div class="jumbotron">
			<div class="container">
				<div class="row">
					<div class="col-md-12">
						<h1>
							<xsl:value-of select="title"/>
						</h1>
						<p>
							<xsl:value-of select="description"/>
						</p>
					</div>
				</div>
			</div>
		</div>
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-3">
					<div class="highlight">
						<h3>Sidebar Navigation</h3>
					</div>					
				</div>
				<div class="col-md-6">
					<!-- index -->
					<p>The ANS collections database contains information on more than 600,000 objects in the Society’s collections. These include, coins, paper money, tokens, ‘primitive’ money, medals and decorations, from all parts of the world, and all periods in which such objects have been produced. </p>
					<p>
						<b>Click an image below to search a department.</b>
					</p>
					<div class="row text-center">
						<div class="col-md-3">
							<a href="department/Greek">
								<img title="Greek" alt="Greek" src="{$include_path}/images/greek.jpg"/><br/>Greek</a>
						</div>
						<div class="col-md-3">
							<a href="department/Roman"><img title="Roman" alt="Roman" src="{$include_path}/images/roman.jpg"/><br/>Roman</a>
						</div>
						<div class="col-md-3">
							<a href="department/Byzantine"><img title="Byzantine" alt="Byzantine" src="{$include_path}/images/byzantine.jpg"/><br/>Byzantine</a>
						</div>
						<div class="col-md-3">
							<a href="department/Islamic"><img title="Islamic" alt="Islamic" src="{$include_path}/images/islamic.jpg"/><br/>Islamic</a>
						</div>
						<div class="col-md-3">
							<a href="department/EastAsian"><img title="East Asian" alt="East Asian" src="{$include_path}/images/east_asian.jpg"/><br/>East Asian</a>
						</div>
						<div class="col-md-3">
							<a href="department/SouthAsian"><img title="South Asian" alt="South Asian" src="{$include_path}/images/south_asian.jpg"/><br/>South Asian</a>
						</div>
						<div class="col-md-3">
							<a href="department/Medieval"><img title="Medieval" alt="Medieval" src="{$include_path}/images/medieval.jpg"/><br/>Medieval</a>
						</div>
						<div class="col-md-3">
							<a href="department/Modern"><img title="Modern" alt="Modern" src="{$include_path}/images/modern.jpg"/><br/>Modern</a>
						</div>
						<div class="col-md-3">
							<a href="department/UnitedStates"><img title="United States" alt="United States" src="{$include_path}/images/united_states.jpg"/><br/>United States</a>
						</div>
						<div class="col-md-3">
							<a href="department/LatinAmerica"><img title="Latin American" alt="Latin American" src="{$include_path}/images/latin_american.jpg"/><br/>Latin American</a>
						</div>
						<div class="col-md-3">
							<a href="department/MedalsAndDecorations"><img title="Medals And Decorations" alt="Medals And Decorations" src="{$include_path}/images/medal.jpg"/><br/>Medals And
								Decorations</a>
						</div>
					</div>
					<p>ANS policies on the acquisition and deacquisition of numismatic items are available <a class="wikilink" href="/About/AcquisitionDeacquisition">online</a>. </p>
				</div>
				<div class="col-md-3">
					<div class="highlight">
						<xsl:copy-of select="/content/div[@id='feature']"/>
					</div>
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
