<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: June 2021
	Function: Serialize NUDS document into GeoJSON. Optionally, include the results for a SPARQL query for hoards and individual finds related to a coin type	
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
	
	<p:choose href="#config">
		<p:when test="/config/collection_type='cointype' and matches(/config/sparql_endpoint, 'https?://')">
			<!-- execute SPARQL queries for hoards and findspots -->
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
				<p:input name="hoards" href="#hoards"/>
				<p:input name="findspots" href="#findspots"/>
				<p:input name="data" href="aggregate('content', #data, #config)"/>
				<p:input name="config" href="../../../../ui/xslt/serializations/nuds/geojson.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>		
				<p:input name="data" href="aggregate('content', #data, #config)"/>		
				<p:input name="config" href="../../../../ui/xslt/serializations/nuds/geojson.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:otherwise>
	</p:choose>

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