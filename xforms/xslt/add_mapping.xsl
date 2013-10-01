<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

	<xsl:param name="contains_id">
		<xsl:value-of select="count(//row[last()]//elem[@mapping='recordId'])"/>
	</xsl:param>

	<xsl:template match="/">
		<root>
			<xsl:apply-templates select="//row[not(position() = last())]"/>
		</root>
	</xsl:template>

	<xsl:template match="row">
		<row>
			<elem name="recordType" mapping="recordType">
				<xsl:value-of select="//row[last()]/recordType"/>
			</elem>
			<xsl:if test="$contains_id = 0">
				<elem name="recordId" mapping="recordId">
					<xsl:value-of select="id"/>
				</elem>
			</xsl:if>
			<xsl:for-each select="elem">
				<xsl:variable name="position" select="position()"/>
				<elem name="{@name}">
					<xsl:if test="string(//row[last()]/elem[position() = $position]/@mapping)">
						<xsl:attribute name="mapping" select="//row[last()]/elem[position() = $position]/@mapping"/>
					</xsl:if>
					<xsl:value-of select="."/>
				</elem>
			</xsl:for-each>
		</row>
	</xsl:template>

</xsl:stylesheet>
