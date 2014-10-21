Numishare is an open source suite of applications for managing digital cultural heritage artifacts, with a particular focus on coins and medals. It is developed and maintained by the American Numismatic Society and employed for its online collection. The architecture of the application is built upon an XML foundation. Coins and medals are described in an XML adaptation of NUDS, the Numismatic Database Standard. Other artifacts are encoded in VRA Core 4.0. The adherence to common library/archive/museum standards and best practices ensures the long-term sustainability and curation of the data.

Background
=========

The code has descended and evolved from the University of Virginia Art Museum Numismatic Collection website, produced by the University of Virginia Library and hosted by the Scholars' Lab. The project commenced in Fall 2007 and the code was open sourced Summer 2009. Considerable work commenced, with sponsorship from the Kittredge Numismatic Foundation, to develop the software with small-to-medium institutions, collectors, and historical societies in mind. An administrative interface was developed taking advantage of cutting-edge XForms apps to create, edit, and publish the XML data. The architecture is a major departure from typical LAMP (Linux, Apache, MySQL, PHP) content management systems, enabling far more sophisticated data models which allow for the creation of an advanced public user interface.

Numishare has been developed by the American Numismatic Society since January 2011.

Architecture
=========

Numishare's codebase is open source, and is built upon a modularized set of open source applications that run within Apache Tomcat, including:

  * [Orbeon](http://www.orbeon.com): Enterprise-level server-side XForms processor which manages back-end workflows as well as produces the fully modern public user interface in HTML5 and provides access to alternate models in KML, RDF/XML, Turtle, JSON-LD, Atom, etc. through both REST and content negotation.
  * [Apache Solr](http://lucene.apache.org/solr/) Advanced search index based on Lucene which provides faceted browsing
  * [eXist-db](http://exist-db.org/exist/apps/homepage/index.html): XML database
