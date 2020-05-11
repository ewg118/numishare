xquery version "1.0";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace xs = "http://www.w3.org/2001/XMLSchema";

let $collection-name := substring-before(substring-after(request:get-uri(), '/exist/rest/db/'), '/')
let $identifiers := request:get-parameter("identifiers", 0)
let $sequence := tokenize($identifiers, '\|')

return
    <nudsGroup
        xmlns:xlink="http://www.w3.org/1999/xlink"
        xmlns:nuds="http://nomisma.org/nuds"
        xmlns:mods="http://www.loc.gov/mods/v3"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:mets="http://www.loc.gov/METS/"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">
        {
            for $doc in $sequence
            return
                (:if there's a forward slash in the identifier sequence, this assumes a manual checking of symbol or object collection:)
                if (contains($doc, '/')) then
                    (:evaluate the full document path and the extension of XML or RDF for NUDS file or symbol/monogram RDF:)
                    let $collection := if (substring-before($doc, '/') = 'symbol') then
                        'symbols'
                    else
                        'objects'
                    
                    let $ext := if (substring-before($doc, '/') = 'symbol') then
                        'rdf'
                    else
                        'xml'
                    
                    let $path := concat('/db/', $collection-name, '/', $collection, '/', substring-after($doc, '/'), ".", $ext)
                    return
                        doc($path)/*
                else
                    (:otherwise read the ID from the NUDS objects folder with an XML extension:)
                    let $path := concat('/db/', $collection-name, '/objects/', $doc, ".xml")
                    return
                        doc($path)/*
        }
    </nudsGroup>