<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: June 2020
	Function: Execute some SPARQL ASK queries for geodata and query for types related to a symbol URI
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
	
	<!-- get query from a text file on disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/get-types-for-symbols.sparql</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="query"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#query"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="query-document"/>
	</p:processor>
	
	<!-- ask whether there are mints or findspots associated with the coin types associated with the symbol -->
	<p:processor name="oxf:pipeline">						
		<p:input name="data" href="#config"/>
		<p:input name="config" href="../../../models/sparql/ask-mints-for-symbols.xpl"/>
		<p:output name="data" id="hasMints"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">						
		<p:input name="data" href="#config"/>
		<p:input name="config" href="../../../models/sparql/ask-findspots.xpl"/>
		<p:output name="data" id="hasFindspots"/>
	</p:processor>
	
	<!-- ask whether there are related symbols -->
	<p:processor name="oxf:pipeline">						
		<p:input name="data" href="#config"/>
		<p:input name="config" href="../../../models/sparql/ask-symbol-relations.xpl"/>
		<p:output name="data" id="hasSymbolRelations"/>
	</p:processor>
	
	<!-- get a list of associated coin types -->
	<p:processor name="oxf:pipeline">						
		<p:input name="data" href="#data"/>
		<p:input name="config-xml" href="#config"/>
		<p:input name="config" href="../../../models/sparql/get-types-for-symbols.xpl"/>
		<p:output name="data" id="types"/>
	</p:processor>
	
	<!-- get a list of symbols that have a skos:broader of the current symbol URI -->	
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#config"/>
		<p:input name="config" href="../../../models/xquery/get-subsymbols.xpl"/>
		<p:output name="data" id="subsymbols"/>
	</p:processor>			
	
	<!-- serialize models into HTML -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="types" href="#types"/>
		<p:input name="hasFindspots" href="#hasFindspots"/>
		<p:input name="hasMints" href="#hasMints"/>
		<p:input name="hasSymbolRelations" href="#hasSymbolRelations"/>
		<p:input name="subsymbols" href="#subsymbols"/>
		<p:input name="query" href="#query-document"/>
		<p:input name="data" href="aggregate('content', #data, #config)"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/rdf/html.xsl"/>
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
