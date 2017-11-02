<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- config variable -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="service" select="concat($url, 'apis/reconcile')"/>

	<!-- request params -->
	<xsl:param name="suggest" select="
			if (contains(doc('input:request')/request/request-url, 'suggest/')) then
				true()
			else
				false()"/>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$suggest = true()">
				<!-- apply alternative templates for the suggest API response instead of the default query response -->
				<xsl:variable name="model" as="element()*">
					<xsl:apply-templates select="descendant::result[@name = 'response']" mode="suggest"/>
				</xsl:variable>
				
				<xsl:apply-templates select="$model"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="model" as="element()*">
					<xsl:choose>
						<xsl:when test="count(descendant::response) &gt; 1">
							<_object>
								<xsl:apply-templates select="descendant::response">
									<xsl:sort order="ascending" select="lst[@name = 'responseHeader']/lst[@name = 'params']/str[@name = 'qid']"/>
								</xsl:apply-templates>
							</_object>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="descendant::response"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:apply-templates select="$model"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- TEMPLATE FOR SEARCH RESPONSE -->
	<xsl:template match="response">
		<xsl:choose>
			<xsl:when test="string(lst[@name = 'responseHeader']/lst[@name = 'params']/str[@name = 'qid'])">
				<xsl:element name="{descendant::str[@name = 'qid'][1]}">
					<xsl:apply-templates select="result[@name = 'response']" mode="query"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="result[@name = 'response']" mode="query"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- response for query results -->
	<xsl:template match="result[@name = 'response']" mode="query">
		<xsl:variable name="numFound" select="@numFound"/>
		<xsl:variable name="maxScore" select="@maxScore"/>

		<_object>
			<result>
				<_array>
					<xsl:apply-templates select="descendant::doc">
						<xsl:with-param name="mode">query</xsl:with-param>
						<xsl:with-param name="numFound" select="$numFound"/>
						<xsl:with-param name="maxScore" select="$maxScore"/>
					</xsl:apply-templates>
				</_array>
			</result>
		</_object>
	</xsl:template>

	<!-- response for suggest API -->
	<xsl:template match="result[@name = 'response']" mode="suggest">
		<_object>
			<code>/api/status/ok</code>
			<status>200 OK</status>
			<prefix>
				<xsl:value-of select="doc('input:request')/request/parameters/parameter[name = 'prefix']/value"/>
			</prefix>
			<result>
				<_array>
					<xsl:apply-templates select="descendant::doc">
						<xsl:with-param name="mode">suggest</xsl:with-param>
					</xsl:apply-templates>
				</_array>
			</result>
		</_object>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:param name="mode"/>
		<xsl:param name="numFound"/>
		<xsl:param name="maxScore"/>

		<_object>
			<id>
				<xsl:value-of select="str[@name = 'recordId']"/>
			</id>
			<name>
				<xsl:value-of select="str[@name = 'title_display']"/>
			</name>

			<xsl:choose>
				<xsl:when test="$mode = 'query'">
					<type>
						<_array>
							<_object>
								<id>conceptual</id>
								<name>Coin Type</name>
							</_object>
						</_array>
					</type>
				</xsl:when>
				<xsl:when test="$mode = 'suggest'">
					<n:type xmlns:n="//null">
						<_object>
							<id>conceptual</id>
							<name>Coin Type</name>
						</_object>
					</n:type>
				</xsl:when>
			</xsl:choose>


			<xsl:if test="$mode = 'query'">
				<score>
					<xsl:value-of select="float[@name = 'score'] div $maxScore"/>
				</score>
				<match>
					<xsl:value-of
						select="
							if ($numFound = 1 and float[@name = 'score'] div $maxScore &gt; 0.8) then
								'true'
							else
								'false'"/>
				</match>
			</xsl:if>
		</_object>
	</xsl:template>

</xsl:stylesheet>
