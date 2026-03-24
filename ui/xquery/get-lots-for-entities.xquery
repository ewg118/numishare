xquery version "1.0";

(:Author: Ethan Gruber
Date: March 2026
Function: Execute query to gather all lots associated with an entity URI :)

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace crm = "http://www.cidoc-crm.org/cidoc-crm/";
declare namespace la = "https://linked.art/ns/terms/";

<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:la="https://linked.art/ns/terms/">
    {
        for $record in collection(COLLECTION)//rdf:RDF[descendant::crm:P23_transferred_title_from[@rdf:resource = '%URI%']]
            order by $record//crm:P82a_begin_of_the_begin
        return
           $record/*
    }
</rdf:RDF>
