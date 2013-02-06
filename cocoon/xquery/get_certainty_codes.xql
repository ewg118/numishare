xquery version "1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace nuds="http://nomisma.org/nuds";

<results>
   {
         for $i in distinct-values(collection('/db/numishare/objects')//nuds:typeDesc/@certainty)
         return 
         <code> { $i } </code>
      }
</results>