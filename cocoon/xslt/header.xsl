<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="#all" version="2.0">
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
				<li role="presentation">
					<a href="{$display_path}.">Home</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}results?q=*:*">Browse</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}search">Search</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}maps">Maps</a>
				</li>
				<xsl:if test="//config/pages/compare/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}compare">Compare</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/analyze/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}analyze">Analyze Hoards</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/visualize/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}visualize">Visualize Queries</a>
					</li>
				</xsl:if>
				<xsl:for-each select="//config/pages/page[public = '1']">
					<li role="presentation">
						<a href="{$display_path}pages/{@stub}">
							<xsl:value-of select="short-title"/>
						</a>
					</li>
				</xsl:for-each>
				<!-- display the language switching menu when 2 or more languages are enabled -->
				<xsl:if test="count(//config/descendant::language[@enabled='true']) &gt; 1">
					<li role="presentation">
						<a href="#Language">Language</a>
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

			</ul>

			<div id="log"/>
		</div>


	</xsl:template>
</xsl:stylesheet>
