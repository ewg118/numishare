<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare"
	xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="#all" version="2.0">
	<xsl:template name="header">
		<div class="navbar navbar-default navbar-static-top" role="navigation">
			<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
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
									<xsl:when test="matches(//config/logo, 'https?://')">
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
					<xsl:if test="not(//config/languages/language[@code = $lang]/@rtl = true())">
						<ul class="nav navbar-nav">
							<xsl:call-template name="menubar"/>
						</ul>
					</xsl:if>
					<div class="col-sm-3 col-md-3 pull-{if (//config/languages/language[@code = $lang]/@rtl = true()) then 'left' else 'right'}">
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
					<xsl:if test="//config/languages/language[@code = $lang]/@rtl = true()">
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
			<xsl:when test="//config/languages/language[@code = $lang]/@rtl = true()">
				<xsl:apply-templates select="//config/navigation/tab" mode="nav">
					<xsl:sort order="descending" select="position()"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="//config/navigation/tab" mode="nav"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tab" mode="nav">
		<xsl:choose>
			<xsl:when test="@id = 'analyze' or @id = 'compare' or @id = 'apis' or @id = 'identify' or @id = 'symbols' or @id = 'feedback'">
				<xsl:variable name="id" select="@id"/>
				<xsl:variable name="href"
					select="
						concat($display_path, @href, if (string($langParam)) then
							concat('?lang=', $langParam)
						else
							'')"/>

				<!-- only display tabs if the page has been activated in the config -->
				<xsl:if test="//config/pages/*[name() = $id]/@enabled = true()">
					<li>
						<a href="{$href}">
							<xsl:choose>
								<xsl:when test="@label">
									<xsl:value-of select="@label"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="numishare:normalizeLabel(concat('header_', @id), $lang)"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</li>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@id = 'visualize'">
				<xsl:variable name="id" select="@id"/>

				<xsl:if test="//config/pages/*[name() = $id]/@enabled = true()">
					<!-- conditional for drop-down versus single link -->
					<xsl:choose>
						<xsl:when test="//config/collection_type = 'cointype' and matches(//config/sparql_endpoint, '^https?://')">
							<li class="dropdown">
								<a href="#" class="dropdown-toggle" data-toggle="dropdown">
									<xsl:value-of select="numishare:normalizeLabel(concat('header_', @id), $lang)"/>
									<xsl:text> </xsl:text>
									<b class="caret"/>
								</a>
								<ul class="dropdown-menu">
									<li>
										<a
											href="{$display_path}visualize/distribution{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
											<xsl:value-of select="numishare:normalizeLabel('visualize_typological', $lang)"/>
										</a>
									</li>
									<li>
										<a href="{$display_path}visualize/metrical{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
											<xsl:value-of select="numishare:normalizeLabel('visualize_measurement', $lang)"/>											
										</a>
									</li>
								</ul>
							</li>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="href"
								select="
									concat($display_path, @href, if (string($langParam)) then
										concat('?lang=', $langParam)
									else
										'')"/>
							<li>
								<a href="{$href}">
									<xsl:choose>
										<xsl:when test="@label">
											<xsl:value-of select="@label"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="numishare:normalizeLabel(concat('header_', @id), $lang)"/>
										</xsl:otherwise>
									</xsl:choose>
								</a>
							</li>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@id = 'contributors'">
				<xsl:if test="//config/collection_type = 'cointype' and string(//config/sparql_endpoint)">
					<xsl:variable name="href"
						select="
							concat($display_path, @href, if (string($langParam)) then
								concat('?lang=', $langParam)
							else
								'')"/>
					<li>
						<a href="{$href}">
							<xsl:value-of
								select="
									if (@label) then
										@label
									else
										numishare:normalizeLabel(concat('header_', @id), $lang)"
							/>
						</a>
					</li>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@id = 'pages'">
				<xsl:call-template name="pages"/>
			</xsl:when>
			<xsl:when test="@id = 'languages-tab'">
				<xsl:call-template name="languages"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="href">
					<xsl:choose>
						<xsl:when test="child::tab">#</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="
									concat($display_path, @href, if (string($langParam)) then
										concat('?lang=', $langParam)
									else
										'')"
							/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<li>
					<xsl:if test="child::tab">
						<xsl:attribute name="class">dropdown</xsl:attribute>
					</xsl:if>
					<a href="{$href}">
						<xsl:if test="child::tab">
							<xsl:attribute name="class">dropdown-toggle</xsl:attribute>
							<xsl:attribute name="data-toggle">dropdown</xsl:attribute>
						</xsl:if>
						<xsl:value-of
							select="
								if (@label) then
									@label
								else
									numishare:normalizeLabel(concat('header_', @id), $lang)"/>
						<xsl:if test="child::tab">
							<b class="caret"/>
						</xsl:if>
					</a>
					<xsl:if test="child::tab">
						<ul class="dropdown-menu">
							<xsl:apply-templates select="tab" mode="nav"/>
						</ul>
					</xsl:if>
				</li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="pages">
		<xsl:for-each select="//config/pages/page[@public = '1']">
			<xsl:variable name="stub" select="@stub"/>

			<li>
				<a href="{$display_path}pages/{@stub}{if (string($langParam)) then concat('?lang=', $langParam) else ''}">
					<xsl:choose>
						<!-- if there is a generic header label, e.g., about page in the normalizeLabel function -->
						<xsl:when test="not(substring(numishare:normalizeLabel(concat('header_', @stub), $lang), 1, 1) = '[')">
							<xsl:value-of select="numishare:normalizeLabel(concat('header_', @stub), $lang)"/>
						</xsl:when>
						<xsl:when test="content[@lang = $lang]">
							<xsl:value-of select="content[@lang = $lang]/short-title"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="content[@lang = 'en']">
									<xsl:value-of select="content[@lang = 'en']/short-title"/>
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
	</xsl:template>

	<xsl:template name="languages">
		<xsl:variable name="collection-name" select="substring-after(substring-after(doc('input:request')/request/request-uri, 'numishare/'), '/')"/>
		<xsl:variable name="query" select="doc('input:request')/request/parameters/parameter[name = 'q']/value"/>

		<xsl:if test="count(//config/descendant::language[@enabled = 'true']) &gt; 1">
			<li class="dropdown">
				<a href="#" class="dropdown-toggle" data-toggle="dropdown">
					<xsl:value-of select="numishare:normalizeLabel('header_language', $lang)"/>
					<b class="caret"/>
				</a>
				<ul class="dropdown-menu">
					<xsl:for-each select="//config/descendant::language[@enabled = 'true']">
						<xsl:sort select="@code"/>
						<li>
							<xsl:choose>
								<xsl:when test="string-length($collection-name) = 0">
									<a href="{//config/url}?lang={@code}">
										<xsl:value-of select="numishare:normalizeLabel(concat('lang_', @code), $lang)"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<a href="{$display_path}{$collection-name}?lang={@code}{if (string-length($query) &gt; 0) then concat('&amp;q=', $query) else ''}">
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
