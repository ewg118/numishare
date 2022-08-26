xquery version "1.0";

(:Author: Ethan Gruber
Date: December 2019
Function: Get distinct letters/URIs that are components of monograms :)

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace crm = "http://www.cidoc-crm.org/cidoc-crm/";
declare namespace crmdig = "http://www.ics.forth.gr/isl/CRMdig/";

<letters>
    {
        for $x in distinct-values(collection(COLLECTION)//crm:P106_is_composed_of)
        order by $x
        return
            <letter codepoint="{string-to-codepoints($x)}">
                {
                    $x
                }
            </letter>
    }
    {
        for $x in distinct-values(collection(COLLECTION)//crm:P165i_is_incorporated_in[string(.) and not(child::*)])
        order by $x
        return
            <glyph codepoint="{string-to-codepoints($x)}">
                {
                    $x
                }
            </glyph>
    }
</letters>

