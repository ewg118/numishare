<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>

	<!-- globals -->
	<xsl:param name="solr-url"/>
	<xsl:param name="collection-name"/>

	<!-- solr query parameters -->
	<xsl:param name="q"/>
	<xsl:param name="field"/>
	<xsl:param name="prefix"/>
	<xsl:param name="fq"/>

	<!-- output modes -->
	<xsl:param name="link"/>
	<xsl:param name="mode"/>

	<xsl:template match="/">
		<xsl:apply-templates select="//lst[@name=concat($field, '_hier')]"/>
	</xsl:template>

	<xsl:template match="lst[@name=concat($field, '_hier')]">
		<xsl:choose>
			<xsl:when test="count(int) = 0">
				<option disabled="disabled">No options available</option>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="int[starts-with(@name, $prefix)]">
					<xsl:variable name="next-level" select="number(substring-after($prefix, 'L')) + 1"/>
					<xsl:variable name="next-prefix" select="concat('L', $next-level)"/>
					<xsl:variable name="next-prefix-count">
						<xsl:value-of
							select="count(document(concat($solr-url, 'select?q=collection-name:', $collection-name, encode-for-uri(' AND '), encode-for-uri($q), '&amp;rows=0&amp;facet.field=', $field, '_hier&amp;fq=collection-name:', $collection-name, encode-for-uri(' AND '), $field, '_hier:&#x022;', encode-for-uri(@name), '&#x022;&amp;facet.prefix=', $next-prefix))//lst[@name='facet_fields']/lst[@name=concat($field, '_hier')]/int)"
						/>
					</xsl:variable>
					<li class="h_item">
						<xsl:if test="$next-prefix-count &gt; 0">
							<xsl:variable name="starter-space" select="if(contains(@name, 'L1|')) then '' else ' '"/>
							<span class="expand_category" id="{replace(@name, ' ', '_')}__{$field}" field="{$field}" q="{$q}" next-prefix="{$next-prefix}"
								link="{concat($link, $starter-space, '+&#x022;', @name, '&#x022;')}">
								<img src="images/{if (contains($q, @name)) then 'minus' else 'plus'}.gif" alt="expand"/>
							</span>
						</xsl:if>

						<!-- figure out problem with labels not updating on findspot city selection -->

						<xsl:choose>
							<xsl:when test="contains($q, @name)">
								<input type="checkbox" value="{@name}" checked="checked">
									<xsl:if test="$next-prefix-count = 0">
										<xsl:attribute name="style">margin-left:12px;</xsl:attribute>
									</xsl:if>
								</input>
							</xsl:when>
							<xsl:otherwise>
								<input type="checkbox" value="{@name}">
									<xsl:if test="$next-prefix-count = 0">
										<xsl:attribute name="style">margin-left:12px;</xsl:attribute>
									</xsl:if>
								</input>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="substring-after(@name, '|')"/>

						<xsl:if test="$next-prefix-count &gt; 0">
							<xsl:choose>
								<xsl:when test="contains($q, @name)">
									<xsl:variable name="starter-space" select="if(contains(@name, 'L1|')) then '' else ' '"/>
									<ul class="{$field}_level" id="{substring-after(replace(@name, ' ', '_'), '|')}__list">
										<cinclude:include
											src="cocoon:/get_hier?q={$q}&amp;fq={@name}&amp;prefix={$next-prefix}&amp;link={concat($link, $starter-space, '%2B&#x022;', @name, '&#x022;')}&amp;field={$field}"
										/>
									</ul>
								</xsl:when>
								<xsl:otherwise>
									<ul class="{$field}_level" id="{substring-after(replace(@name, ' ', '_'), '|')}__list" style="display:none"/>
								</xsl:otherwise>
							</xsl:choose>

						</xsl:if>
					</li>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

</xsl:stylesheet>
