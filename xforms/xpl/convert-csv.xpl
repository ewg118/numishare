<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<p:param name="file" type="input"/>
	<p:param name="data" type="output" />
	
	<!-- Upload of .csv -->
	<p:processor name="oxf:url-generator">		
		<p:input name="config" href="#file"/>		
		<p:output name="data" id="documentTexteCsv" />
	</p:processor>
	
	
	<p:processor name="oxf:xslt">
		<p:input name="data" href="#documentTexteCsv"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0">
				<xsl:import href="../xslt/csv2xml-xslt2.xsl" />
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="csvConverti" ref="data"/>
	</p:processor>
	
</p:pipeline>
