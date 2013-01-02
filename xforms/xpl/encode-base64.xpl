<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<p:param name="file" type="input"/>
	<p:param name="data" type="output" />	
	
	<p:processor name="oxf:url-generator">       
		<p:input name="config" href="#file"/>       
		<p:output name="data" ref="data"/>
	</p:processor>
</p:pipeline>