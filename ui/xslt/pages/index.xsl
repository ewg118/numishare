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
			<xsl:when test="//config/uri_space">
				<xsl:value-of select="//config/uri_space"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(//config/url, 'id/')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="//config">
		<html lang="en">
			<head>
				<title>
					<xsl:value-of select="title"/>
				</title>
				<link rel="shortcut icon" type="image/x-icon" href="{$include_path}/images/favicon.png"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"/>
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
		<!--<img src="{$include_path}/images/jumbotron.jpg" style="width:100%;border-bottom:4px solid black; margin-bottom:15px;"/>-->
		<div class="jumbotron visible-xs visible-sm  visible-md">
			<div class="container">
				<div class="row">
					<div class="col-md-4 text-center">
						<img src="{$include_path}/images/ans_large.png" alt="logo" style="max-height:150px;"/>
					</div>
					<div class="col-md-8">
						<h1>MANTIS</h1>
						<h3>A Numismatic Technologies Integration Service</h3>
					</div>
				</div>
			</div>
		</div>
		<div class="container-fluid banner hidden-xs hidden-sm hidden-md">			
			<div class="row">
				<div class="col-md-6 col-md-offset-6">
					<div class="row banner-background">
						<div class="col-lg-4 col-md-12 text-center">
							<img src="{$include_path}/images/ans_large.png" alt="logo"/>
						</div>
						<div class="col-lg-8 col-md-12">
							<h1>MANTIS</h1>
							<h3>A Numismatic Technologies Integration Service</h3>
						</div>
					</div>					
				</div>
			</div>
		</div>
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-3 col-lg-2 hidden-xs hidden-sm">
					<div class="highlight">
						<h3>Navigation</h3>
						<xsl:call-template name="navigation"/>
					</div>
				</div>
				<div class="col-md-6 col-lg-7 col-sm-9">
					<!-- index -->
					<!--<h2>
						<xsl:value-of select="description"/>
					</h2>-->
					<p>The ANS collections database contains information on more than 600,000 objects in the Society’s collections. These include coins, paper money, tokens, ‘primitive’ money, medals
						and decorations, from all parts of the world, and all periods in which such objects have been produced. </p>
					<p>Use the menu at the top of the page to navigate the site or click on the links below for customized departmental search pages.</p>
					<h3>Departments <small><a href="{$display_path}results?q=*:*">Browse All</a></small></h3>
					<div class="row text-center" id="departments">
						<div class="col-sm-6 col-lg-3">
							<a href="department/Greek">
								<img title="Greek" alt="Greek" src="{$include_path}/images/greek.jpg"/><br/>Greek</a>
						</div>
						<div class="col-sm-6 col-lg-3">
							<a href="department/Roman"><img title="Roman" alt="Roman" src="{$include_path}/images/roman.jpg"/><br/>Roman</a>
						</div>
						<div class="col-sm-6 col-lg-3">
							<a href="department/Byzantine"><img title="Byzantine" alt="Byzantine" src="{$include_path}/images/byzantine.jpg"/><br/>Byzantine</a>
						</div>
						<div class="col-sm-6 col-lg-3">
							<a href="department/Islamic"><img title="Islamic" alt="Islamic" src="{$include_path}/images/islamic.jpg"/><br/>Islamic</a>
						</div>
						<div class="col-sm-6 col-lg-3">
							<a href="department/EastAsian"><img title="East Asian" alt="East Asian" src="{$include_path}/images/east_asian.jpg"/><br/>East Asian</a>
						</div>
						<div class="col-sm-6 col-lg-3">
							<a href="department/SouthAsian"><img title="South Asian" alt="South Asian" src="{$include_path}/images/south_asian.jpg"/><br/>South Asian</a>
						</div>
						<div class="col-sm-6 col-lg-3">
							<a href="department/Medieval"><img title="Medieval" alt="Medieval" src="{$include_path}/images/medieval.jpg"/><br/>Medieval</a>
						</div>
						<div class="col-sm-6 col-lg-3">
							<a href="department/Modern"><img title="Modern" alt="Modern" src="{$include_path}/images/modern.jpg"/><br/>Modern</a>
						</div>
						<div class="col-sm-6 col-lg-3">
							<a href="department/UnitedStates"><img title="United States" alt="United States" src="{$include_path}/images/united_states.jpg"/><br/>United States</a>
						</div>
						<div class="col-sm-6 col-lg-3">
							<a href="department/LatinAmerican"><img title="Latin American" alt="Latin American" src="{$include_path}/images/latin_american.jpg"/><br/>Latin American</a>
						</div>
						<div class="col-sm-6 col-lg-3">
							<a href="department/MedalsAndDecorations"><img title="Medals And Decorations" alt="Medals And Decorations" src="{$include_path}/images/medal.jpg"/><br/>Medals And
								Decorations</a>
						</div>
					</div>
					<p>ANS policies on the acquisition and deacquisition of numismatic items are available <a href="http://numismatics.org/About/AcquisitionDeacquisition">online</a>. </p>
				</div>
				<div class="col-md-3 col-lg-3 col-sm-3">
					<div id="feature" class="highlight text-center">
						<xsl:apply-templates select="doc('input:feature-model')//doc"/>
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

	<xsl:template name="navigation">
		<ul class="navigation-ul">
			<li>
				<a href="http://numismatics.org/">Home</a>
			</li>
			<li>
				<a href="http://numismatics.org/About/About">About the ANS</a>
			</li>
			<li>
				<a href="http://numismatics.org/search/">Collections</a>
				<ul>
					<li>
						<a href="http://numismatics.org/Collections/RecentAcquisitions">Recent Acquisitions</a>
					</li>
					<li>
						<a href="http://numismatics.org/Collections/Photography">Photography</a>
					</li>
					<li>
						<i>Departments</i>
						<ul>
							<li>
								<a href="http://numismatics.org/Collections/Greek">Greek</a>
							</li>
							<li>
								<a href="http://numismatics.org/Collections/Roman">Roman</a>
							</li>
							<li>
								<a href="http://numismatics.org/Collections/Byzantine">Byzantine</a>
							</li>
							<li>
								<a href="http://numismatics.org/Collections/Islamic">Islamic</a>
							</li>
							<li>
								<a href="http://numismatics.org/Collections/EastAsian">East Asian</a>
							</li>
							<li>
								<a href="http://numismatics.org/Collections/SouthAsian">South Asian</a>
							</li>
							<li>
								<a href="http://numismatics.org/Collections/Medieval">Medieval</a>
							</li>
							<li>
								<a href="http://numismatics.org/Collections/UnitedStates">United States</a>
							</li>
							<li>
								<a href="http://numismatics.org/Collections/LatinAmerica">Latin America</a>
							</li>
							<li>
								<a href="http://numismatics.org/Collections/Modern">Modern</a>
							</li>
							<li>
								<a href="http://numismatics.org/Collections/MedalsAndDecorations">Medals and Decorations</a>
							</li>
						</ul>
					</li>
				</ul>
			</li>
			<li>
				<a href="http://numismatics.org/Library/Library">Library</a>
			</li>
			<li>
				<a href="http://numismatics.org/archives/">Archives</a>
			</li>
			<li>
				<a href="http://numismatics.org/Publications/Publications">Publications</a>
			</li>
			<li>
				<a href="http://numismatics.org/Membership/Membership">Membership</a>
			</li>
			<li>
				<a href="http://numismatics.org/EventsExhibitions/EventsExhibitions">Events and Exhibitions</a>
			</li>
			<li>
				<a href="http://numismatics.org/Education/Education">Education</a>
			</li>
			<li>
				<a href="http://numismatics.org/resources">Online Resources</a>
			</li>
			<li>
				<a href="http://numismatics.org/Development/Development">Support the ANS</a>
			</li>
			<li>
				<a href="http://numismatics.org/About/Contact">Contact</a>
			</li>
			<li>
				<a target="_blank" href="http://ansmagazine.com" title="" rel="nofollow">ANS Magazine</a>
			</li>
			<li>
				<a target="_blank" href="http://numismatics.org/Store/Store">The ANS Store</a>
			</li>
		</ul>
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
