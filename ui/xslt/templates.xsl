<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:template name="header">
		<div class="navbar navbar-default navbar-static-top" role="navigation">
			<xsl:if test="$lang='ar'">
				<xsl:attribute name="style">direction: rtl;</xsl:attribute>
			</xsl:if>
			<div class="container-fluid">
				<div class="navbar-header">
					<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
						<span class="sr-only">Toggle navigation</span>
						<span class="icon-bar"/>
						<span class="icon-bar"/>
						<span class="icon-bar"/>
					</button>
					<a class="navbar-brand" href="{//config/url}{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
						<xsl:choose>
							<xsl:when test="string-length(//config/logo) &gt; 0">
								<xsl:choose>
									<xsl:when test="contains(//config/logo, 'http://')">
										<img src="{//config/logo}"/>
									</xsl:when>
									<xsl:otherwise>
										<img src="{$include_path}/images/{//config/logo}"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="//config/title"/>
							</xsl:otherwise>
						</xsl:choose>
					</a>
				</div>
				<div class="navbar-collapse collapse">
					<xsl:if test="not($lang='ar')">
						<ul class="nav navbar-nav">
							<xsl:call-template name="menubar"/>
						</ul>
					</xsl:if>
					<div class="col-sm-3 col-md-3 pull-{if ($lang='ar') then 'left' else 'right'}">
						<form class="navbar-form" role="search" action="{$display_path}results" method="get">
							<div class="input-group">
								<input type="text" class="form-control" placeholder="{numishare:normalizeLabel('header_search', $lang)}" name="q" id="srch-term"/>
								<div class="input-group-btn">
									<button class="btn btn-default" type="submit">
										<i class="glyphicon glyphicon-search"/>
									</button>
								</div>
							</div>
						</form>
					</div>
					<xsl:if test="$lang='ar'">
						<ul class="nav navbar-nav navbar-right">
							<xsl:call-template name="menubar"/>
						</ul>
					</xsl:if>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="menubar">
		<xsl:choose>
			<xsl:when test="$lang='ar'">
				<xsl:call-template name="languages"/>
				<xsl:for-each select="//config/pages/page[@public = '1']">
					<xsl:sort select="position()" order="descending"/>
					<xsl:variable name="stub" select="@stub"/>

					<li>
						<a href="{$display_path}pages/{@stub}{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
							<xsl:choose>
								<xsl:when test="content[@lang=$lang]">
									<xsl:value-of select="content[@lang=$lang]/short-title"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="content[@lang='en']">
											<xsl:value-of select="content[@lang='en']/short-title"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="short-title"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</li>
				</xsl:for-each>
				<xsl:if test="not(//config/pages/apis/@enabled=false())">
					<li>
						<a href="{$display_path}apis{if (string($langParam)) then concat('?lang=', $langParam) else ''}">APIs</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/visualize/@enabled= true()">
					<li>
						<a href="{$display_path}visualize{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_visualize', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/analyze/@enabled= true()">
					<li>
						<a href="{$display_path}analyze{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_analyze', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/compare/@enabled= true()">
					<li>
						<a href="{$display_path}compare{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_compare', $lang)"/>
						</a>
					</li>
				</xsl:if>				
				<xsl:if test="//config/collection-type= 'cointype'">
					<li>
						<a href="{$display_path}contributors{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_contributors', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/identify/@enabled= true()">
					<li>
						<a href="{$display_path}identify{if (string($langParam)) then concat('?lang=', $langParam) else ''}">Identify a Coin</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/symbols/@enabled=true()">
					<li>
						<a href="{$display_path}symbols{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_symbols', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<li>
					<a href="{$display_path}maps{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_maps', $lang)"/>
					</a>
				</li>
				<li>
					<a href="{$display_path}search{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_search', $lang)"/>
					</a>
				</li>
				<li>
					<a href="{$display_path}results{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_browse', $lang)"/>
					</a>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<li>
					<a href="{$display_path}results{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_browse', $lang)"/>
					</a>
				</li>
				<li>
					<a href="{$display_path}search{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_search', $lang)"/>
					</a>
				</li>
				<li>
					<a href="{$display_path}maps{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_maps', $lang)"/>
					</a>
				</li>
				<xsl:if test="//config/pages/symbols/@enabled=true()">
					<li>
						<a href="{$display_path}symbols{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_symbols', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/identify/@enabled= true()">
					<li>
						<a href="{$display_path}identify{if (string($langParam)) then concat('?lang=', $langParam) else ''}">Identify a Coin</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/collection_type= 'cointype' and string(//config/sparql_endpoint)">
					<li>
						<a href="{$display_path}contributors{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_contributors', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/compare/@enabled= true()">
					<li>
						<a href="{$display_path}compare{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_compare', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/analyze/@enabled= true()">
					<li>
						<a href="{$display_path}analyze{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_analyze', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/visualize/@enabled= true()">
					<li>
						<a href="{$display_path}visualize{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_visualize', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="not(//config/pages/apis/@enabled=false())">
					<li>
						<a href="{$display_path}apis{if (string($langParam)) then concat('?lang=', $langParam) else ''}">APIs</a>
					</li>
				</xsl:if>
				<xsl:for-each select="//config/pages/page[@public='1']">
					<xsl:variable name="stub" select="@stub"/>

					<li>
						<a href="{$display_path}pages/{@stub}{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
							<xsl:choose>
								<!-- if there is a generic header label, e.g., about page in the normalizeLabel function -->
								<xsl:when test="not(substring(numishare:normalizeLabel(concat('header_', @stub), $lang), 1, 1) = '[')">
									<xsl:value-of select="numishare:normalizeLabel(concat('header_', @stub), $lang)"/>
								</xsl:when>
								<xsl:when test="content[@lang=$lang]">
									<xsl:value-of select="content[@lang=$lang]/short-title"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="content[@lang='en']">
											<xsl:value-of select="content[@lang='en']/short-title"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="short-title"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</li>
				</xsl:for-each>
				<!-- navbar addendum -->
				<xsl:copy-of select="//config/header/li"/>
				<!-- display the language switching menu when 2 or more languages are enabled -->
				<xsl:call-template name="languages"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="languages">
		<xsl:variable name="page" select="substring-after(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
		<xsl:variable name="query" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>

		<xsl:if test="count(//config/descendant::language[@enabled='true']) &gt; 1">
			<li class="dropdown">
				<a href="#" class="dropdown-toggle" data-toggle="dropdown">
					<xsl:value-of select="numishare:normalizeLabel('header_language', $lang)"/>
					<b class="caret"/>
				</a>
				<ul class="dropdown-menu">
					<xsl:for-each select="//config/descendant::language[@enabled='true']">
						<xsl:sort select="@code"/>
						<li>
							<xsl:choose>
								<xsl:when test="string-length($page) = 0">
									<a href="{//config/url}?lang={@code}">
										<xsl:value-of select="numishare:normalizeLabel(concat('lang_', @code), $lang)"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a href="{$display_path}{$page}?lang={@code}{if (string-length($query) &gt; 0) then concat('&amp;q=', $query) else ''}">
										<xsl:value-of select="numishare:normalizeLabel(concat('lang_', @code), $lang)"/>
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</li>
					</xsl:for-each>
				</ul>
			</li>
		</xsl:if>
	</xsl:template>

	<xsl:template name="footer">
		<div id="footer" class="container-fluid">
			<xsl:copy-of select="//config/footer/*"/>
		</div>
	</xsl:template>
</xsl:stylesheet>
