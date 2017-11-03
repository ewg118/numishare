<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xxf="http://www.orbeon.com/oxf/pipeline"
	xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- request params -->
	<xsl:param name="lang">en</xsl:param>

	<!-- config variable -->
	<xsl:variable name="url" select="/config/url"/>
	<xsl:variable name="service" select="concat($url, 'apis/reconcile')"/>

	<xsl:param name="prefix" select="doc('input:request')/request/parameters/parameter[name = 'prefix']/value"/>

	<xsl:variable name="properties" as="node()*">
		<properties>
			<xsl:for-each select="/config/facets/facet">
				<property id="{.}">
					<xsl:value-of select="numishare:regularize_node(substring-before(., '_'), $lang)"/>
					<xsl:text> (Exact)</xsl:text>
				</property>
				<property id="{replace(., 'facet', 'text')}">
					<xsl:value-of select="numishare:regularize_node(substring-before(., '_'), $lang)"/>
					<xsl:text> (Keyword)</xsl:text>
				</property>
			</xsl:for-each>
		</properties>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:variable name="model" as="element()*">
			<_object>
				<code>/api/status/ok</code>
				<status>200 OK</status>
				<prefix>
					<xsl:value-of select="doc('input:request')/request/parameters/parameter[name = 'prefix']/value"/>
				</prefix>
				<result>
					<_array>
						<xsl:apply-templates select="$properties/property[matches(., concat($prefix, '.*'), 'i')]">
							<xsl:with-param name="mode">suggest</xsl:with-param>
						</xsl:apply-templates>
					</_array>
				</result>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="property">
		<_object>
			<id>
				<xsl:value-of select="@id"/>
			</id>
			<name>
				<xsl:value-of select="."/>
			</name>
		</_object>
	</xsl:template>

</xsl:stylesheet>
