<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: June 2021
	Function: Serialize Symbol RDF document into GeoJSON, including SPARQL queries for mints, findspots, and hoards	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

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
	
	<!-- execute SPARQL queries -->
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#data"/>
		<p:input name="config-xml" href="#config"/>
		<p:input name="config" href="../../../models/sparql/getMints.xpl"/>
		<p:output name="data" id="mints"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#data"/>
		<p:input name="config-xml" href="#config"/>
		<p:input name="config" href="../../../models/sparql/getHoards.xpl"/>
		<p:output name="data" id="hoards"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#data"/>
		<p:input name="config-xml" href="#config"/>
		<p:input name="config" href="../../../models/sparql/getFindspots.xpl"/>
		<p:output name="data" id="findspots"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="mints" href="#mints"/>
		<p:input name="hoards" href="#hoards"/>
		<p:input name="findspots" href="#findspots"/>
		<p:input name="data" href="aggregate('content', #data, #config)"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/sparql/geojson.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>

	<p:processor name="oxf:text-converter">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/vnd.geo+json</content-type>
				<encoding>utf-8</encoding>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>