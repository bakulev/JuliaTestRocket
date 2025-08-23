// Jest-style configuration for Julia tests
// This helps some IDEs recognize test structure

module.exports = {
  displayName: 'Julia Point Controller Tests',
  testMatch: ['**/test/**/*.jl'],
  testEnvironment: 'node',
  runner: 'julia',
  collectCoverageFrom: [
    'src/**/*.jl'
  ]
};