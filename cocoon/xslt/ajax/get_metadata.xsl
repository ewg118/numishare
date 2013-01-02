<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0">

	<xsl:template match="/">
		<xsl:apply-templates select="//doc"/>
	</xsl:template>

	<xsl:template match="doc">
		<ul>
			<li>Object Type: <xsl:value-of select="str[@name='objectType_facet']"/></li>
			<li>Date: <xsl:choose>
					<xsl:when test="string(str[@name='date_display'])">
						<xsl:value-of select="str[@name='date_display']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>[Unknown]</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</li>

			<xsl:if test="arr[@name='department_facet']">

				<li>Department: <xsl:value-of select="arr[@name='department_facet']/str"/>
				</li>

			</xsl:if>
			<xsl:if test="arr[@name='persname_facet']">
				
				<li>Person: <xsl:for-each select="arr[@name='persname_facet']/str">
					<xsl:value-of select="."/>
					<xsl:if test="not(position() = last())">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
				</li>
			</xsl:if>
			<xsl:if test="arr[@name='corpname_facet']">
				
				<li>Issuer: <xsl:for-each select="arr[@name='corpname_facet']/str">
					<xsl:value-of select="."/>
					<xsl:if test="not(position() = last())">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
				</li>
			</xsl:if>
			<xsl:if test="arr[@name='mint_facet']">

				<li> Mint: <xsl:for-each select="arr[@name='mint_facet']/str">
						<xsl:value-of select="."/>
						<xsl:if test="not(position() = last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</li>

			</xsl:if>
			<xsl:if test="arr[@name='region_facet']">

				<li>Region: <xsl:for-each select="arr[@name='region_facet']/str">
						<xsl:value-of select="."/>
						<xsl:if test="not(position() = last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</li>

			</xsl:if>
			<xsl:if test="arr[@name='locality_facet']">

				<li>Locality: <xsl:for-each select="arr[@name='locality_facet']/str">
						<xsl:value-of select="."/>
						<xsl:if test="not(position() = last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</li>

			</xsl:if>
			<xsl:if test="arr[@name='denomination_facet']">

				<li>Denomination: <xsl:for-each select="arr[@name='denomination_facet']/str">
						<xsl:value-of select="."/>
						<xsl:if test="not(position() = last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</li>

			</xsl:if>
			<xsl:if test="arr[@name='material_facet']">

				<li>Material: <xsl:for-each select="arr[@name='material_facet']/str">
						<xsl:value-of select="."/>
						<xsl:if test="not(position() = last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</li>

			</xsl:if>
			<xsl:if test="arr[@name='reference_display']">

				<li>Reference(s): <xsl:for-each select="arr[@name='reference_display']/str">
						<xsl:value-of select="."/>
						<xsl:if test="not(position() = last())">
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</li>

			</xsl:if>
		</ul>
	</xsl:template>

</xsl:stylesheet>
