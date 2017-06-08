<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2017 Ethan Gruber
	Numishare
	Apache License 2.0
	Function:  Render RDF into HTML. Note that the RDF-to-HTML serialization only occurs within symbols thus far
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">
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
	
	<!-- get a list of associated coin types -->
	<p:processor name="oxf:pipeline">						
		<p:input name="data" href="#data"/>
		<p:input name="config-xml" href="#config"/>
		<p:input name="config" href="../../../models/sparql/get-types-for-symbols.xpl"/>
		<p:output name="data" id="types"/>
	</p:processor>
	
	<!-- serialize models into HTML -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="types" href="#types"/>
		<p:input name="hasFindspots" href="#hasFindspots"/>
		<p:input name="hasMints" href="#hasMints"/>
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
