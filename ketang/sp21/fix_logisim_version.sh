#!/bin/bash

#!/bin/bash


#!/bin/bash


#!/bin/bash

#!/bin/bash

find . -name '*.circ' -exec sed -i '' -E 's/(source="[0-9]\.[0-9]\.[0-9])-[^"]*/\1/g' {} \; -exec echo "Modified file: {}" \;

