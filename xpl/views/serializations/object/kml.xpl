<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: April 2020
	Function: Serialize NUDS or NUDS Hoard document into KML. If there is a SPARQL endpoint and the collection
	is a coin type collection, then execute the SPARQL query to get associated hoards in order to serialize into Placemarks -->
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

	<!-- evaluate whether or not a SPARQL query should be executed for coin type corpora -->
	<p:choose href="#config">
		<p:when test="/config/collection_type='cointype' and matches(/config/sparql_endpoint, 'https?://')">
			<!-- execute SPARQL query for a hoard -->
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../../../models/sparql/getHoards.xpl"/>
				<p:output name="data" id="hoards"/>
			</p:processor>

			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="hoards" href="#hoards"/>
				<p:input name="data" href="aggregate('content', #data, #config)"/>
				<p:input name="config" href="../../../../ui/xslt/serializations/object/kml.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', #data, #config)"/>
				<p:input name="config" href="../../../../ui/xslt/serializations/object/kml.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
	
	<!-- serialize to KML -->
	<p:processor name="oxf:xml-serializer">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<content-type>application/vnd.google-earth.kml+xml</content-type>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>

</p:config>
