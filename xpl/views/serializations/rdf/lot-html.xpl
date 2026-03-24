<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: March 2026
	Function: Serialize Linked Art compliant CIDOC-CRM RDF/XML into HTML
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#">
	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<!-- include Solr query to ask for associated number of objects and geographic facets -->
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/solr/ask-coins-for-lots.xpl"/>
		<p:output name="data" id="specimens"/>
	</p:processor>
	
	<!-- serialize models into HTML -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="specimens" href="#specimens"/>
		<p:input name="data" href="aggregate('content', #data, #config)"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/rdf/lot-html.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>	
	
	<p:processor name="oxf:html-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<version>5.0</version>
				<indent>true</indent>
				<content-type>text/html</content-type>
				<encoding>utf-8</encoding>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
