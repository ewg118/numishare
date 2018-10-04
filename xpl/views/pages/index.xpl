<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL Pipeline for the Index page in Numishare. Read the config to see if the features_enabled
is active (physical object collections only) and extract a random object from the collection to be
shown on the home page. Otherwise, just serialize the config variables into HTML
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
	
	<p:choose href="#data">
		<p:when test="/config/features_enabled = true()">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../../models/solr/get_feature.xpl"/>		
				<p:output name="data" id="feature-model"/>
			</p:processor>
			
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="feature-model" href="#feature-model"/>
				<p:input name="data" href="#data"/>		
				<p:input name="config" href="../../../ui/xslt/pages/index.xsl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="#data"/>		
				<p:input name="config" href="../../../ui/xslt/pages/index.xsl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>	
</p:config>