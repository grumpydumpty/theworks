#!/bin/bash

cat << EOF > ./tmp.sh
#!/bin/bash

echo "| Package | Version |";
echo "|---------|---------|";
EOF

cat Dockerfile | sed -nE '/export [A-Z]+_VERSION/p' | sed -E 's/[[:space:]]+export /echo \"| /g;s/(.*)_VERSION/\1/g;s/=/ | /g;s/ \&\& \\$/ |\"/g;' >> ./tmp.sh
cat Dockerfile | sed -nE '/RUN [A-Z]+_VERSION/p' | sed -E 's/^RUN /echo \"| /g;s/(.*)_VERSION/\1/g;s/=/ | /g;s/ \&\& \\$/ |\"/g;' >> ./tmp.sh

sed -i '' '1,/<!-- snip -->/!d' README.md

chmod +x ./tmp.sh

./tmp.sh >> README.md

rm -f ./tmp.sh
