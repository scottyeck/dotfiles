// Use https://finicky-kickstart.now.sh to generate basic configuration
// Learn more about configuration options: https://github.com/johnste/finicky/wiki/Configuration

const profileNames = {
  personal: "Default",
  hen: "Profile 2",
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
