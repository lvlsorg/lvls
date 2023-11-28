module.exports= {
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
  "ecmaFeatures": {
    "jsx": true
  }
  },
  "plugins": ["@typescript-eslint", "react", "react-hooks"],
  "extends": [
  "plugin:react/recommended",
  "plugin:@typescript-eslint/recommended",
  "plugin:@next/next/recommended",
  "prettier"],
  "ignorePatterns": ["node_modules/*", "out/*", "hardhat-scripts/*"]
}