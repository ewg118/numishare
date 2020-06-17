xquery version "1.0";

(:Author: Ethan Gruber
Date: June 2020
Function: XQuery to get the child symbols of a symbol from eXist-db:)

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace crm = "http://www.cidoc-crm.org/cidoc-crm/";
declare namespace crmdig = "http://www.ics.forth.gr/isl/CRMdig/";

    <rdf:RDF
        xmlns:dcterms="http://purl.org/dc/terms/"
        xmlns:nmo="http://nomisma.org/ontology#"
        xmlns:foaf="http://xmlns.com/foaf/0.1/"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:skos="http://www.w3.org/2004/02/skos/core#"
        xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
        xmlns:void="http://rdfs.org/ns/void#"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
        xmlns:prov="http://www.w3.org/ns/prov#"
        xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
        xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig/">
        {
            for $record in collection('/db/numishare/symbols')[descendant::skos:broader/@rdf:resource = '%URI%']
                
                return
                    $record//rdf:RDF/*[1]
        }
    </rdf:RDF>