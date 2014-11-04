<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:template name="header">
		<div class="navbar navbar-default navbar-static-top" role="navigation">
			<div class="container-fluid">
				<div class="navbar-header">					
					<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
						<span class="sr-only">Toggle navigation</span>
						<span class="icon-bar"/>
						<span class="icon-bar"/>
						<span class="icon-bar"/>
					</button>
					<a class="navbar-brand" href="{$display_path}./">
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
								<xsl:if test="$lang='ar'">
									<div class="input-group-btn">
										<button class="btn btn-default" type="submit">
											<i class="glyphicon glyphicon-search"/>
										</button>
									</div>
								</xsl:if>
								<input type="text" class="form-control" placeholder="{numishare:normalizeLabel('header_search', $lang)}" name="q" id="srch-term"/>
								<xsl:if test="not($lang='ar')">
									<div class="input-group-btn">
										<button class="btn btn-default" type="submit">
											<i class="glyphicon glyphicon-search"/>
										</button>
									</div>
								</xsl:if>
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
				<xsl:for-each select="//config/pages/page[public = '1']">
					<li>
						<a href="{$display_path}pages/{@stub}{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="short-title"/>
						</a>
					</li>
				</xsl:for-each>
				<li>
					<a href="{$display_path}apis{if (string($lang)) then concat('?lang=', $lang) else ''}">APIs</a>
				</li>
				<xsl:if test="//config/pages/visualize/@enabled= true()">
					<li>
						<a href="{$display_path}visualize{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_visualize', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/analyze/@enabled= true()">
					<li>
						<a href="{$display_path}analyze{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_analyze', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/compare/@enabled= true()">
					<li>
						<a href="{$display_path}compare{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_compare', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/collection-type= 'cointype'">
					<li>
						<a href="{$display_path}contributors{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_contributors', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<li>
					<a href="{$display_path}maps{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_maps', $lang)"/>
					</a>
				</li>
				<li>
					<a href="{$display_path}search{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_search', $lang)"/>
					</a>
				</li>
				<li>
					<a href="{$display_path}results?q=*:*{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_browse', $lang)"/>
					</a>
				</li>				
			</xsl:when>
			<xsl:otherwise>				
				<li>
					<a href="{$display_path}results?q=*:*{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_browse', $lang)"/>
					</a>
				</li>
				<li>
					<a href="{$display_path}search{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_search', $lang)"/>
					</a>
				</li>
				<li>
					<a href="{$display_path}maps{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_maps', $lang)"/>
					</a>
				</li>
				<xsl:if test="//config/collection_type= 'cointype' and string(//config/sparql_endpoint)">
					<li>
						<a href="{$display_path}contributors{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_contributors', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/compare/@enabled= true()">
					<li>
						<a href="{$display_path}compare{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_compare', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/analyze/@enabled= true()">
					<li>
						<a href="{$display_path}analyze{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_analyze', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/visualize/@enabled= true()">
					<li>
						<a href="{$display_path}visualize{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_visualize', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<li>
					<a href="{$display_path}apis{if (string($lang)) then concat('?lang=', $lang) else ''}">APIs</a>
				</li>
				<xsl:for-each select="//config/pages/page[public = '1']">
					<li>
						<a href="{$display_path}pages/{@stub}{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="short-title"/>
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
		<xsl:if test="count(//config/descendant::language[@enabled='true']) &gt; 1">
			<li class="dropdown">
				<a href="#" class="dropdown-toggle" data-toggle="dropdown">Language <b class="caret"/></a>
				<ul class="dropdown-menu">
					<xsl:for-each select="//config/descendant::language[@enabled='true']">
						<xsl:sort select="@code"/>
						<li>
							<xsl:choose>
								<xsl:when test="string-length(substring-after(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')) = 0">
									<a href="{//config/url}?lang={@code}">
										<xsl:value-of select="numishare:normalizeLabel(concat('lang_', @code), $lang)"/>
									</a>
								</xsl:when> 
								<xsl:otherwise>
									<a href="{$display_path}{substring-after(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')}?lang={@code}">
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