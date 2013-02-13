<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/" exclude-result-prefixes="#all" version="2.0">
	<xsl:template name="footer">
		<div id="ft">
			<div class="yui3-g">
				<div class="yui3-u-1-3">
					<div class="content">
						<a href="http://lib.virginia.edu" target="_blank">University of Virginia Library</a>
						<br/>
						<xsl:text>PO Box 40013, Charlottesville, VA 22904-4113</xsl:text>
						<br/>
						<xsl:text>ph: (434) 924-3201, fax: (434) 924-1431</xsl:text>
						<br/>
						<xsl:text>Comments/Errors: Contact coins [at] collab.itc.virginia.edu</xsl:text>
					</div>
				</div>
				<div class="yui3-u-1-3">
					<div class="content">
						
					</div>
				</div>
				<div class="yui3-u-1-3">
					<div class="content" style="text-align:right">
						<a href="http://www.virginia.edu/artmuseum/index.php" target="_blank">The Fralin | University of Virginia Art Museum</a>
						<br/>
						<xsl:text>Thomas H. Bayly Building</xsl:text><br/>
						<xsl:text>155 Rugby Road, PO Box 400119</xsl:text><br/>
						<xsl:text>Charlottesville VA 22904-4119</xsl:text>
					</div>
				</div>
			</div>
		</div>
		<!--<xsl:copy-of select="saxon:parse(concat('&lt;div id=&#x022;ft&#x022;&gt;', string(//config/footer), '&lt;/div&gt;'))"/>-->
	</xsl:template>
</xsl:stylesheet>
