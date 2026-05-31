module.exports = {
  root: true,
  env: {es2022: true, node: true},
  parser: "@typescript-eslint/parser",
  parserOptions: {ecmaVersion: 2022, sourceType: "module"},
  plugins: ["@typescript-eslint"],
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
  ],
  ignorePatterns: ["lib/", "node_modules/", "*.js"],
  rules: {
    "quotes": ["error", "double"],
    "indent": ["error", 2],
  },
};
