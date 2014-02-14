<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	Numishare: https://github.com/ewg118/numishare
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">
	
	<p:param type="input" name="source"/>
	<p:param type="output" name="finalized"/>
	
	<p:processor name="oxf:xslt">
		<p:input name="data" href="#source"/>
		<p:input name="config" href="../xslt/add_mapping.xsl"/>
		<p:output name="data" id="schematized"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="aggregate('content', #schematized, ../exist-config.xml)"/>
		<p:input name="config" href="../xslt/xml2ead.xsl"/>
		<p:output name="data" ref="finalized"/>
	</p:processor>
	
</p:config>