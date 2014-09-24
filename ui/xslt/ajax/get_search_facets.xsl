<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all">
	<xsl:include href="../functions.xsl"/>
	
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="category" select="doc('input:request')/request/parameters/parameter[name='category']/value"/>
	
	<xsl:template match="/">
		<select class="search_text form-control">
			<option value="">Select option from list...</option>
			<xsl:apply-templates select="descendant::lst[@name=$category]/int"/>
		</select>
	</xsl:template>

	<xsl:template match="int">
		<xsl:choose>
			<xsl:when test="$category = 'century_num'">
				<option value="&#x0022;{@name}&#x0022;" class="term">
					<xsl:value-of select="numishare:normalize_century(@name)"/>
				</option>
			</xsl:when>
			<xsl:otherwise>
				<option value="&#x0022;{@name}&#x0022;" class="term">
					<xsl:value-of select="@name"/>
				</option>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
