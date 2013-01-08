<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="http://code.google.com/p/numishare/" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:template name="header">

		<!-- if displaying a coin or artifact record, the path to the other sections should be {$display_path} ; otherwise nothing -->
		<div id="hd">
			<div class="banner align-right">
				<xsl:if test="string(/content/config/banner_text)">
					<div class="banner_text">
						<xsl:value-of select="/content/config/banner_text"/>
					</div>
				</xsl:if>
				<xsl:if test="string(//config/banner_image/@xlink:href)">
					<img src="{$display_path}images/{//config/banner_image/@xlink:href}" alt="banner image"/>
				</xsl:if>
			</div>
			<ul role="menubar" id="menu">
				<xsl:call-template name="menubar"/>
			</ul>
			<div id="log"/>
		</div>
	</xsl:template>

	<xsl:template name="menubar">
		<xsl:choose>
			<xsl:when test="$lang='ar'">
				<xsl:if test="count(//config/descendant::language[@enabled='true']) &gt; 1">
					<li role="presentation">
						<a href="#Language">
							<xsl:value-of select="numishare:headerLabel('language')"/>
						</a>
						<ul role="menu">
							<xsl:for-each select="//config/descendant::language[@enabled='true']">
								<li role="presentation">
									<a role="menuitem" href="?lang={@code}">
										<xsl:value-of select="if (string(label[@xml:lang=$lang])) then label[@xml:lang=$lang] else label[@xml:lang='en']"/>
									</a>
								</li>
							</xsl:for-each>
						</ul>
					</li>
				</xsl:if>
				<xsl:for-each select="//config/pages/page[public = '1']" >
					<li role="presentation">
						<a href="{$display_path}pages/{@stub}{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="short-title"/>
						</a>
					</li>
				</xsl:for-each>
				<xsl:if test="//config/pages/visualize/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}visualize{if (string($lang)) then concat('?ang=', $lang) else ''}">
							<xsl:value-of select="numishare:headerLabel('visualize')"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/analyze/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}analyze{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:headerLabel('analyze')"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/compare/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}compare{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:headerLabel('compare')"/>
						</a>
					</li>
				</xsl:if>
				<li role="presentation">
					<a href="{$display_path}maps{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:headerLabel('maps')"/>
					</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}search{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:headerLabel('search')"/>
					</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}results?q=*:*{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
						<xsl:value-of select="numishare:headerLabel('browse')"/>
					</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}.{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:headerLabel('home')"/>
					</a>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<li role="presentation">
					<a href="{$display_path}.{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:headerLabel('home')"/>
					</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}results?q=*:*{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
						<xsl:value-of select="numishare:headerLabel('browse')"/>
					</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}search{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:headerLabel('search')"/>
					</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}maps{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:headerLabel('maps')"/>
					</a>
				</li>
				<xsl:if test="//config/pages/compare/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}compare{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:headerLabel('compare')"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/analyze/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}analyze{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:headerLabel('analyze')"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/visualize/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}visualize{if (string($lang)) then concat('?ang=', $lang) else ''}">
							<xsl:value-of select="numishare:headerLabel('visualize')"/>
						</a>
					</li>
				</xsl:if>
				<xsl:for-each select="//config/pages/page[public = '1']">
					<li role="presentation">
						<a href="{$display_path}pages/{@stub}{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="short-title"/>
						</a>
					</li>
				</xsl:for-each>
				<!-- display the language switching menu when 2 or more languages are enabled -->
				<xsl:if test="count(//config/descendant::language[@enabled='true']) &gt; 1">
					<li role="presentation">
						<a href="#Language">
							<xsl:value-of select="numishare:headerLabel('language')"/>
						</a>
						<ul role="menu">
							<xsl:for-each select="//config/descendant::language[@enabled='true']">
								<li role="presentation">
									<a role="menuitem" href="?lang={@code}">
										<xsl:value-of select="if (string(label[@xml:lang=$lang])) then label[@xml:lang=$lang] else label[@xml:lang='en']"/>
									</a>
								</li>
							</xsl:for-each>
						</ul>
					</li>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	
	</xsl:template>

	<xsl:function name="numishare:headerLabel">
		<xsl:param name="label"/>
		<xsl:choose>
			<xsl:when test="$lang='ar'">
				<xsl:choose>
					<xsl:when test="$label='home'">المكان</xsl:when>
					<xsl:when test="$label='search'">البحث</xsl:when>
					<xsl:when test="$label='browse'">البحث بالتحديد</xsl:when>
					<xsl:when test="$label='maps'">الخرائط</xsl:when>
					<xsl:when test="$label='compare'">المقارنة</xsl:when>
					<xsl:when test="$label='language'">اللغة</xsl:when>
					<xsl:otherwise>No label</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$label='home'">Home</xsl:when>
					<xsl:when test="$label='search'">Search</xsl:when>
					<xsl:when test="$label='browse'">Browse</xsl:when>
					<xsl:when test="$label='maps'">Maps</xsl:when>
					<xsl:when test="$label='compare'">Compare</xsl:when>
					<xsl:when test="$label='analyze'">Analyze Hoards</xsl:when>
					<xsl:when test="$label='visualize'">Visualize Queries</xsl:when>
					<xsl:when test="$label='language'">Language</xsl:when>
					<xsl:otherwise>No label</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>
