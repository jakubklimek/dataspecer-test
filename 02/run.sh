docker run -i --rm -v $PWD:/usr/src/app -v $PWD/../common:/usr/src/common dataspecer < script.sh
echo "-----------DIFF-----------"
diff -r expected data > diff
cat diff