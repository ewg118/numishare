<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date modified: May 2020
	Function: Serializes a Solr query for a particular facet and responds with the facet options for the bootstrap multiselect UI.
		It has been extended in May 2020 to render monogram SVG as HTML in the options list -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:numishare="https://github.com/ewg118/numishare" xmlns:nh="http://nomisma.org/nudsHoard"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:saxon="http://saxon.sf.net/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../functions.xsl"/>
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name = 'q']/value"/>
	<xsl:param name="category" select="doc('input:request')/request/parameters/parameter[name = 'category']/value"/>
	<xsl:param name="tokenized_q" select="tokenize($q, ' AND ')"/>

	<xsl:output name="html" encoding="UTF-8" method="html" indent="no" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<html>
			<head>
				<title/>
			</head>
			<body>
				<select>
					<xsl:apply-templates select="descendant::lst[@name = 'facet_fields']/lst[@name = $category]"/>
				</select>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="lst[@name = $category]">
		<xsl:if test="$category != 'category_facet'">
			<xsl:choose>
				<xsl:when test="count(int) = 0">
					<option disabled="disabled">No options available</option>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="int">
						<xsl:variable name="matching_term" select="concat($category, ':&#x022;', @name, '&#x022;')"/>

						<option value="{@name}">
							<xsl:if test="contains($q, $matching_term)">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>

							<xsl:choose>
								<xsl:when test="matches(substring-before(@name, '|'), '^https?://')">
									<xsl:variable name="html" as="element()*">
										<span>
											<img src="{substring-before(@name, '|')}" alt="SVG File" style="height:24px"/>
											<xsl:text> </xsl:text>
											<xsl:value-of select="substring-after(@name, '|')"/>
										</span>
									</xsl:variable>

									<xsl:value-of select="saxon:serialize($html, 'html')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="$category = 'century_num'">
											<xsl:value-of select="numishare:normalize_century(@name)"/>
										</xsl:when>
										<xsl:when test="$category = 'taq_num' or $category = 'tpq_num'">
											<xsl:value-of select="numishare:normalizeDate(format-number(@name, '0000'))"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="@name"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</option>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>