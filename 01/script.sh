URL=https://ofn.gov.cz/data-specification/7568e98b-13e3-4780-850b-979262432d60
SPEC=test-tc-2022-04-08
SCHEMA=tourist-destination

dataspecer generate $URL
mkdir data 2>/dev/null
mkdir data/rdf 2>/dev/null
mkdir data/xml 2>/dev/null
cp input.ttl data/rdf
#pygmentize -g data/rdf/input.ttl
echo -------------SPARQL CONSTRUCT--------------
sparql --data=data/rdf/input.ttl --query=$SPEC/$SCHEMA/query.sparql --results=turtle > data/rdf/sparqled.ttl

echo -------------SPARQL DIFF-------------------
rdfdiff data/rdf/input.ttl data/rdf/sparqled.ttl TTL TTL > data/rdf/diff-sparqled.txt
cat data/rdf/diff-sparqled.txt
#pygmentize -g data/rdf/sparqled.ttl

echo -------------Turtle to RDF/XML-------------
riot --output=rdfxml data/rdf/input.ttl > data/rdf/input.rdf
#pygmentize -g data/rdf/input.rdf

echo -------------RDF/XML to XML SPARQL Results-
xslt3 -xsl:../common/rdf-to-sparql.xsl -s:data/rdf/input.rdf -o:data/xml/sparql-result.xml -t
#pygmentize -g data/xml/sparql-result.xml

echo -------------Lowering XSLT-----------------
xslt3 -xsl:$SPEC/$SCHEMA/lowering.xslt -s:data/xml/sparql-result.xml -o:data/xml/lowered.xml -t
#pygmentize -g data/xml/lowered.xml

echo -------------XSD Validation----------------
xmllint --schema $SPEC/$SCHEMA/schema.xsd data/xml/lowered.xml --noout > data/xml/xsd-validation.txt 2>&1
cat data/xml/xsd-validation.txt

echo -------------Lifting XSLT------------------
xslt3 -xsl:$SPEC/$SCHEMA/lifting.xslt -s:data/xml/lowered.xml -o:data/rdf/lifted.rdf -t
#pygmentize -g data/rdf/lifted.rdf

echo -------------RDF/XML to Turtle-------------
#save output without timestamp so that we can compare it
riot --formatted=turtle data/rdf/lifted.rdf 2>&1 >data/rdf/lifted.ttl | cut -d" " -f2- > data/rdf/lifted-validation.txt

echo -------------Lifted DIFF-------------------
rdfdiff data/rdf/input.ttl data/rdf/lifted.ttl TTL TTL > data/rdf/diff-lifted.txt
cat data/rdf/diff-lifted.txt