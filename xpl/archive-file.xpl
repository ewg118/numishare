<?xml version="1.0" encoding="UTF-8"?>
<!-- Convert a document to serialized XML -->
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">	
	
	<p:param name="dump" type="input"/>
	<p:param name="file" type="input"/>
	<p:param name="serialize-config" type="input"/>	
	<p:param name="data" type="output"/>	

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#file"/>       
		<p:output name="data" id="new-file"/>
	</p:processor>
	
	<!-- Write the document to a file -->
	<p:processor name="oxf:file-serializer">		
		<p:input name="config" href="#serialize-config"/>
		<p:input name="data" href="#new-file"/>		
	</p:processor>
	
	<p:processor name="oxf:xml-converter">
		<p:input name="config">
			<config>				 
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:input name="data" href="#dump"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:pipeline>
