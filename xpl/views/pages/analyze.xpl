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
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../models/config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../models/solr/get_hoards.xpl"/>
		<p:output name="data" id="get_hoards-model"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#get_hoards-model"/>		
		<p:input name="config" href="../../../ui/xslt/ajax/get_hoards.xsl"/>
		<p:output name="data" id="get_hoards-view"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="aggregate('content', #data, #config, #get_hoards-view)"/>		
		<p:input name="config" href="../../../ui/xslt/pages/analyze.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
