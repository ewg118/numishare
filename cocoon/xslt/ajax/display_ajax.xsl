<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">	
	<xsl:include href="../display/nuds/html.xsl"/>

	<xsl:param name="q"/>
	<xsl:param name="start"/>
	<xsl:param name="mode"/>
	<xsl:param name="image"/>
	<xsl:param name="side"/>
	<xsl:param name="display_path"/>
	
	<xsl:variable name="flickr-api-key" select="/content/config/flickr_api_key"/>		
	
	<!-- get layout -->
	<xsl:variable name="orientation" select="/content/config/theme/layouts/display/nuds/orientation"/>
	<xsl:variable name="image_location" select="/content/config/theme/layouts/display/nuds/image_location"/>	

	<xsl:template match="/">		
		<xsl:choose>
			<xsl:when test="descendant::nuds">
				<xsl:call-template name="nuds"/>
			</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
</xsl:stylesheet>
