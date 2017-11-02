<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- config variable -->
	<xsl:variable name="url" select="/config/url"/>
	<xsl:variable name="service" select="concat($url, 'apis/reconcile')"/>

	<!-- request params -->
	<xsl:param name="suggest" select="
			if (contains(doc('input:request')/request/request-url, 'suggest/')) then
				true()
			else
				false()"/>

	<xsl:template match="/config">
		<xsl:variable name="model" as="element()*">
			<_object>
				<name>
					<xsl:value-of select="title"/>
				</name>
				<view>
					<_object>
						<url>
							<xsl:value-of select="concat(uri_space, '{{id}}')"/>
						</url>
					</_object>
				</view>
				<identifierSpace>
					<xsl:value-of select="uri_space"/>
				</identifierSpace>
				<schemaSpace>http://nomisma.org/nuds</schemaSpace>
				<defaultTypes>
					<_array>
						<_object>
							<id>conceptual</id>
							<name>Coin Type</name>
						</_object>
					</_array>
				</defaultTypes>
				<preview>
					<_object>
						<url>
							<xsl:value-of select="concat($service, '/preview?id={{id}}')"/>
						</url>
						<height>160</height>
						<width>320</width>
					</_object>
				</preview>
				<suggest>
					<_object>
						<entity>
							<_object>
								<service_url>
									<xsl:value-of select="$service"/>
								</service_url>
								<service_path>/suggest/entity</service_path>
								<flyout_service_path>/flyout?id=${id}</flyout_service_path>
							</_object>
						</entity>
					</_object>
				</suggest>
			</_object>
		</xsl:variable>
		
		<xsl:apply-templates select="$model"/>
	</xsl:template>

</xsl:stylesheet>
