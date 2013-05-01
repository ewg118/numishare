<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="http://code.google.com/p/numishare/" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:template name="header">
		
		<!-- if displaying a coin or artifact record, the path to the other sections should be {$display_path} ; otherwise nothing -->
		<div id="hd">
			<table style="width:100%">
				<tr>
					<td style="width:10%">
						<img src="{$display_path}images/uva-logo.jpg" alt="logo"/>
					</td>
					<td>
						<span class="banner_text">The University of Virginia Art Museum <br/>Numismatic Collection</span>
					</td>
					<td style="width:25%">
						<form action="{$display_path}results" method="GET" id="qs_form" style="padding:10px 0">
							<input type="text" name="q" id="qs_text"/>	
							<input id="qs_button" type="submit" value="{numishare:normalizeLabel('header_search', $lang)}"/>
						</form>
					</td>
				</tr>
			</table>
			<ul role="menubar" id="menu">
				<xsl:call-template name="menubar"/>
			</ul>
			<div id="log"/>
		</div>
	</xsl:template>
	
	<xsl:template name="menubar">
		<xsl:choose>
			<xsl:when test="$lang='ar'">
				<xsl:call-template name="languages"/>
				<xsl:for-each select="//config/pages/page[public = '1']">
					<li role="presentation">
						<a href="{$display_path}pages/{@stub}{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="short-title"/>
						</a>
					</li>
				</xsl:for-each>
				<xsl:if test="//config/pages/visualize/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}visualize{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_visualize', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/analyze/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}analyze{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_analyze', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/compare/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}compare{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_compare', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<li role="presentation">
					<a href="{$display_path}maps{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_maps', $lang)"/>
					</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}search{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_search', $lang)"/>
					</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}results?q=*:*{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_browse', $lang)"/>
					</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}.{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_home', $lang)"/>
					</a>
				</li>
			</xsl:when>
			<xsl:otherwise>
				<li role="presentation">
					<a href="{$display_path}.{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_home', $lang)"/>
					</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}results?q=*:*{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_browse', $lang)"/>
					</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}search{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_search', $lang)"/>
					</a>
				</li>
				<li role="presentation">
					<a href="{$display_path}maps{if (string($lang)) then concat('?lang=', $lang) else ''}">
						<xsl:value-of select="numishare:normalizeLabel('header_maps', $lang)"/>
					</a>
				</li>
				<xsl:if test="//config/pages/compare/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}compare{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_compare', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/analyze/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}analyze{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_analyze', $lang)"/>
						</a>
					</li>
				</xsl:if>
				<xsl:if test="//config/pages/visualize/@enabled= true()">
					<li role="presentation">
						<a href="{$display_path}visualize{if (string($lang)) then concat('?lang=', $lang) else ''}">
							<xsl:value-of select="numishare:normalizeLabel('header_visualize', $lang)"/>
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
				<xsl:call-template name="languages"/>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	<xsl:template name="languages">
		<xsl:if test="count(//config/descendant::language[@enabled='true']) &gt; 1">
			<li role="presentation">
				<a href="#Language">
					<xsl:value-of select="numishare:normalizeLabel('header_language', $lang)"/>
				</a>
				<ul role="menu">
					<xsl:for-each select="//config/descendant::language[@enabled='true']">
						<xsl:sort select="@code"/>
						<li role="presentation">
							<a role="menuitem" href="?lang={@code}">
								<xsl:value-of select="numishare:normalizeLabel(concat('lang_', @code), $lang)"/>
							</a>
						</li>
					</xsl:for-each>
				</ul>
			</li>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>



