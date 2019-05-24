<?xml version="1.0" encoding="UTF-8"?>
<!--
	Author: Ethan Gruber
	Date: February 2019
	Function: Execute a SPARQL query or chain of SPARQL queries for measurement analyses to extract a JSON response for d3
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
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<!-- get query from a text file on disk -->
	<p:processor name="oxf:url-generator">
		<p:input name="config">
			<config>
				<url>oxf:/apps/numishare/ui/sparql/quant_average.sparql</url>
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

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:numishare="https://github.com/ewg118/numishare">
				<xsl:param name="interval" select="/request/parameters/parameter[name='interval']/value"/>
				<xsl:param name="from" select="/request/parameters/parameter[name='from']/value"/>
				<xsl:param name="to" select="/request/parameters/parameter[name='to']/value"/>

				<xsl:template match="/">
					<interval>
						<xsl:choose>
							<xsl:when test="number($from) and number($to) and number($interval)">true</xsl:when>
							<xsl:otherwise>false</xsl:otherwise>
						</xsl:choose>
					</interval>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="interval-query"/>
	</p:processor>

	<p:choose href="#interval-query">
		<p:when test="/interval='true'">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#request"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
						xmlns:numishare="https://github.com/ewg118/numishare">
						<xsl:include href="../../../ui/xslt/functions.xsl"/>

						<!-- request parameters -->
						<xsl:param name="compare" select="/request/parameters/parameter[name='compare']/value"/>
						<xsl:param name="filter" select="/request/parameters/parameter[name='filter']/value"/>
						<xsl:param name="interval" select="/request/parameters/parameter[name='interval']/value"/>
						<xsl:param name="from" select="/request/parameters/parameter[name='from']/value"/>
						<xsl:param name="to" select="/request/parameters/parameter[name='to']/value"/>

						<xsl:template match="/">
							<queries>
								<xsl:if test="string($filter)">
									<group>
										<xsl:call-template name="loop">
											<xsl:with-param name="from" select="$from"/>
											<xsl:with-param name="to" select="$to"/>
											<xsl:with-param name="interval" select="$interval"/>
											<xsl:with-param name="query" select="normalize-space($filter)"/>
										</xsl:call-template>
									</group>
								</xsl:if>
								<xsl:for-each select="$compare">
									<group>
										<xsl:call-template name="loop">
											<xsl:with-param name="from" select="$from"/>
											<xsl:with-param name="to" select="$to"/>
											<xsl:with-param name="interval" select="$interval"/>
											<xsl:with-param name="query" select="normalize-space(.)"/>
										</xsl:call-template>
									</group>
								</xsl:for-each>
							</queries>
						</xsl:template>

						<xsl:template name="loop">
							<xsl:param name="from"/>
							<xsl:param name="to"/>
							<xsl:param name="interval"/>
							<xsl:param name="query"/>

							<query>
								<xsl:choose>
									<xsl:when test="$interval = 1">
										<xsl:attribute name="range" select="if ($from = 0) then numishare:normalizeDate('1') else numishare:normalizeDate(string($from))"/>		
										<xsl:attribute name="year" select="if ($from = 0) then (format-number(1, '0000')) else format-number($from, '0000')"/>
										<xsl:value-of select="$query"/>
										<xsl:text>; range </xsl:text>
										<xsl:value-of select="concat(string($from), '|', string($from))"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="range">
											<xsl:value-of select="if ($from = 0) then numishare:normalizeDate('1') else numishare:normalizeDate(string($from))"/>
											<xsl:text> - </xsl:text>
											<xsl:value-of select="numishare:normalizeDate(string($from + ($interval - 1)))"/>
										</xsl:attribute>
										<xsl:attribute name="year" select="if ($from = 0) then (format-number(1, '0000')) else format-number($from, '0000')"/>
										<xsl:value-of select="$query"/>
										<xsl:text>; range </xsl:text>
										<xsl:value-of select="concat(string($from), '|', string($from + ($interval - 1)))"/>
									</xsl:otherwise>
								</xsl:choose>
							</query>

							<xsl:if test="$from + $interval &lt;= $to">
								<xsl:call-template name="loop">
									<xsl:with-param name="from" select="$from + $interval"/>
									<xsl:with-param name="to" select="$to"/>
									<xsl:with-param name="interval" select="$interval"/>
									<xsl:with-param name="query" select="$query"/>
								</xsl:call-template>
							</xsl:if>
						</xsl:template>

					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="group-queries"/>
				<!--<p:output name="data" ref="data"/>-->
			</p:processor>

			<p:for-each href="#group-queries" select="//group" root="response" id="aggregate-response">
				<p:processor name="oxf:unsafe-xslt">
					<p:input name="data" href="current()"/>
					<p:input name="config">
						<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
							<xsl:template match="/">
								<xsl:copy-of select="."/>
							</xsl:template>
						</xsl:stylesheet>
					</p:input>
					<p:output name="data" id="group"/>
				</p:processor>

				<p:for-each href="#group" select="//query" root="group" id="range-result">
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="filter" href="current()"/>
						<p:input name="query" href="#query-document"/>
						<p:input name="request" href="#request"/>
						<p:input name="data" href="#config"/>
						<p:input name="config" href="../../../ui/xslt/controllers/metrical-params-to-model.xsl"/>
						<p:output name="data" id="compare-url-generator-config"/>
					</p:processor>

					<!-- get the data from fuseki -->
					<p:processor name="oxf:url-generator">
						<p:input name="config" href="#compare-url-generator-config"/>
						<p:output name="data" id="sparql-results"/>
					</p:processor>

					<p:processor name="oxf:identity">
						<p:input name="data" href="aggregate('value', current(), #sparql-results)"/>
						<p:output name="data" ref="range-result"/>
					</p:processor>
				</p:for-each>

				<p:processor name="oxf:identity">
					<p:input name="data" href="#range-result"/>
					<p:output name="data" ref="aggregate-response"/>
				</p:processor>
			</p:for-each>

			<p:processor name="oxf:identity">
				<p:input name="data" href="#aggregate-response"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<!-- add in compare queries -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#request"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						<!-- request parameters -->
						<xsl:param name="compare" select="/request/parameters/parameter[name='compare']/value"/>
						<xsl:param name="filter" select="/request/parameters/parameter[name='filter']/value"/>
						<xsl:param name="interval" select="/request/parameters/parameter[name='interval']/value"/>
						<xsl:param name="from" select="/request/parameters/parameter[name='from']/value"/>
						<xsl:param name="to" select="/request/parameters/parameter[name='to']/value"/>

						<xsl:template match="/">
							<queries>
								<xsl:if test="string($filter)">
									<query>
										<xsl:value-of select="normalize-space($filter)"/>
									</query>
								</xsl:if>
								<xsl:for-each select="$compare">
									<query>
										<xsl:value-of select="."/>
									</query>
								</xsl:for-each>
							</queries>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="compare-queries"/>
			</p:processor>

			<!-- when there is at least one compare query, then aggregate the compare queries with the primary query into one model -->
			<p:for-each href="#compare-queries" select="//query" root="response" id="sparql-results">
				<p:processor name="oxf:unsafe-xslt">
					<p:input name="filter" href="current()"/>
					<p:input name="query" href="#query-document"/>
					<p:input name="request" href="#request"/>
					<p:input name="data" href="#config"/>
					<p:input name="config" href="../../../ui/xslt/controllers/metrical-params-to-model.xsl"/>
					<p:output name="data" id="compare-url-generator-config"/>
				</p:processor>

				<!-- get the data from fuseki -->
				<p:processor name="oxf:url-generator">
					<p:input name="config" href="#compare-url-generator-config"/>
					<p:output name="data" ref="sparql-results"/>
				</p:processor>
			</p:for-each>

			<p:processor name="oxf:identity">
				<p:input name="data" href="#sparql-results"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:config>
