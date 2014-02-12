<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all"
	xmlns:numishare="https://github.com/ewg118/numishare" xmlns:cinclude="http://apache.org/cocoon/include/1.0" version="2.0">
	<xsl:include href="../functions.xsl"/>
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:param name="q"/>
	<xsl:param name="pipeline"/>
	
	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="$pipeline='maps'">../</xsl:when>
			<xsl:when test="$pipeline='maps_fullscreen'">../../</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="centuries" as="element()*">
		<xsl:variable name="all" as="element()*">
			<centuries>
				<xsl:analyze-string select="$q" regex="((century|decade)_num:&#x022;[^&#x022;]+&#x022;)">
					<xsl:matching-substring>
						<xsl:for-each select="regex-group(1)">
							<xsl:choose>
								<xsl:when test="contains(., 'century_num')">
									<century>
										<xsl:value-of select="substring-after(translate(., '&#x022;()', ''), ':')"/>
									</century>
								</xsl:when>
								<xsl:when test="contains(., 'decade_num')">
									<xsl:variable name="num" select="number(substring-after(translate(., '&#x022;()', ''), ':')) div 100"/>
									<xsl:choose>
										<xsl:when test="$num &lt; 0">
											<century>
												<xsl:value-of select="floor($num)"/>
											</century>
										</xsl:when>
										<xsl:when test="$num &gt; 0">
											<century>
												<xsl:value-of select="ceiling($num)"/>
											</century>
										</xsl:when>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>

						</xsl:for-each>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</centuries>
		</xsl:variable>

		<centuries>
			<xsl:for-each select="distinct-values($all//century)">
				<xsl:sort order="ascending" data-type="number"/>
				<century>
					<xsl:value-of select="."/>
				</century>
			</xsl:for-each>
		</centuries>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="descendant::lst[@name='century_num']"/>
	</xsl:template>

	<xsl:template match="lst[@name='century_num']">
		<xsl:choose>
			<xsl:when test="count(int) = 0">
				<option disabled="disabled">No options available</option>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="int">
					<xsl:choose>
						<xsl:when test="number(@name) &lt; 0">
							<li>
								<span class="expand_century" century="{@name}" q="{$q}">
									<img src="{$display_path}images/{if (boolean(index-of($centuries//century, @name)) = true()) then 'minus' else 'plus'}.gif" alt="expand"/>
								</span>
								<xsl:choose>
									<xsl:when test="boolean(index-of($centuries//century, @name)) = true()">
										<input type="checkbox" value="{@name}" checked="checked" class="century_checkbox"/>
									</xsl:when>
									<xsl:otherwise>
										<input type="checkbox" value="{@name}" class="century_checkbox"/>
									</xsl:otherwise>
								</xsl:choose>
								<!-- output for 1800s, 1900s, etc. -->
								<xsl:value-of select="numishare:normalize_century(@name)"/>
								<ul id="century_{@name}_list" class="decades-list"
									style="{if(boolean(index-of($centuries//century, @name)) = true()) then '' else 'display:none'}">
									<xsl:if test="boolean(index-of($centuries//century, @name)) = true()">
										<cinclude:include src="cocoon:/get_decades?q={encode-for-uri($q)}&amp;century=&#x022;{@name}&#x022;"/>
									</xsl:if>
								</ul>
							</li>
						</xsl:when>
						<xsl:otherwise>
							<li>
								<span class="expand_century" century="{@name}" q="{$q}">
									<img src="{$display_path}images/{if (boolean(index-of($centuries//century, @name)) = true()) then 'minus' else 'plus'}.gif" alt="expand"/>
								</span>
								<xsl:choose>
									<xsl:when test="boolean(index-of($centuries//century, @name)) = true()">
										<input type="checkbox" value="{@name}" checked="checked" class="century_checkbox"/>
									</xsl:when>
									<xsl:otherwise>
										<input type="checkbox" value="{@name}" class="century_checkbox"/>
									</xsl:otherwise>
								</xsl:choose>
								<!-- output for 1800s, 1900s, etc. -->
								<xsl:value-of select="numishare:normalize_century(@name)"/>
								<ul id="century_{@name}_list" class="decades-list"
									style="{if(boolean(index-of($centuries//century, @name)) = true()) then '' else 'display:none'}">
									<xsl:if test="boolean(index-of($centuries//century, @name)) = true()">
										<cinclude:include src="cocoon:/get_decades?q={encode-for-uri($q)}&amp;century=&#x022;{@name}&#x022;"/>
									</xsl:if>
								</ul>
							</li>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
