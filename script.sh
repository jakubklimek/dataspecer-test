URL=https://ofn.gov.cz/data-specification/7568e98b-13e3-4780-850b-979262432d60
SPEC=test-tc-2022-04-08
SCHEMA=tourist-destination

dataspecer generate $URL
mkdir data
mkdir data/rdf
mkdir data/xml
mkdir data/json
mkdir data/csv
cp input.ttl data/rdf
cp input.csv data/csv
#pygmentize -g data/rdf/input.ttl
sparql --data=data/rdf/input.ttl --query=$SPEC/$SCHEMA/query.sparql --results=turtle > data/rdf/sparqled.ttl
rdfdiff data/rdf/input.ttl data/rdf/sparqled.ttl TTL TTL > data/rdf/sparqled-diff.txt
#pygmentize -g data/rdf/sparqled.ttl
riot --output=rdfxml data/rdf/input.ttl > data/rdf/input.rdf
#pygmentize -g data/rdf/input.rdf
xslt3 -xsl:rdf-to-sparql.xsl -s:data/rdf/input.rdf -o:data/xml/sparql-result.xml -t
#pygmentize -g data/xml/sparql-result.xml
xslt3 -xsl:$SPEC/$SCHEMA/lowering.xslt -s:data/xml/sparql-result.xml -o:data/xml/lowered.xml -t
#pygmentize -g data/xml/lowered.xml
xmllint --schema $SPEC/$SCHEMA/schema.xsd data/xml/lowered.xml --noout > data/xml/xsd-validation.txt 2>&1
xslt3 -xsl:$SPEC/$SCHEMA/lifting.xslt -s:data/xml/lowered.xml -o:data/rdf/lifted.rdf -t
#pygmentize -g data/rdf/lifted.rdf
riot --formatted=turtle data/rdf/lifted.rdf > data/rdf/lifted.ttl 2> data/rdf/lifted-validation.txt
rdfdiff data/rdf/input.ttl data/rdf/lifted.ttl TTL TTL > data/rdf/lifted-diff.txt
rdf validate --format tabular --metadata $SPEC/$SCHEMA/schema.csv-metadata.json data/csv/input.csv > data/csv/validation.txt 2>&1
rdf serialize --format tabular --minimal --decode-uri --output-format turtle --metadata $SPEC/$SCHEMA/schema.csv-metadata.json -o data/rdf/csv.ttl data/csv/input.csv