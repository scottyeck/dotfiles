// Use https://finicky-kickstart.now.sh to generate basic configuration
// Learn more about configuration options: https://github.com/johnste/finicky/wiki/Configuration

const profileNames = {
  // The profile name you supply to Finicky must match the folder name of the profile. For Chrome,
  // the folders are located at ~/Library/Application Support/Google/Chrome. Folder names are called
  // "Default", "Profile 1", "Profile 2", etc.
  //
  // To find out which one is which, run: identify_chrome_profiles
  personal: "Default",
  skylight: "Profile 1",
};

module.exports = {
  defaultBrowser: "Google Chrome",
  handlers: [
    {
      match: [/github.com\/SkylightFamily/, /linear.app/, /loom.com/],
      browser: {
        name: "Google Chrome",
        profile: profileNames.skylight,
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
