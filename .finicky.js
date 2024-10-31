// Use https://finicky-kickstart.now.sh to generate basic configuration
// Learn more about configuration options: https://github.com/johnste/finicky/wiki/Configuration

const profileNames = {
  // The profile name you supply to Finicky must match the folder name of the profile. For Chrome,
  // the folders are located at ~/Library/Application Support/Google/Chrome. Folder names are called
  // "Profile 1", "Profile 2", etc.
  personal: "Profile 2",
  hen: "Profile 3"
};

module.exports = {
  defaultBrowser: "Google Chrome",
  handlers: [
    {
      match: [
        /github.com\/comprehensiveio/,
        /linear.app/,
        /loom.com/,
        /range.co/,
        /render.com/,
      ],
      browser: {
        name: "Google Chrome",
        profile: profileNames.hen,
      },
    },
    {
      match: [/github.com\/scottyeck/, /focusmate.com/],
      browser: {
        name: "Google Chrome",
        profile: profileNames.personal,
      },
    },
  ],
};
