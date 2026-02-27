module.exports = {
    skipFiles: ['mocks', 'proxies'],
    mocha: {
        grep: "@skip-on-coverage",
        invert: true
    }
};