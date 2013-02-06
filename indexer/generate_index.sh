#write config
FILE=compilation.xml
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $FILE
echo '<content>' >> $FILE
cat ../cocoon/xml/db/uva/config.xml >> $FILE
for i in `ls ../cocoon/xml/db/uva/objects/*.xml`; do cat $i >> $FILE; done;
echo '</content>' >> $FILE

#process add doc
java -jar saxon/saxon9.jar -xi:on -s $FILE -xsl:../cocoon/xslt/solr.xsl collection-name=uva > add_doc.xml

COIN_INDEX=http://localhost:8080/solr/numishare-published/update

echo Posting Solr add document to $COIN_INDEX
curl $COIN_INDEX --data-binary @add_doc.xml -H 'Content-type:text/xml; charset=utf-8' 
curl $COIN_INDEX --data-binary '<commit/>' -H 'Content-type:text/xml; charset=utf-8'
curl $COIN_INDEX --data-binary '<optimize/>' -H 'Content-type:text/xml; charset=utf-8'
echo Done. Cleaning up.
rm $FILE
rm add_doc.xml