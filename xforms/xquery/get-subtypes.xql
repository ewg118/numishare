xquery version "3.0";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace nuds = "http://nomisma.org/nuds";
declare namespace xlink = "http://www.w3.org/1999/xlink";

let $collection-name:= substring-before(substring-after(request:get-uri(), '/exist/rest/db/'), '/')
let $identifiers:= request:get-parameter("identifiers",0)
let $sequence := tokenize($identifiers, '\|')
return
    <response
        xmlns:xlink="http://www.w3.org/1999/xlink">
        {
            for $id in $sequence
            return
                <type
                    recordId="{$id}">
                    {
                        for $doc in collection()[descendant::nuds:otherRecordId[@semantic = 'skos:broader'] = $id]
                        return
                            <subtype
                                recordId="{data($doc//nuds:recordId)}" sortId="{data($doc//nuds:otherRecordId[@localType = 'sortId'])}"><descMeta
                                    xmlns="http://nomisma.org/nuds">
                                    {$doc//nuds:descMeta/*}
                                </descMeta></subtype>
                    }
                </type>
        }
    </response>