<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs cinclude"
	version="2.0">

	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>

	<xsl:param name="q"/>
	<xsl:param name="solr-url"/>
	<xsl:param name="section"/>
	<xsl:param name="prefix"/>
	<xsl:param name="fq"/>
	<xsl:param name="link"/>
	<xsl:param name="mode"/>

	<xsl:template match="/">
		<xsl:apply-templates select="//lst[@name='category_facet']"/>
	</xsl:template>

	<xsl:template match="lst[@name='category_facet']">
		<xsl:if test="$mode='maps'">
			<li>
				<div class="ui-widget-header ui-corner-all ui-helper-clearfix">
					<span style="float:right" class="close_facets" id="{$category}-close">
						<span class="ui-icon ui-icon-circle-close"/>
					</span>
				</div>
			</li>
		</xsl:if>
		<xsl:for-each select="int[starts-with(@name, $prefix)]">			
			<xsl:variable name="next-level" select="number(substring-after($prefix, 'L')) + 1"/>
			<xsl:variable name="next-prefix" select="concat('L', $next-level)"/>
			
			<xsl:variable name="next-prefix-count">
				<xsl:value-of
					select="count(document(concat($solr-url, 'select?q=', encode-for-uri($q), '&amp;rows=', 0, '&amp;facet.field=category_facet&amp;fq=category_facet:&#x022;', encode-for-uri(@name), '&#x022;&amp;facet.prefix=', $next-prefix))//lst[@name='facet_fields']/lst[@name='category_facet']/int)"
				/>
			</xsl:variable>
			<li class="term">
				
				<xsl:if test="$next-prefix-count &gt; 0">
					<xsl:variable name="starter-space" select="if(contains(@name, 'L1|')) then '' else ' '"/>
					<span class="expand_category" id="{replace(@name, ' ', '_')}__category" section="{$section}" q="{$q}" next-prefix="{$next-prefix}"
						link="{concat($link, $starter-space, '+&#x022;', @name, '&#x022;')}">
						<img src="images/{if (contains($q, @name)) then 'minus' else 'plus'}.gif" alt="expand"/>
					</span>
				</xsl:if>
				<xsl:choose>
					<!-- make a clickable link for search/gallery results if the section is search -->
					<xsl:when test="$section = 'search'">
						<xsl:variable name="new_query">
							<xsl:choose>
								<xsl:when test="contains($q, 'category_facet:')">
									<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>
									<xsl:for-each select="$tokenized_q[not(contains(., 'category_facet'))]">
										<xsl:value-of select="."/>
										<xsl:if test="position() != last()">
											<xsl:text> AND </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$q"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="contains($q, @name)">
								<b>
									<xsl:value-of select="substring-after(@name, '|')"/>
								</b>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$mode='maps'">
										<span class="category_term" href="?q=category_facet:({$link} +&#x022;{@name}&#x022;)">
											<xsl:value-of select="substring-after(@name, '|')"/>
										</span>
									</xsl:when>
									<xsl:otherwise>
										<a href="?q={encode-for-uri($new_query)} AND category_facet:({$link} +&#x022;{@name}&#x022;)">
											<xsl:value-of select="substring-after(@name, '|')"/>
										</a>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<!-- include checkboxes for collection -->
					<xsl:when test="$section = 'collection'">
						<xsl:choose>
							<xsl:when test="contains($q, @name)">
								<input type="checkbox" value="{@name}" checked="checked"/>
							</xsl:when>
							<xsl:otherwise>
								<input type="checkbox" value="{@name}"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="substring-after(@name, '|')"/>
					</xsl:when>
				</xsl:choose>
				
				<xsl:if test="$next-prefix-count &gt; 0">
					<xsl:choose>
						<xsl:when test="contains($q, @name)">
							<xsl:variable name="starter-space" select="if(contains(@name, 'L1|')) then '' else ' '"/>
							<ul class="category_level" id="{substring-after(replace(@name, ' ', '_'), '|')}__list">
								<!--<a href="get_categories?q={$q}&amp;fq={@name}&amp;prefix={$next-prefix}&amp;link={concat($link, $starter-space, '+&#x022;', @name, '&#x022;')}&amp;section={$section}">test</a>-->
								<cinclude:include
									src="cocoon:/get_categories?q={$q}&amp;fq={@name}&amp;prefix={$next-prefix}&amp;link={concat($link, $starter-space, '+&#x022;', @name, '&#x022;')}&amp;section={$section}"
								/>
							</ul>
						</xsl:when>
						<xsl:otherwise>
							<ul class="category_level" id="{substring-after(replace(@name, ' ', '_'), '|')}__list" style="display:none"/>
						</xsl:otherwise>
					</xsl:choose>
					
				</xsl:if>
			</li>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
