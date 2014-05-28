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

	<xsl:template match="/">
		<xsl:variable name="id-param">
			<xsl:for-each select="distinct-values(descendant::nuds:typeDesc[string(@xlink:href) and (boolean(index-of($codes, @certainty)) = false())]/@xlink:href)">
				<xsl:value-of select="."/>
				<xsl:if test="not(position()=last())">
					<xsl:text>|</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="date" select="document(concat('http://nomisma.org/apis/closingDate?identifiers=', encode-for-uri($id-param)))/response"/>
			
		<xsl:value-of select="nh:normalize_date($date, $date)"/>		
	</xsl:template>

</xsl:stylesheet>
