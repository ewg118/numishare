<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#all" version="2.0">
	<xsl:template name="footer">		
		<div class="container-fluid" id="footer">
			<div class="col-md-12">
				<xsl:copy-of select="//config/footer/*"/>
			</div>
		</div>		
	</xsl:template>
</xsl:stylesheet>
