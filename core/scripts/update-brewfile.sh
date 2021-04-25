# Clear the existing.
rm -f .Brewfile

# Add a heading because we're having a nice time.
echo "# Brewfile\n" > .Brewfile

# Format the leaves and dump.
brew leaves | sed 's/^/brew "/' | sed 's/$/"/' >> .Brewfile
