<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

	<xsl:template match="/config">
		<xsl:variable name="params">?q={searchTerms}&amp;start={startIndex}&amp;format=atom</xsl:variable>

		<OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/" xmlns:dc="http://purl.org/dc/elements/1.1/">
			<ShortName>
				<xsl:value-of select="title"/>
			</ShortName>
			<dc:relation href="{url}"/>
			<Tags>coins</Tags>
			<xsl:if test="string(normalize-space(contact))">
				<Contact>
					<xsl:value-of select="normalize-space(contact)"/>
				</Contact>
			</xsl:if>
			<Url type="application/atom+xml" template="{url}apis/search{$params}"/>
			<Query role="example" searchTerms="test+xml"/>
			<xsl:if test="string(template/copyrightHolder) or string(template/license)">
				<Attribution>
					<xsl:if test="string(template/copyrightHolder)">Copyright: <xsl:value-of select="template/copyrightHolder"/></xsl:if>
					<xsl:if test="string(template/copyrightHolder) and string(template/license)"><xsl:text>, </xsl:text></xsl:if>
					<xsl:if test="string(template/license)">License: <xsl:value-of select="template/license"/></xsl:if>
				</Attribution>
			</xsl:if>

		</OpenSearchDescription>
	</xsl:template>
</xsl:stylesheet>
