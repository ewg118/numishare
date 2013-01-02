<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:nm="http://nomisma.org/id/" xmlns:nuds="http://nomisma.org/nuds"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="#all" version="2.0">
	<!--***************************************** Process Nomisma Coin Type RDF into NUDS **************************************** -->
	<xsl:template match="nm:coin|nm:type_series_item">
		<nuds:typeDesc>
			<xsl:attribute name="xlink:href" select="@rdf:about"/>

			<nuds:objectType xlink:href="http://nomisma.org/id/coin">Coin</nuds:objectType>
			<xsl:if test="nm:start_date or nm:end_date">
				<xsl:call-template name="nm:date"/>
			</xsl:if>
			<xsl:for-each select="nm:denomination">
				<xsl:call-template name="nm:generate_element">
					<xsl:with-param name="element">denomination</xsl:with-param>
					<xsl:with-param name="role"/>
					<xsl:with-param name="uri" select="@rdf:resource"/>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:for-each select="nm:material">
				<xsl:call-template name="nm:generate_element">
					<xsl:with-param name="element">material</xsl:with-param>
					<xsl:with-param name="role"/>
					<xsl:with-param name="uri" select="@rdf:resource"/>
				</xsl:call-template>
			</xsl:for-each>

			<!-- authority -->
			<xsl:if test="nm:authority or nm:issuer">
				<nuds:authority>
					<xsl:for-each select="nm:authority">
						<xsl:call-template name="nm:generate_element">
							<xsl:with-param name="element">persname</xsl:with-param>
							<xsl:with-param name="role">authority</xsl:with-param>
							<xsl:with-param name="uri" select="@rdf:resource"/>
						</xsl:call-template>
					</xsl:for-each>
					<xsl:for-each select="nm:issuer">
						<xsl:call-template name="nm:generate_element">
							<xsl:with-param name="element">persname</xsl:with-param>
							<xsl:with-param name="role">issuer</xsl:with-param>
							<xsl:with-param name="uri" select="@rdf:resource"/>
						</xsl:call-template>
					</xsl:for-each>
				</nuds:authority>
			</xsl:if>

			<!-- geographic -->
			<xsl:if test="descendant::nm:mint">
				<nuds:geographic>
					<xsl:for-each select="descendant::nm:mint">
						<xsl:call-template name="nm:generate_element">
							<xsl:with-param name="element">geogname</xsl:with-param>
							<xsl:with-param name="role">mint</xsl:with-param>
							<xsl:with-param name="uri" select="@rdf:resource"/>
						</xsl:call-template>
					</xsl:for-each>
				</nuds:geographic>
			</xsl:if>

			<!-- obverse -->
			<xsl:apply-templates select="nm:obverse"/>
			<xsl:apply-templates select="nm:reverse"/>
		</nuds:typeDesc>
	</xsl:template>

	<xsl:template match="nm:obverse|nm:reverse">
		<xsl:element name="{local-name()}" namespace="http://nomisma.org/nuds">
			<xsl:if test="descendant::nm:legend">
				<nuds:legend>
					<xsl:value-of select="descendant::nm:legend"/>
				</nuds:legend>
			</xsl:if>
			<xsl:if test="descendant::nm:description">
				<nuds:type>
					<xsl:value-of select="descendant::nm:description"/>
				</nuds:type>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<xsl:template name="nm:generate_element">
		<xsl:param name="element"/>
		<xsl:param name="role"/>
		<xsl:param name="uri"/>

		<xsl:element name="{$element}" namespace="http://nomisma.org/nuds">
			<xsl:if test="string($role)">
				<xsl:attribute name="xlink:role" select="$role"/>
			</xsl:if>
			<xsl:if test="ancestor::nm:uncertain_value">
				<xsl:attribute name="certainty">uncertain</xsl:attribute>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="string($uri)">
					<xsl:attribute name="xlink:href" select="$uri"/>
					<!-- get the prefLabel from nomisma only when there isn't a value already -->
					<xsl:choose>
						<xsl:when test="string(normalize-space(.))">
							<xsl:value-of select="."/>
						</xsl:when>
						<xsl:otherwise>
							<!-- get the English prefLabel by default.  If there is no @xml:lang defined, just get first prefLabel -->
							<xsl:choose>
								<xsl:when test="string(exsl:node-set($rdf)/rdf:RDF/*[@rdf:about = $uri]/skos:prefLabel[@xml:lang='en'])">
									<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about = $uri]/skos:prefLabel[@xml:lang='en']"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about = $uri]/skos:prefLabel[1]"/>
								</xsl:otherwise>
							</xsl:choose>
							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template name="nm:date">
		<nuds:date>
			<xsl:attribute name="normal">
				<xsl:choose>
					<xsl:when test="number(nm:start_date) = number(nm:end_date)">
						<xsl:value-of select="format-number(number(nm:start_date), '0000')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(number(nm:start_date), '0000')"/>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="format-number(number(nm:end_date), '0000')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>

			<!-- textual value -->
			<xsl:call-template name="nm:normalize_date">
				<xsl:with-param name="start_date" select="nm:start_date"/>
				<xsl:with-param name="end_date" select="nm:end_date"/>
			</xsl:call-template>

		</nuds:date>
	</xsl:template>

	<xsl:template name="nm:normalize_date">
		<xsl:param name="start_date"/>
		<xsl:param name="end_date"/>

		<xsl:choose>
			<xsl:when test="number($start_date) = number($end_date)">
				<xsl:if test="number($start_date) &lt; 500 and number($start_date) &gt; 0">
					<xsl:text>A.D. </xsl:text>
				</xsl:if>
				<xsl:value-of select="abs(number($start_date))"/>
				<xsl:if test="number($start_date) &lt; 0">
					<xsl:text> B.C.</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!-- start date -->

				<xsl:if test="number($start_date) &lt; 500 and number($start_date) &gt; 0">
					<xsl:text>A.D. </xsl:text>
				</xsl:if>
				<xsl:value-of select="abs(number($start_date))"/>
				<xsl:if test="number($start_date) &lt; 0">
					<xsl:text> B.C.</xsl:text>
				</xsl:if>
				<xsl:text> - </xsl:text>

				<!-- end date -->
				<xsl:if test="number($end_date) &lt; 500 and number($end_date) &gt; 0">
					<xsl:text>A.D. </xsl:text>
				</xsl:if>
				<xsl:value-of select="abs(number($end_date))"/>
				<xsl:if test="number($end_date) &lt; 0">
					<xsl:text> B.C.</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
