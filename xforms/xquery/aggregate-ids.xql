xquery version "1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace xs="http://www.w3.org/2001/XMLSchema";

let $collection-name:= substring-before(substring-after(request:get-uri(), '/exist/rest/db/'), '/')
let $identifiers:= request:get-parameter("identifiers",0)
let $sequence:= tokenize($identifiers, '\|')

return
<nudsGroup xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:nuds="http://nomisma.org/nuds" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mets="http://www.loc.gov/METS/" xmlns:xs="http://www.w3.org/2001/XMLSchema">
   {
         for $doc in $sequence
         let $path:= concat('/db/', $collection-name, '/objects/', $doc, ".xml")
         return doc($path)/* 
      }
</nudsGroup>