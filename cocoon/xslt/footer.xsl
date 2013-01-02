<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/" version="2.0">
	<xsl:template name="footer">		
		<xsl:copy-of select="saxon:parse(concat('&lt;div id=&#x022;ft&#x022;&gt;', string(//config/footer), '&lt;/div&gt;'))"/>
	</xsl:template>
</xsl:stylesheet>
