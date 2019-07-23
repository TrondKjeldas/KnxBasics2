
# Since jazzy does not (yet) support SPM projects directly,
# we need to jump through som hoops.

# Make sure this points to the correct jazzy vended sourcekitten
KITTEN=$HOME/.rbenv/versions/2.3.8/lib/ruby/gems/2.3.0/gems/jazzy-0.10.0/bin/sourcekitten
DOCSRC=doc.json

# Generate the input for jazzy this way, since sourcekitten supports SPM projects
$KITTEN doc --spm-module KnxBasics2 > $DOCSRC

# Then run jazzy with the output from the previous step as input
jazzy --clean --sourcekitten-sourcefile $DOCSRC --output docs \
      --theme fullwidth --author Trond Kjeldås \
      --skip-undocumented --module KnxBasics2 \
      --swift-version 5.1 --exclude Source/KnxBasics2/DispacthQueueDoOnce.swift

# Remove the temporary file
rm $DOCSRC
