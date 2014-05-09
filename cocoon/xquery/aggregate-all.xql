declare namespace nuds="http://nomisma.org/nuds";
declare namespace xlink="http://www.w3.org/1999/xlink";
<nudsGroup>
   {
         for $doc in collection('/db/numishare/objects/')[descendant::*:publicationStatus='approved' and (descendant::nuds:nuds/@recordType='conceptual' or descendant::nuds:typeDesc[string(@xlink:href)])]
         return $doc 
      }
</nudsGroup>