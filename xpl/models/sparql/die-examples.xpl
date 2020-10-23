<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Last modified: October 2020
	Function: execute a SPARQL query with an optional page parameter to get examples of physical specimens for a given die URI, limited to a value set in the config (or 48 if not set).
	This should handle union queries of 1 or more named graphs defined in the Numishare config.
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
	
	<!-- load SPARQL query from disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/die-examples.sparql</url>
				<content-type>text/plain</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" id="die-examples-query"/>
	</p:processor>
	
	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#die-examples-query"/>
		<p:input name="config">
			<config/>
		</p:input>
		<p:output name="data" id="die-examples-query-document"/>
	</p:processor>

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="query" href="#die-examples-query-document"/>
		<p:input name="data" href="#data"/>
		<p:input name="config" href="../../../ui/xslt/controllers/die-example-params-to-model.xsl"/>
		<p:output name="data" id="url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
