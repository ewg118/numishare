<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
    Last Modified: November 2020
    Function: Templates for constructing the SPARQL metamodel for various sorts of API calls that execute a query for metrical analysis, distribution visualizations, network graphs,
    SPARQL-based facets in vis UIs, etc. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">

    <xsl:template name="numishare:filterToMetamodel">
        <xsl:param name="subject"/>
        <xsl:param name="filter"/>

        <xsl:for-each select="tokenize($filter, ';')">
            <xsl:variable name="property" select="substring-before(normalize-space(.), ' ')"/>
            <xsl:variable name="object" select="substring-after(normalize-space(.), ' ')"/>
            <xsl:choose>
                <xsl:when test="$property = 'portrait' or $property = 'deity'">
                    <union>
                        <triple s="{$subject}" p="nmo:hasObverse/nmo:hasPortrait" o="{$object}"/>
                        <triple s="{$subject}" p="nmo:hasReverse/nmo:hasPortrait" o="{$object}"/>
                    </union>
                </xsl:when>
                <xsl:when test="$property = 'authPerson'">
                    <triple s="{$subject}" p="nmo:hasAuthority" o="{$object}"/>
                </xsl:when>
                <xsl:when test="$property = 'authCorp'">
                    <union>
                        <group>
                            <triple s="{$subject}" p="nmo:hasAuthority" o="{$object}"/>
                        </group>
                        <group>
                            <triple s="{$subject}" p="nmo:hasAuthority" o="?authority"/>
                            <triple s="?authority" p="org:hasMembership/org:organization" o="{$object}"/>
                        </group>
                    </union>
                </xsl:when>
                <xsl:when test="$property = 'dynasty'">
                    <union>
                        <group>
                            <triple s="{$subject}" p="nmo:hasAuthority" o="{$object}"/>
                            <triple s="{$object}" p="a" o="rdac:Family"/>
                        </group>
                        <group>
                            <triple s="{$subject}" p="nmo:hasAuthority" o="?person"/>
                            <triple s="?person" p="org:memberOf" o="{$object}"/>
                            <triple s="{$object}" p="a" o="rdac:Family"/>
                        </group>
                    </union>
                </xsl:when>
                <xsl:when test="$property = 'from'">
                    <xsl:if test="$object castable as xs:integer">
                        <xsl:variable name="gYear" select="format-number(number($object), '0000')"/>

                        <triple s="{$subject}" p="nmo:hasStartDate" o="?startDate">
                            <xsl:attribute name="filter">
                                <xsl:text>(?startDate &gt;= "</xsl:text>
                                <xsl:value-of select="$gYear"/>
                                <xsl:text>"^^xsd:gYear)</xsl:text>
                            </xsl:attribute>
                        </triple>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$property = 'to'">
                    <xsl:if test="$object castable as xs:integer">
                        <xsl:variable name="gYear" select="format-number(number($object), '0000')"/>

                        <triple s="{$subject}" p="nmo:hasEndDate" o="?endDate">
                            <xsl:attribute name="filter">
                                <xsl:text>(?endDate &lt;= "</xsl:text>
                                <xsl:value-of select="$gYear"/>
                                <xsl:text>"^^xsd:gYear)</xsl:text>
                            </xsl:attribute>
                        </triple>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$property = 'range'">
                    <xsl:if test="matches($object, '-?\d+\|-?\d+')">
                        <xsl:variable name="range" select="tokenize($object, '\|')"/>

                        <xsl:variable name="s">
                            <xsl:choose>
                                <xsl:when test="contains($filter, 'nmo:hasTypeSeriesItem')">
                                    <xsl:analyze-string select="$filter" regex="nmo:hasTypeSeriesItem\s(&lt;.*&gt;)">
                                        <xsl:matching-substring>
                                            <xsl:value-of select="regex-group(1)"/>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$subject"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:choose>
                            <!-- if the interval is 1, then the from and to are the same -->
                            <xsl:when test="number($range[1]) = number($range[2])">
                                <triple s="{$s}" p="nmo:hasStartDate" o="?startDate">
                                    <xsl:attribute name="filter">
                                        <xsl:text>(?startDate &lt;= "</xsl:text>
                                        <xsl:value-of select="format-number(number($range[1]), '0000')"/>
                                        <xsl:text>"^^xsd:gYear)</xsl:text>
                                    </xsl:attribute>
                                </triple>
                                <triple s="{$s}" p="nmo:hasEndDate" o="?endDate">
                                    <xsl:attribute name="filter">
                                        <xsl:text>(?endDate &gt;= "</xsl:text>
                                        <xsl:value-of select="format-number(number($range[1]), '0000')"/>
                                        <xsl:text>"^^xsd:gYear)</xsl:text>
                                    </xsl:attribute>
                                </triple>
                            </xsl:when>
                            <xsl:otherwise>
                                <triple s="{$s}" p="nmo:hasEndDate" o="?endDate">
                                    <xsl:attribute name="filter">
                                        <xsl:text>(?endDate &gt;= "</xsl:text>
                                        <xsl:value-of select="format-number(number($range[1]), '0000')"/>
                                        <xsl:text>"^^xsd:gYear &amp;&amp; ?endDate &lt;= "</xsl:text>
                                        <xsl:value-of select="format-number(number($range[2]), '0000')"/>
                                        <xsl:text>"^^xsd:gYear)</xsl:text>
                                    </xsl:attribute>
                                </triple>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$property = 'nmo:hasTypeSeriesItem'">
                    <!-- get the measurements for all coins connected with a given type or any of its subtypes -->
                    <union>
                        <group>
                            <triple s="{$subject}" p="{$property}" o="{$object}"/>
                        </group>
                        <group>
                            <triple s="?broader" p="skos:broader+" o="{$object}"/>
                            <triple s="{$subject}" p="{$property}" o="?broader"/>
                        </group>
                    </union>
                </xsl:when>
                <xsl:otherwise>
                    <triple s="{$subject}" p="{$property}" o="{$object}"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="numishare:distToMetamodel">
        <xsl:param name="object"/>
        <xsl:param name="dist"/>

        <xsl:choose>
            <xsl:when test="$dist = 'authPerson'">
                <triple s="?coinType" p="nmo:hasAuthority" o="{$object}"/>
                <triple s="{$object}" p="a" o="foaf:Person"/>
            </xsl:when>
            <xsl:when test="$dist = 'authCorp'">
                <union>
                    <group>
                        <triple s="?coinType" p="nmo:hasAuthority" o="{$object}"/>
                    </group>
                    <group>
                        <triple s="?coinType" p="nmo:hasAuthority" o="?authority"/>
                        <triple s="?authority" p="org:hasMembership/org:organization" o="{$object}"/>
                    </group>
                </union>
                <triple s="{$object}" p="a" o="foaf:Organization"/>
            </xsl:when>
            <xsl:when test="$dist = 'dynasty'">
                <union>
                    <group>
                        <triple s="?coinType" p="nmo:hasAuthority" o="{$object}"/>
                        <triple s="{$object}" p="a" o="rdac:Family"/>
                    </group>
                    <group>
                        <triple s="?coinType" p="nmo:hasAuthority" o="?person"/>
                        <triple s="?person" p="org:memberOf" o="{$object}"/>
                        <triple s="{$object}" p="a" o="rdac:Family"/>
                    </group>
                </union>
            </xsl:when>
            <xsl:when test="$dist = 'portrait' or $dist = 'deity'">
                <xsl:variable name="distClass"
                    select="
                        if ($dist = 'portrait') then
                            'foaf:Person'
                        else
                            'wordnet:Deity'"/>
                <union>
                    <triple s="?coinType" p="nmo:hasObverse/nmo:hasPortrait" o="{$object}"/>
                    <triple s="?coinType" p="nmo:hasReverse/nmo:hasPortrait" o="{$object}"/>
                </union>
                <triple s="{$object}" p="a" o="{$distClass}"/>
            </xsl:when>
            <xsl:when test="$dist = 'region'">
                <union>
                    <group>
                        <triple s="?coinType" p="nmo:hasRegion" o="{$object}"/>
                    </group>
                    <group>
                        <triple s="?coinType" p="nmo:hasMint" o="?mint"/>
                        <triple s="?mint" p="skos:broader+" o="{$object}"/>
                    </group>
                </union>
            </xsl:when>
            <xsl:otherwise>
                <triple s="?coinType" p="{$dist}" o="{$object}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- get hoards associated with either types or symbols -->
    <xsl:template name="numishare:getHoards">
        <xsl:param name="uri"/>
        <xsl:param name="type"/>
        
        <xsl:choose>
            <xsl:when test="$type = 'cointype'">
                <bind statement="&lt;{$uri}&gt;" variable="?coinType"/>
                <union>
                    <group>
                        <triple s="?object" p="nmo:hasTypeSeriesItem|nmo:hasTypeSeriesItem/skos:exactMatch|nmo:hasTypeSeriesItem/skos:broader+" o="?coinType"/>
                        <triple s="?object" p="rdf:type" o="nmo:NumismaticObject"/>
                        <triple s="?object" p="dcterms:isPartOf" o="?hoard"/>
                        <triple s="?hoard" p="nmo:hasFindspot/crm:P7_took_place_at/crm:P89_falls_within" o="?place"/>
                    </group>
                    <group>
                        <triple s="?contents" p="nmo:hasTypeSeriesItem" o="?coinType"/>
                        <triple s="?contents" p="rdf:type" o="dcmitype:Collection"/>
                        <triple s="?hoard" p="dcterms:tableOfContents" o="?contents"/>
                        <triple s="?hoard" p="nmo:hasFindspot/crm:P7_took_place_at/crm:P89_falls_within" o="?place"/>
                    </group>
                </union>
            </xsl:when>
            <xsl:when test="$type = 'symbol'">
                <xsl:call-template name="numishare:subSelectSymbols">
                    <xsl:with-param name="uri" select="$uri"/>
                </xsl:call-template>
                
                <union>
                    <group>
                        <triple s="?coinType" p="nmo:hasObverse|nmo:hasReverse" o="?side"/>
                        <triple s="?object" p="nmo:hasTypeSeriesItem" o="?coinType"/>
                        <triple s="?object" p="rdf:type" o="nmo:NumismaticObject"/>
                        <triple s="?object" p="dcterms:isPartOf" o="?hoard"/>
                        <triple s="?hoard" p="nmo:hasFindspot/crm:P7_took_place_at/crm:P89_falls_within" o="?place"/>
                    </group>
                    <group>
                        <triple s="?coinType" p="nmo:hasObverse|nmo:hasReverse" o="?side"/>
                        <triple s="?contents" p="nmo:hasTypeSeriesItem" o="?coinType"/>
                        <triple s="?contents" p="rdf:type" o="dcmitype:Collection"/>
                        <triple s="?hoard" p="dcterms:tableOfContents" o="?contents"/>
                        <triple s="?hoard" p="nmo:hasFindspot/crm:P7_took_place_at/crm:P89_falls_within" o="?place"/>
                    </group>
                </union>
            </xsl:when>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template name="numishare:getFindspots">
        <xsl:param name="uri"/>
        <xsl:param name="type"/>
        
        <xsl:choose>
            <xsl:when test="$type = 'cointype'">
                <bind statement="&lt;{$uri}&gt;" variable="?coinType"/>
                <triple s="?object" p="nmo:hasTypeSeriesItem|nmo:hasTypeSeriesItem/skos:exactMatch|nmo:hasTypeSeriesItem/skos:broader+" o="?coinType"/>
                <triple s="?object" p="rdf:type" o="nmo:NumismaticObject"/>
                <triple s="?object" p="nmo:hasFindspot/crm:P7_took_place_at/crm:P89_falls_within" o="?place"/>
            </xsl:when>
            <xsl:when test="$type = 'symbol'">
                <xsl:call-template name="numishare:subSelectSymbols">
                    <xsl:with-param name="uri" select="$uri"/>
                </xsl:call-template>
                
                <triple s="?coinType" p="nmo:hasObverse|nmo:hasReverse" o="?side"/>
                <triple s="?object" p="nmo:hasTypeSeriesItem" o="?coinType"/>
                <triple s="?object" p="rdf:type" o="nmo:NumismaticObject"/>
                <triple s="?object" p="nmo:hasFindspot/crm:P7_took_place_at/crm:P89_falls_within" o="?place"/>
            </xsl:when>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template name="numishare:getMints">
        <xsl:param name="uri"/>
        
        <xsl:call-template name="numishare:subSelectSymbols">
            <xsl:with-param name="uri" select="$uri"/>
        </xsl:call-template>
        
        <triple s="?coinType" p="nmo:hasObverse|nmo:hasReverse" o="?side"/>
        <triple s="?coinType" p="nmo:hasMint" o="?mint"/>
        <triple s="?mint" p="geo:location" o="?loc"/>        
    </xsl:template>
    
    <!-- creae a subselect query for sides of coins that are associated with particular symbol URIs -->
    <xsl:template name="numishare:subSelectSymbols">
        <xsl:param name="uri"/>
        
        <select variables="?side">
            <union>
                <group>
                    <triple s="?side" p="nmo:hasControlmark" o="&lt;{$uri}&gt;"/>
                </group>
                <group>
                    <triple s="?children" p="skos:broader+" o="&lt;{$uri}&gt;"/>
                    <triple s="?side" p="nmo:hasControlmark" o="?children"/>
                </group>
            </union>
        </select>
    </xsl:template>    

    <!-- query the other monograms associated with a particular monogram -->
    <xsl:template name="numishare:querySymbolRelations">
        <xsl:param name="uri"/>

        <bind statement="&lt;{$uri}&gt;" variable="?symbol"/>
        <triple s="?type" p="nmo:hasObverse/nmo:hasControlmark|nmo:hasReverse/nmo:hasControlmark" o="?symbol"/>
        <triple s="?symbol" p="skos:prefLabel" o="?symbolLabel"/>
        <triple s="?symbol" p="crm:P165i_is_incorporated_in" o="?image"/>
        <triple s="?type" p="nmo:hasObverse/nmo:hasControlmark|nmo:hasReverse/nmo:hasControlmark" o="?altSymbol" filter="(?altSymbol != ?symbol)"/>
        <triple s="?altSymbol" p="skos:prefLabel" o="?altSymbolLabel"/>
        <triple s="?altSymbol" p="crm:P165i_is_incorporated_in" o="?altImage"/>
    </xsl:template>


    <!-- construct groups for 1 or more named graphs pertaining to die studies -->
    <xsl:template name="numishare:graph-group">
        <xsl:param name="uri"/>
        <xsl:param name="namedGraph"/>
        <xsl:param name="side"/>

        <graph namedGraph="{$namedGraph}">
            <triple s="?object" p="nmo:has{$side}/nmo:hasDie" o="?die"/>
            <triple s="?die" p="rdf:value" o="&lt;{$uri}&gt;"/>
        </graph>
        <triple s="?object" p="dcterms:title" o="?title"/>
        <optional>
            <triple s="?object" p="dcterms:identifier" o="?identifier"/>
        </optional>
        <optional>
            <triple s="?object" p="nmo:hasCollection/skos:prefLabel" o="?collection" filter="(langMatches(lang(?collection), &#x022;en&#x022;))"/>
        </optional>
        <triple s="?object" p="void:inDataset" o="?dataset"/>
        <triple s="?dataset" p="dcterms:publisher" o="?publisher"
            filter="(lang(?publisher) = &#x022;&#x022; || langMatches(lang(?publisher), &#x022;en&#x022;))"/>
        <triple s="?dataset" p="dcterms:title" o="?datasetTitle"
            filter="(lang(?datasetTitle) = &#x022;&#x022; || langMatches(lang(?datasetTitle), &#x022;en&#x022;))"/>
        <optional>
            <triple s="?object" p="nmo:has{$side}" o="?side"/>
            <triple s="?side" p="foaf:depiction" o="?reference"/>
            <optional>
                <triple s="?reference" p="dcterms:isReferencedBy" o="?manifest"/>
            </optional>
        </optional>
        <optional>
            <triple s="?object" p="foaf:depiction" o="?reference"/>
        </optional>
    </xsl:template>

    <!-- query the the relations from one die to another. This query is typically executed twice to look for the die URI in both the obverse and reverse, since
        the side is not implicity within the die RDF data -->
    <xsl:template name="numishare:queryDieRelations">
        <xsl:param name="dieURI"/>
        <xsl:param name="namedGraph"/>
        <xsl:param name="side"/>

        <bind statement="&lt;{$dieURI}&gt;" variable="?die"/>
        <graph namedGraph="{$namedGraph}">
            <triple s="?object" p="nmo:has{if ($side = 'obv') then 'Obverse' else 'Reverse'}/nmo:hasDie/rdf:value" o="?die"/>
            <select variables="?object ?altDie">
                <triple s="?object" p="nmo:has{if ($side = 'obv') then 'Reverse' else 'Obverse'}/nmo:hasDie/rdf:value" o="?altDie"/>
            </select>
        </graph>
        <triple s="?die" p="skos:notation" o="?dieLabel"/>
        <triple s="?altDie" p="skos:notation" o="?altDieLabel"/>
    </xsl:template>

    <!-- query dies related to a particular coin type URI -->
    <xsl:template name="numishare:queryDieRelationsForType">
        <xsl:param name="typeURI"/>
        <xsl:param name="namedGraph"/>

        <bind statement="&lt;{$typeURI}&gt;" variable="?type"/>
        <triple s="?object" p="nmo:hasTypeSeriesItem" o="?type"/>
        <graph namedGraph="{$namedGraph}">
            <triple s="?object" p="nmo:hasObverse/nmo:hasDie/rdf:value" o="?die"/>
            <select variables="?object ?altDie">
                <triple s="?object" p="nmo:hasReverse/nmo:hasDie/rdf:value" o="?altDie"/>
            </select>
        </graph>
        <triple s="?die" p="skos:notation" o="?dieLabel"/>
        <triple s="?altDie" p="skos:notation" o="?altDieLabel"/>
        <triple s="?type" p="skos:prefLabel" o="?typeLabel" filter="(langMatches(lang(?typeLabel), &#x022;en&#x022;))"/>
    </xsl:template>

    <!-- query the obverse and reverse dies associated with a coin URI for a given named graph -->
    <xsl:template name="numishare:queryDieRelationsForCoin">
        <xsl:param name="objectURI"/>
        <xsl:param name="namedGraph"/>
        <xsl:param name="side"/>

        <bind statement="&lt;{$objectURI}&gt;" variable="?object"/>
        <graph namedGraph="{$namedGraph}">
            <triple s="?object" p="nmo:has{$side}/nmo:hasDie/rdf:value" o="?die"/>
        </graph>
        <triple s="?die" p="skos:prefLabel" o="?dieLabel" filter="(langMatches(lang(?dieLabel), &#x022;en&#x022;))"/>
    </xsl:template>

</xsl:stylesheet>
