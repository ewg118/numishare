<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
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
			
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#feature-model"/>
				<p:input name="config" href="../../views/ajax/get_feature.xpl"/>		
				<p:output name="data" id="feature-view"/>
			</p:processor>
			
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>
				<p:input name="data" href="aggregate('content', #data, #feature-view)"/>		
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
