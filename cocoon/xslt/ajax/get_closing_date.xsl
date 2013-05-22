<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:nuds="http://nomisma.org/nuds" xmlns:nh="http://nomisma.org/nudsHoard" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:cinclude="http://apache.org/cocoon/include/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../functions.xsl"/>

	<!-- use the calculate URI parameter to output tables/charts for counts of material, denomination, issuer, etc. -->
	<xsl:param name="exclude">2,3,4,7,8,9</xsl:param>
	<xsl:variable name="codes" as="item()*">
		<xsl:sequence select="tokenize($exclude, ',')"/>
	</xsl:variable>

	<xsl:variable name="id" select="normalize-space(//*[local-name()='nudsid'])"/>

	<xsl:variable name="contentsDesc">
		<xsl:copy-of select="descendant::nh:contents"/>
	</xsl:variable>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<!-- get nomisma NUDS documents with get-nuds API -->
			<xsl:variable name="id-param">
				<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[contains(@xlink:href, 'nomisma.org') and (boolean(index-of($codes, @certainty)) = false())]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:if test="string-length($id-param) &gt; 0">
				<xsl:for-each select="document(concat('http://admin.numismatics.org/nomisma/apis/getNuds?identifiers=', $id-param))//nuds:nuds">
					<object xlink:href="http://nomisma.org/id/{nuds:nudsHeader/nuds:nudsid}">
						<xsl:copy-of select="."/>
					</object>
				</xsl:for-each>
			</xsl:if>

			<!-- incorporate other typeDescs which do not point to nomisma.org -->
			<xsl:for-each select="descendant::nuds:typeDesc[not(contains(@xlink:href, 'nomisma.org')) and (boolean(index-of($codes, @certainty)) = false())]">
				<xsl:choose>
					<xsl:when test="string(@xlink:href)">
						<object xlink:href="{@xlink:href}">
							<xsl:copy-of select="document(concat(@xlink:href, '.xml'))/nuds:nuds"/>
						</object>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</nudsGroup>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:variable name="dates" as="element()*">
			<dates>
				<xsl:for-each select="distinct-values($nudsGroup/descendant::*/@standardDate)">
					<xsl:sort data-type="number"/>
					<xsl:if test="number(.)">
						<date>
							<xsl:value-of select="number(.)"/>
						</date>
					</xsl:if>
				</xsl:for-each>
			</dates>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="count($dates/date) &gt; 0">
				<xsl:value-of select="nh:normalize_date($dates/date[last()], $dates/date[last()])"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Unknown</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
